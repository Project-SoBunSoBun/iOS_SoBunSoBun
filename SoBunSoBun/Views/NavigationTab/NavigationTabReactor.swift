//
//  NavigationTabReactor.swift
//  SoBunSoBun
//
//  Created by 김태은 on 10/22/25.
//

import ReactorKit
import RxSwift

class NavigationTabReactor: Reactor {
    let initialState = State()
    
    enum Action {
        case selectIndex(Int)
    }
    
    enum Mutation {
        case setSelectedIndex(Int)
    }
    
    struct State {
        var selectedIndex: Int = 0
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .selectIndex(let index):
            return .just(.setSelectedIndex(index))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setSelectedIndex(let index):
            newState.selectedIndex = index
        }
        
        return newState
    }
}
