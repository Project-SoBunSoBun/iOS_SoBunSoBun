//
//  SettleUp3rdStepReactor.swift
//  SoBunSoBun
//
//  Created by 허성필 on 3/11/26.
//

import ReactorKit

class SettleUp3rdStepReactor: Reactor {
    let initialState = State()
    
    enum Action {
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
            
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
            
        }
        
        return newState
    }
}
