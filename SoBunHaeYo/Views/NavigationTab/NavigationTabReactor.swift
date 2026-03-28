//
//  NavigationTabReactor.swift
//  SoBunHaeYo
//
//  Created by 김태은 on 10/22/25.
//

import ReactorKit
import RxSwift
import OSLog

class NavigationTabReactor: Reactor {
    init() {
        chatRoomListWebSocketManager.connect()
    }
    
    deinit {
        chatRoomListWebSocketManager.disconnect()
    }
    
    let initialState = State()
    
    private let disposeBag = DisposeBag()
    
    private let chatRoomListWebSocketManager = ChatRoomListWebSocketManager()
    private let commonNetworkManager = CommonNetworkManager()
    private let networkManager = NavigationTabNetworkManager()
    
    private let logger = Logger(
        subsystem: "SoBunHaeYo",
        category: "NavigationTab.Reactor"
    )
    
    enum Action {
        case viewDidLoad
        case getUnreadNotificationCount
        case getChatRoomListData
        case selectIndex(Int)
    }
    
    enum Mutation {
        case setSelectedIndex(Int)
        case setUnreadNotificationCount(Int)
        case setChatRoomList([ChatRoomListResponseDataModel])
        case updateChatRoomList(ChatRoomListResponseDataModel)
        case setErrorMessage(String)
    }
    
    struct State {
        var selectedIndex: Int = 0
        var unreadNotificationCount: Int = 0
        var chatRoomList: [ChatRoomListResponseDataModel] = []
        @Pulse var errorMessage: String? = nil
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            checkFCMToken()
            
            return Observable.concat([
                getUnreadNotificationCount(),
                getChatRoomList(),
                getMyData()
            ])
            
        case .getUnreadNotificationCount:
            return getUnreadNotificationCount()
            
        case .getChatRoomListData:
            return getChatRoomList()
            
        case .selectIndex(let index):
            return Observable.just(.setSelectedIndex(index))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setSelectedIndex(let index):
            newState.selectedIndex = index
            
        case .setUnreadNotificationCount(let count):
            newState.unreadNotificationCount = count
            
        case .setChatRoomList(let models):
            newState.chatRoomList = models
            
        case .updateChatRoomList(let model):
            var list = newState.chatRoomList
            
            if let index = list.firstIndex(where: { $0.roomId == model.roomId }) {
                list.remove(at: index)
            }
            
            list.insert(model, at: 0)
            
            newState.chatRoomList = list
            
        case .setErrorMessage(let message):
            newState.errorMessage = message
        }
        
        let chatUnreadCount = newState.chatRoomList.reduce(0) { $0 + $1.unReadCount }
        let totalBadgeCount = newState.unreadNotificationCount + chatUnreadCount
        
        NotificationManager.shared.updateBadgeCount(totalBadgeCount)
        
        return newState
    }
    
    // sceneDidEnterBackground / sceneWillEnterForeground action 연결 및 변환
    func transform(action: Observable<Action>) -> Observable<Action> {
        let backgroundAction = NotificationCenter.default.rx
            .notification(.sceneDidEnterBackground)
            .flatMap { _ in
                Observable.merge([
                    Observable.just(Action.getUnreadNotificationCount),
                    Observable.just(Action.getChatRoomListData)
                ])
            }
        
        let foregroundAction = NotificationCenter.default.rx
            .notification(.sceneWillEnterForeground)
            .map { _ in Action.getUnreadNotificationCount }
        
        return Observable.merge(action, backgroundAction, foregroundAction)
    }
    
    // webSocketManager publish mutation 연결 및 변환
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        let didReceiveChatRoom = chatRoomListWebSocketManager.didReceiveChatRoom
            .compactMap { $0 }
            .flatMap { model -> Observable<Mutation> in
                return Observable.just(.updateChatRoomList(model))
            }
        
        return Observable.merge(mutation, didReceiveChatRoom)
    }
    
    private func getMyData() -> Observable<Mutation> {
        if KeyChain.shared.get(key: "USER_ID") != nil,
           KeyChain.shared.get(key: "EMAIL") != nil {
            return Observable.empty()
        }
        
        return commonNetworkManager.myProfile()
            .asObservable()
            .flatMap { userInfo -> Observable<Mutation> in
                KeyChain.shared.set(key: "USER_ID", value: String(userInfo.id))
                KeyChain.shared.set(key: "EMAIL", value: userInfo.email)
                
                return Observable.empty()
            }
            .catch { error in
                self.logger.critical("내 정보 불러오는 중 오류 발생: \(error.localizedDescription)")
                
                return Observable.just(.setErrorMessage(String(localized: "ErrorMessage", table: "Error")))
            }
    }
    
    // 읽지 않음 알림 개수 호출
    private func getUnreadNotificationCount() -> Observable<Mutation> {
        return networkManager.getUnreadNotificationCount()
            .asObservable()
            .flatMap { response -> Observable<Mutation> in
                let count = response.data.unreadCount
                self.logger.debug("읽지 않은 알림 개수: \(count)")
                
                return Observable.just(.setUnreadNotificationCount(count))
            }
            .catch { error -> Observable<Mutation> in
                self.logger.critical("읽지 않은 알림 개수를 불러오는 중 오류 발생: \(error.localizedDescription)")
                
                return Observable.empty()
            }
    }
    
    private func getChatRoomList() -> Observable<Mutation> {
        return networkManager.getChatRoomList()
            .asObservable()
            .flatMap { model -> Observable<Mutation> in
                self.logger.debug("채팅방 목록 불러옴")
                
                return Observable.just(.setChatRoomList(model.data))
            }
            .catch { error in
                self.logger.critical("채팅방 목록 불러오는 중 오류 발생: \(error.localizedDescription)")
                
                return Observable.just(.setErrorMessage(String(localized: "ErrorMessage", table: "Error")))
            }
    }
    
    private func checkFCMToken() {
        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        
        if !hasLaunchedBefore {
            self.logger.debug("앱 첫 실행, 알림 권한 요청")
            
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            
            NotificationManager.shared.requestAuthorization { granted in
                self.logger.debug("알림 권한 결과: \(granted)")
                
                guard granted else {
                    self.logger.error("알림 권한 거부함")
                    
                    return
                }
                
                NotificationManager.shared.registerFCMToken()
            }
        } else {
            self.logger.debug("앱 재실행, FCM 토큰 등록")
            
            NotificationManager.shared.registerFCMToken()
        }
    }
}
