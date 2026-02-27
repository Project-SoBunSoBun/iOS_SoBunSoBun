//
//  ChatReactor.swift
//  SoBunSoBun
//
//  Created by 김태은 on 2/15/26.
//

import Foundation
import ReactorKit
import RxSwift
import UIKit
import OSLog

class ChatReactor: Reactor {
    private let chatRoomId: Int
    
    init(chatRoomId: Int) {
        self.chatRoomId = chatRoomId
    }
    
    deinit {
        webSocketManager.disconnect()
    }
    
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "Chat.Chat.Reactor"
    )
    
    private let MESSAGE_LIMIT_COUNT: Int = 50
    
    private let disposeBag = DisposeBag()
    private let webSocketManager = ChatWebSocketManager()
    private let databaseManager = ChatDataBaseManager()
    private let networkManager = ChatNetworkManager()
    
    let initialState: State = State()
    
    enum Action {
        case viewDidLoad
        case getMoreMessages
        case sendMessage(String)
        case bottomMenuTapped
        case backToKeyboard
        case showImagePicker
        case sendImage(UIImage)
        case chatLongPressed(Bool)
        case setSelectedChatMessageModel(ChatMessageModel)
        case leaveChatRoom
    }
    
    enum Mutation {
        case setDetailInfo(ChatRoomDetailModel)
        case updateMessages([ChatMessageModel])
        case addNewMessage(ChatMessageModel)
        case setIsServerMessageEmpty(Bool)
        case setIsDBMessageEmpty(Bool)
        case setBottomOpenMenu(Bool)
        case setIsChatCellMenuOpen(Bool)
        case setSelectedChatMessageModel(ChatMessageModel)
        case setShouldShowImagePicker
        case setError(String)
        case setCriticalError(String)
        case setShouldNavigateToBack
    }
    
    struct State {
        var detailInfoModel: ChatRoomDetailModel?
        var messages: [ChatMessageModel] = []
        var isServerMessageEmpty: Bool = false
        var isDBMessageEmpty: Bool = false
        var isOpenBottomMenu: Bool = false
        var isChatCellMenuOpen: Bool = false
        var selectedChatMessageModel: ChatMessageModel?
        @Pulse var shouldShowIamgePicker: Void?
        @Pulse var errorMessage: String?
        @Pulse var criticalErrorMessage: String?
        @Pulse var shouldNavigateToBack: Void?
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            connectWebSocket()
            return Observable.concat([
                getDetailInfo(),
                getMessages()
            ])
            
        case .getMoreMessages:
            return getMessages()
            
        case .sendMessage(let message):
            sendMessage(message: message)
            return Observable.empty()
            
        case .backToKeyboard:
            return Observable.just(.setBottomOpenMenu(false))
            
        case .bottomMenuTapped:
            return Observable.just(.setBottomOpenMenu(!currentState.isOpenBottomMenu))
            
        case .showImagePicker:
            return Observable.just(.setShouldShowImagePicker)
            
        case .sendImage(let image):
            return sendImage(image: image)
            
        case .chatLongPressed(let isMenuOpen):
            return Observable.just(.setIsChatCellMenuOpen(isMenuOpen))
            
        case .setSelectedChatMessageModel(let model):
            return Observable.just(.setSelectedChatMessageModel(model))
            
        case .leaveChatRoom:
            return leaveChatRoom()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        var messages = currentState.messages
        
        switch mutation {
        case .setDetailInfo(let model):
            newState.detailInfoModel = model
            
        case .updateMessages(let models):
            var dict = Dictionary(uniqueKeysWithValues: currentState.messages.map { ($0.id, $0) })
            
            models.forEach { model in
                dict[model.id] = model
            }
            
            newState.messages = dict.values.sorted { $0.createdAt > $1.createdAt }
            
        case .addNewMessage(let model):
            if let index = messages.firstIndex(where: { $0.id == model.id }) {
                messages[index] = model
            } else {
                messages.insert(model, at: 0)
            }
            
            newState.messages = messages
            
        case .setIsServerMessageEmpty(let isEmpty):
            newState.isServerMessageEmpty = isEmpty
            
        case .setIsDBMessageEmpty(let isEmpty):
            newState.isDBMessageEmpty = isEmpty
            
        case .setBottomOpenMenu(let isOpen):
            newState.isOpenBottomMenu = isOpen
            
        case .setShouldShowImagePicker:
            newState.shouldShowIamgePicker = ()
            
        case .setIsChatCellMenuOpen(let isMenuOpen):
            newState.isChatCellMenuOpen = isMenuOpen
            
        case .setSelectedChatMessageModel(let model):
            newState.selectedChatMessageModel = model
        
        case .setError(let message):
            newState.errorMessage = message
            
        case .setCriticalError(let message):
            newState.criticalErrorMessage = message
            
        case .setShouldNavigateToBack:
            newState.shouldNavigateToBack = ()
        }
        
        return newState
    }
    
    // webSocketManager.didReceiveMessage mutation 연결 및 변환
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        let socketMutation = webSocketManager.didReceiveMessage
            .do {
                self.databaseManager.insertMessage($0)
            }
            .map { Mutation.addNewMessage($0) }
        
        return Observable.merge(mutation, socketMutation)
    }
    
    private func connectWebSocket() {
        webSocketManager.connect(chatRoomId: chatRoomId)
    }
    
    private func getDetailInfo() -> Observable<Mutation> {
        return networkManager.getChatRoomDetail(id: chatRoomId)
            .asObservable()
            .flatMap { model -> Observable<Mutation> in
                return Observable.just(.setDetailInfo(model))
            }
            .catch { error in
                self.logger.critical("채팅방 정보 불러오기 실패: \(error.localizedDescription)")
                
                return Observable.just(.setCriticalError(String(localized: "ErrorGetChatRoomDetail", table: "Chat")))
            }
    }
    
    private func getMessages() -> Observable<Mutation> {
        // deferred로 감싸지 않으면 action 발생 시점의 currentState가 아닌 이전 상태를 참조함
        return Observable.deferred { // 백그라운드에서 수행
            if self.currentState.isDBMessageEmpty {
                return Observable.empty()
            } else if self.currentState.isServerMessageEmpty {
                return self.getMessagesFromDatabase()
            } else {
                return Observable.concat([
                    self.getMessagesFromDatabase(),
                    self.getMessagesFromServer()
                ])
            }
        }
    }
    
    private func getMessagesFromDatabase() -> Observable<Mutation> {
        // 메인 스레드에서 동기로 실행되어 UI 업데이트를 블로킹하기 때문에 백그라운드에서 수행함
        return Observable.deferred { // 백그라운드에서 수행
            let members = self.currentState.detailInfoModel?.data.members
            let messages = self.databaseManager.getMessages(
                roomId: self.chatRoomId,
                beforeCreatedAt: self.currentState.messages.last?.createdAt,
                limit: self.MESSAGE_LIMIT_COUNT
            )
            
            self.logger.debug("내부 DB로부터 메시지 과거 메시지 조회 성공: \(messages.count)개")
            
            let updatedMessages = messages.map {
                var message = $0
                if let member = members?.first(where: { $0.userId == message.userId }) {
                    message.nickname = member.nickname
                    message.profileImage = member.profileImage
                }
                return message
            }
            
            return Observable.concat([
                Observable.just(Mutation.updateMessages(updatedMessages)),
                Observable.just(.setIsDBMessageEmpty(self.MESSAGE_LIMIT_COUNT > messages.count))
            ])
        }
        .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated)) // 높은 우선순위 작업 실행 스레드
        .observe(on: MainScheduler.instance) // 결과 수신
    }
    
    private func getMessagesFromServer() -> Observable<Mutation> {
        return networkManager.getChatHistory(
            id: chatRoomId,
            lastMessageId: currentState.messages.last?.id,
            size: MESSAGE_LIMIT_COUNT
        )
        .asObservable()
        .flatMap { models -> Observable<Mutation> in
            self.logger.debug(
                """
                \(models.message ?? "서버로부터 받은 메시지가 없습니다.")\n
                서버로부터 메시지 과거 메시지 조회 성공: \(models.data.count)개
                """
            )
            
            self.databaseManager.insertMessages(models.data)
            
            return Observable.concat([
                Observable.just(.updateMessages(models.data)),
                Observable.just(.setIsServerMessageEmpty(self.MESSAGE_LIMIT_COUNT > models.data.count))
            ])
        }
        .catch { error in
            self.logger.critical("채팅방 메시지 불러오기 실패: \(error.localizedDescription)")
            
            return Observable.empty()
        }
    }
    
    private func sendMessage(message: String) {
        if !message.isEmpty {
            webSocketManager.sendMessage(message: message)
        }
    }
    
    private func sendImage(image: UIImage) -> Observable<Mutation> {
        if let imageData = image.jpegData(compressionQuality: 0.3) {
            return networkManager.uploadChatImage(id: chatRoomId, message: nil, image: imageData)
                .asObservable()
                .flatMap { _ -> Observable<Mutation> in
                    self.logger.debug("이미지 보내기 성공")
                    
                    return Observable.just(.setBottomOpenMenu(false))
                }
                .catch { error in
                    self.logger.critical("채팅 이미지 보내기 실패: \(error.localizedDescription)")
                    
                    return Observable.concat([
                        Observable.just(.setError(String(localized: "ErrorSendImage", table: "Chat"))),
                        Observable.just(.setBottomOpenMenu(false))
                    ])
                }
        } else {
            return Observable.just(.setError(String(localized: "ErrorSendImage", table: "Chat")))
        }
    }
    
    private func leaveChatRoom() -> Observable<Mutation> {
        databaseManager.deleteMessages(roomId: chatRoomId)
        
        return Observable.just(.setShouldNavigateToBack)
    }
}
