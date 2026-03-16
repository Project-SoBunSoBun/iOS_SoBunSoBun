//
//  ChatRoomListReactor.swift
//  SoBunSoBun
//
//  Created by 김태은 on 2/10/26.
//

import Foundation
import ReactorKit
import RxSwift
import OSLog

class ChatRoomListReactor: Reactor {
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "Chat.ChatList.Reactor"
    )
    
    private let disposeBag = DisposeBag()
    
    let initialState: State = State()
    
    enum Action {
        case tabButtonTapped(Int)
        case receivedChatRoomList([ChatRoomListResponseDataModel])
        case chatRoomTapped(ChatRoomListResponseDataModel)
    }
    
    enum Mutation {
        case setTabIndex(Int)
        case setChatRoomList([ChatRoomListResponseDataModel])
        case setShouldPushChatView(ChatRoomListResponseDataModel)
    }
    
    struct State {
        var tabIndex: Int = 0
        var privateChatRoomList: [ChatRoomListResponseDataModel] = []
        var groupChatRoomList: [ChatRoomListResponseDataModel] = []
        @Pulse var shouldPushChatView: ChatRoomListResponseDataModel?
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .tabButtonTapped(let index):
            return Observable.just(.setTabIndex(index))
            
        case .receivedChatRoomList(let models):
            return Observable.just(.setChatRoomList(models))
            
        case .chatRoomTapped(let model):
            return Observable.just(.setShouldPushChatView(model))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setTabIndex(let index):
            newState.tabIndex = index
            
        case .setChatRoomList(let models):
            newState.privateChatRoomList = models.filter { $0.roomType == .ONE_TO_ONE }
            newState.groupChatRoomList = models.filter { $0.roomType == .GROUP }
            
        case .setShouldPushChatView(let model):
            newState.shouldPushChatView = model
        }
        
        return newState
    }
}
