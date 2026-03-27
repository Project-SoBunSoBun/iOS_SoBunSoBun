//
//  ChatRoomKickReactor.swift
//  SoBunHaeYo
//
//  Created by 김태은 on 2/16/26.
//

import Foundation
import ReactorKit
import OSLog

class ChatRoomKickReactor: Reactor {
    private let chatRoomId: Int
    
    init(chatRoomId: Int) {
        self.chatRoomId = chatRoomId
    }
    
    private let logger = Logger(
        subsystem: "SoBunHaeYo",
        category: "Chat.ChatRoomKick.Reactor"
    )
    
    var initialState: State = State()
    
    private let networkManager = ChatNetworkManager()
    private let disposeBag = DisposeBag()
    
    enum Action {
        case setMembers([ChatRoomDetailMemberModel])
        case kickButtonTapped(Int)
        case kickAccepted
    }
    
    enum Mutation {
        case setMembers([ChatRoomDetailMemberModel])
        case setSelectedMemberId(Int)
        case setShouldShowKickAlert
        case changeMembers(Int)
        case setShouldShowKickDoneAlert
        case setError(String)
    }
    
    struct State {
        var members: [ChatRoomDetailMemberModel] = []
        var selectedMemberId: Int?
        @Pulse var shouldShowKickAlert: Void?
        @Pulse var shouldShowKickDoneAlert: Void?
        @Pulse var errorMessage: String?
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .setMembers(let members):
            return Observable.just(.setMembers(members))
            
        case .kickButtonTapped(let id):
            return Observable.concat([
                Observable.just(.setSelectedMemberId(id)),
                Observable.just(.setShouldShowKickAlert)
            ])
            
        case .kickAccepted:
            guard let selectedMemberId = currentState.selectedMemberId else {
                return Observable.empty()
            }
            
            return kickMember(id: selectedMemberId)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setMembers(let members):
            if let myIdString = KeyChain.shared.get(key: "USER_ID"),
               let myId = Int(myIdString) {
                newState.members = members.filter { $0.userId != myId }
            }
            
        case .setSelectedMemberId(let id):
            newState.selectedMemberId = id
            
        case .changeMembers(let id):
            newState.members = newState.members.filter { $0.userId != id }
            
        case .setShouldShowKickAlert:
            newState.shouldShowKickAlert = ()
            
        case .setShouldShowKickDoneAlert:
            newState.shouldShowKickDoneAlert = ()
            
        case .setError(let message):
            newState.errorMessage = message
        }
        
        return newState
    }
    
    private func kickMember(id: Int) -> Observable<Mutation> {
        return networkManager.kickMember(chatRoomId: chatRoomId, userId: id)
            .asObservable()
            .flatMap { _ -> Observable<Mutation> in
                self.logger.debug("멤버 강퇴 성공")
                
                return Observable.concat([
                    Observable.just(.changeMembers(id)),
                    Observable.just(.setShouldShowKickDoneAlert)
                ])
            }
            .catch { error in
                self.logger.critical("멤버 강퇴 실패: \(error.localizedDescription)")
                
                return Observable.just(.setError(String(localized: "ErrorMessage", table: "Error")))
            }
    }
}
