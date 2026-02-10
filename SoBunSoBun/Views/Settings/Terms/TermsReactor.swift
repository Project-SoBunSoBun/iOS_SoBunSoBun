//
//  TermsReactor.swift
//  SoBunSoBun
//
//  Created by 허성필 on 2/6/26.
//

import ReactorKit
import OSLog

class TermsReactor: Reactor {
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "Mypage.Terms.Reactor"
    )
    
    let initialState = State()
    
    enum ViewType {
        case serviceTerm
        case privacyPolicy
    }
    
    enum Action {
        case serviceTermTapped
        case privacyPolicyTapped
    }
    
    enum Mutation {
        case setNavigate(ViewType)
    }
    
    struct State {
        @Pulse var shouldNavigate: ViewType? = nil
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
            
        case .serviceTermTapped:
            return Observable.just(.setNavigate(.serviceTerm))
            
        case .privacyPolicyTapped:
            return Observable.just(.setNavigate(.privacyPolicy))
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
