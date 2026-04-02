//
//  CustomAlertViewReactor.swift
//  SoBunHaeYo
//
//  Created by 허성필 on 11/11/25.
//

import UIKit
import ReactorKit


class CustomAlertViewReactor: Reactor {
    let initialState = State()
    private let disposeBag = DisposeBag()
    
    enum Action {
        case settingButtonTapped
        case cancelButtonTapped
    }
    
    enum Mutation {
        case setOpenSettings
        case setDismiss
    }
    
    struct State {
        @Pulse var shouldOpenSettings: Void?
        @Pulse var shouldDismiss: Void?
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .settingButtonTapped:
            return Observable.just(.setOpenSettings)
        case .cancelButtonTapped:
            return Observable.just(.setDismiss)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setOpenSettings:
            newState.shouldOpenSettings = ()
        case .setDismiss:
            newState.shouldDismiss = ()
        }
        return newState
    }
}
