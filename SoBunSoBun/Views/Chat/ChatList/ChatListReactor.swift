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
    }
    
    enum Mutation {
        
    }
    
    struct State {
        
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return Observable.empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
            
        }
        
        return newState
    }
}
