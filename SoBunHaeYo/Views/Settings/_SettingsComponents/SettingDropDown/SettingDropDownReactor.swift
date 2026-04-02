//
//  SettingDropDownReactor.swift
//  SoBunHaeYo
//
//  Created by 허성필 on 2/11/26.
//

import Foundation
import ReactorKit

class SettingDropDownReactor: Reactor {
    let initialState: State = State()
    
    enum Action {
        case buttonTapped(Bool)
        case selectCell(String)
    }
    
    enum Mutation {
        case setIsOpen(Bool)
        case setSelected(String)
    }
    
    struct State {
        var isOpen: Bool = false
        @Pulse var selectedCell: String?
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .buttonTapped(let isOpen):
            return Observable.just(.setIsOpen(isOpen))
            
        case .selectCell(let title):
            return Observable.concat([
                Observable.just(.setSelected(title)),
                Observable.just(.setIsOpen(false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setIsOpen(let isOpen):
            newState.isOpen = isOpen
            
        case .setSelected(let title):
            newState.selectedCell = title
        }
        
        return newState
    }
}
