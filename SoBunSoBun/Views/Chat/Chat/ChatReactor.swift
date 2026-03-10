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
        case getMoreMessages // 과거 채팅 더 불러오기
        case sendMessage(String) // 텍스트 전송
        case rightMenuButtonTapped // 오른쪽 메뉴 버튼 누름
        case bottomMenuTapped // 하단 메뉴 버튼 누름
        case backToKeyboard // 키보드로 바꾸기
        case showImagePicker // 이미지 피커 표시
        case sendImage(UIImage) // 이미지 전송
        case chatLongPressed(Bool) // 텍스트 채팅을 길게 눌렀을 때
        case setSelectedChatMessageModel(ChatMessageModel) // 선택(상호작용)한 채팅
        case sendInviteCard // 그룹 채팅방 초대장 전송(개인 채팅 전용)
        case acceptGroupChatRoom(Int) // 그룹 채팅방 초대 수락(개인 채팅 전용)
        case sendSettlementCard(Int) // 정산서 보내기
        case leaveChatRoom // 채팅방 나가기
    }
    
    enum Mutation {
        case setDetailInfo(ChatRoomDetailModel) // 채팅방 상세 정보 설정
        case updateMessages([ChatMessageModel]) // 메시지 데이터 업데이트
        case addNewMessage(ChatMessageModel) // 메시지 추가
        case setIsServerMessageEmpty(Bool) // 서버의 과거 메시지가 캐싱된 메시지보다 부족할 때
        case setIsDBMessageEmpty(Bool) // 캐싱된 메시지가 없을 때
        case setShouldNavigateToRightMenu // 오른쪽 메뉴 뷰 이동
        case setBottomOpenMenu(Bool) // 하단 메뉴 표시
        case setIsChatCellMenuOpen(Bool) // 채팅 상호작용 메뉴 표시
        case setSelectedChatMessageModel(ChatMessageModel) // 선택(상호작용)할 채팅 설정
        case setShouldShowImagePicker // 이미지 피커 표시
        case setShouldNavigateToGroupChat(Int) // 그룹 채팅방 이동(개인 채팅 전용)
        case setError(String) // 오류
        case setCriticalError(String) // 심각한 오류
        case setShouldNavigateToBack // 채팅방 나가기
    }
    
    struct State {
        var detailInfoModel: ChatRoomDetailModel?
        var messages: [ChatMessageModel] = []
        var isServerMessageEmpty: Bool = false
        var isDBMessageEmpty: Bool = false
        var isOpenBottomMenu: Bool = false
        var isChatCellMenuOpen: Bool = false
        var selectedChatMessageModel: ChatMessageModel?
        @Pulse var shouldNavigateToRightMenu: Void?
        @Pulse var shouldShowIamgePicker: Void?
        @Pulse var shouldNavigateToGroupChatRoom: Int?
        @Pulse var shouldNavigateToBack: Void?
        @Pulse var errorMessage: String?
        @Pulse var criticalErrorMessage: String?
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
            
        case .rightMenuButtonTapped:
            return Observable.just(.setShouldNavigateToRightMenu)
            
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
            
        case .sendInviteCard:
            return sendInviteCard()
            
        case .acceptGroupChatRoom(let id):
            return acceptInvitationGroupChatRoom(inviteId: id)
            
        case .sendSettlementCard(let id):
            return sendSettlementCard(settlementId: id)
            
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
            
        case .setShouldNavigateToRightMenu:
            newState.shouldNavigateToRightMenu = ()
            
        case .setBottomOpenMenu(let isOpen):
            newState.isOpenBottomMenu = isOpen
            
        case .setShouldShowImagePicker:
            newState.shouldShowIamgePicker = ()
            
        case .setIsChatCellMenuOpen(let isMenuOpen):
            newState.isChatCellMenuOpen = isMenuOpen
            
        case .setSelectedChatMessageModel(let model):
            newState.selectedChatMessageModel = model
            
        case .setShouldNavigateToGroupChat(let id):
            newState.shouldNavigateToGroupChatRoom = id
            
        case .setShouldNavigateToBack:
            newState.shouldNavigateToBack = ()
        
        case .setError(let message):
            newState.errorMessage = message
            
        case .setCriticalError(let message):
            newState.criticalErrorMessage = message
        }
        
        return newState
    }
    
    // webSocketManager publish mutation 연결 및 변환
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        let didReceiveMessage = webSocketManager.didReceiveMessage
            .do {
                self.databaseManager.insertMessage($0)
            }
            .map { Mutation.addNewMessage($0) }
        
        let didReceiveSettlement = webSocketManager.didReceiveSettlement
            .compactMap { $0 }
            .flatMap { _ -> Observable<Mutation> in
                return self.getDetailInfo()
            }
        
        return Observable.merge(mutation, didReceiveMessage, didReceiveSettlement)
    }
    
    // websocket 연결
    private func connectWebSocket() {
        webSocketManager.connect(chatRoomId: chatRoomId)
    }
    
    // 채팅방 상세 정보 불러오기
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
    
    // 메시지 불러오기
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
    
    // 캐싱된 메시지 불러오기
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
    
    // 서버에서 메시지 불러오기
    private func getMessagesFromServer() -> Observable<Mutation> {
        return networkManager.getChatHistory(
            id: chatRoomId,
            cursor: currentState.messages.last?.createdAt,
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
    
    // 메시지 전송
    private func sendMessage(message: String) {
        let cleanedMessage = message.limitNewLines(limit: 2).trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !cleanedMessage.isEmpty else {
            return
        }
        
        webSocketManager.sendMessage(message: message)
    }
    
    // 이미지 전송
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
    
    // 그룹 채팅방 초대장 전송
    private func sendInviteCard() -> Observable<Mutation> {
        guard let myIdString = KeyChain.shared.get(key: "USER_ID"),
              let myId = Int(myIdString),
              let inviteeId: Int = currentState.detailInfoModel?.data.members.first(where: { $0.userId != myId })?.userId else {
            return Observable.just(.setError(String(localized: "ErrorMessage", table: "Common")))
        }
        
        return networkManager.sendInviteCard(chatRoomId: chatRoomId, inviteeId: inviteeId)
            .asObservable()
            .flatMap { _ -> Observable<Mutation> in
                self.logger.debug("초대장 전송 성공")
                
                return Observable.empty()
            }
            .catch { error in
                self.logger.critical("초대장 전송 실패: \(error.localizedDescription)")
                
                return Observable.just(.setError(String(localized: "ErrorSendInviteCardMessage", table: "Chat")))
            }
    }
    
    // 그룹 채팅방 초대 수락
    private func acceptInvitationGroupChatRoom(inviteId: Int) -> Observable<Mutation> {
        return networkManager.acceptInvitation(inviteId: inviteId)
            .asObservable()
            .flatMap { model -> Observable<Mutation> in
                self.logger.debug("초대장 수락 성공")
                
                return Observable.just(.setShouldNavigateToGroupChat(model.data.chatRoomId))
            }
            .catch { error in
                self.logger.critical("초대장 수락 실패: \(error.localizedDescription)")
                
                return Observable.just(.setError(String(localized: "ErrorAcceptGroupChatRoomMessage", table: "Chat")))
            }
    }
    
    // 정산서 보내기
    private func sendSettlementCard(settlementId: Int) -> Observable<Mutation> {
        return networkManager.sendSettlementCard(chatRoomId: chatRoomId, settlementId: settlementId)
            .asObservable()
            .flatMap { _ -> Observable<Mutation> in
                self.logger.debug("정산서 전송 성공")
                
                return Observable.empty()
            }
            .catch { error in
                self.logger.critical("정산서 전송 실패: \(error.localizedDescription)")
                
                return Observable.just(.setError(String(localized: "ErrorSendSettlementCardMessage", table: "Chat")))
            }
    }
    
    // 채팅방 나가기
    private func leaveChatRoom() -> Observable<Mutation> {
        return networkManager.leaveChatRoom(id: chatRoomId)
            .asObservable()
            .flatMap { _ -> Observable<Mutation> in
                self.logger.debug("채팅방 나가기 성공")
                
                self.databaseManager.deleteMessages(roomId: self.chatRoomId)
                return Observable.just(.setShouldNavigateToBack)
            }
            .catch { error in
                self.logger.critical("채팅방 나가기 실패: \(error.localizedDescription)")
                
                return Observable.just(.setError(String(localized: "ErrorMessage", table: "Common")))
            }
    }
}
