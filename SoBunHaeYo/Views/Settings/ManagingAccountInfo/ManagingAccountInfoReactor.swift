//
//  ManagingAccountInfoReactor.swift
//  SoBunHaeYo
//
//  Created by 허성필 on 1/29/26.
//

import ReactorKit
import RxSwift
import OSLog

class ManagingAccountInfoReactor: Reactor {
    private let logger = Logger(
        subsystem: "SoBunHaeYo",
        category: "Settings.ManagingAccountInfo.Reactor"
    )
    
    let initialState = State()
    
    private let disposeBag = DisposeBag()
    
    enum ViewType {
        case logOut
        case deleteAccount
    }
    
    enum Action {
        case logOutTapped
        case deleteAccountTapped
    }
    
    enum Mutation {
        case setNavigate(ViewType)
    }
    
    struct State {
        @Pulse var shouldNavigate: ViewType? = nil
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
            
        case .logOutTapped:
            return Observable.just(.setNavigate(.logOut))
            
        case .deleteAccountTapped:
            return Observable.just(.setNavigate(.deleteAccount))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
            
        case .setNavigate(let viewType):
            newState.shouldNavigate = viewType
        }
        
        return newState
    }
}
