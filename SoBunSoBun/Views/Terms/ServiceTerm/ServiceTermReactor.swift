//
//  ServiceTermReactor.swift
//  SoBunSoBun
//
//  Created by 허성필 on 10/23/25.
//

import UIKit
import ReactorKit
import OSLog

class ServiceTermReactor: Reactor {
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "ServiceTerm.Reactor"
    )
    
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
