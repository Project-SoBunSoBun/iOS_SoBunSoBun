//
//  NavigationTabReactor.swift
//  SoBunSoBun
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
    
    private let chatRoomListWebSocketManager = ChatRoomListWebSocketManager()
    private let commonNetworkManager = CommonNetworkManager()
    private let networkManager = NavigationTabNetworkManager()
    
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "NavigationTab.Reactor"
    )
    
    enum Action {
        case viewDidLoad
        case getChatRoomListData
        case selectIndex(Int)
    }
    
    enum Mutation {
        case setSelectedIndex(Int)
        case setChatRoomList([ChatRoomListResponseDataModel])
        case updateChatRoomList(ChatRoomListResponseDataModel)
        case setErrorMessage(String)
    }
    
    struct State {
        var selectedIndex: Int = 0
        var chatRoomList: [ChatRoomListResponseDataModel] = []
        @Pulse var errorMessage: String? = nil
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return Observable.concat([
                getChatRoomList(),
                getMyData()
            ])
            
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
        
        return newState
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
                
                return Observable.just(.setErrorMessage(String(localized: "ErrorMessage", table: "Common")))
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
                
                return Observable.just(.setErrorMessage(String(localized: "ErrorMessage", table: "Common")))
            }
    }
}
