//
//  SettleUp2ndStepReactor.swift
//  SoBunSoBun
//
//  Created by 허성필 on 1/12/26.
//

import ReactorKit

class SettleUp2ndStepReactor: Reactor {
    let initialState = State()
    
    enum Action {
        case backButtonTapped // 뒤로가기 버튼 클릭
    }
    
    enum Mutation {
        case setBackButtonTapped
    }
    
    struct State {
        @Pulse var shouldPopViewController: Void?
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
            
        case .backButtonTapped:
            return Observable.just(.setBackButtonTapped)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
            
        case .setBackButtonTapped:
            newState.shouldPopViewController = ()
        }
        
        return newState
    }
}
