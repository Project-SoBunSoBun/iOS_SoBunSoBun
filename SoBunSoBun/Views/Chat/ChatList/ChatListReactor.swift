//
//  ChatListReactor.swift
//  SoBunSoBun
//
//  Created by 김태은 on 2/10/26.
//

import Foundation
import ReactorKit
import RxSwift
import OSLog

class ChatListReactor: Reactor {
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "Chat.ChatList.Reactor"
    )
    
    private let disposeBag = DisposeBag()
    
    let initialState: State = State()
    
    enum Action {
        case viewDidLoad
        case tabButtonTapped(Int)
    }
    
    enum Mutation {
        case setTabIndex(Int)
    }
    
    struct State {
        var tabIndex: Int = 0
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return Observable.empty()
            
        case .tabButtonTapped(let index):
            return Observable.just(.setTabIndex(index))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setTabIndex(let index):
            newState.tabIndex = index
        }
        
        return newState
    }
}
