//
//  ChatRightMenuReactor.swift
//  SoBunHaeYo
//
//  Created by 김태은 on 2/16/26.
//

import Foundation
import ReactorKit
import RxSwift
import OSLog

class ChatRightMenuReactor: Reactor {
    var initialState: State = State()
    
    private let chatRoomId: Int
    
    init(chatRoomId: Int) {
        self.chatRoomId = chatRoomId
    }
    
    private let logger = Logger(
        subsystem: "SoBunHaeYo",
        category: "Chat.RightMenu.Reactor"
    )
    
    private let disposeBag = DisposeBag()
    
    enum Action {
        case setMembers([ChatRoomDetailMemberModel])
        case postDetailCardTapped
        case kickCardTapped
        case profileTapped(Int)
        case leaveChatRoomTapped
    }
    
    enum Mutation {
        case setMembers([ChatRoomDetailMemberModel])
        case setShouldNavigateToPostDetail
        case setShouldNavigateToKick
        case setShouldShowProfile(Int)
        case setShowShouldLeaveChatRoomAlert
    }
    
    struct State {
        var members: [ChatRoomDetailMemberModel] = []
        @Pulse var shouldNavigateToPostDetailId: Void?
        @Pulse var shouldNavigateToKick: Void?
        @Pulse var shouldShowProfile: Int?
        @Pulse var shouldShowLeaveChatRoomAlert: Void?
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .setMembers(let members):
            return Observable.just(.setMembers(members))
            
        case .postDetailCardTapped:
            return Observable.just(.setShouldNavigateToPostDetail)
            
        case .kickCardTapped:
            return Observable.just(.setShouldNavigateToKick)
            
        case .profileTapped(let id):
            return Observable.just(.setShouldShowProfile(id))
            
        case .leaveChatRoomTapped:
            return Observable.just(.setShowShouldLeaveChatRoomAlert)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setMembers(let members):
            newState.members = members
            
        case .setShouldNavigateToPostDetail:
            newState.shouldNavigateToPostDetailId = ()
            
        case .setShouldNavigateToKick:
            newState.shouldNavigateToKick = ()
            
        case .setShouldShowProfile(let id):
            newState.shouldShowProfile = id
            
        case .setShowShouldLeaveChatRoomAlert:
            newState.shouldShowLeaveChatRoomAlert = ()
        }
        
        return newState
    }
}
