//
//  NotificationSettingReactor.swift
//  SoBunSoBun
//
//  Created by 허성필 on 2/18/26.
//

import ReactorKit
import RxSwift
import OSLog

class NotificationSettingReactor: Reactor {
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "Settings.NotificationSetting.Reactor"
    )
    
    let initialState = State()
    
    enum Action {
        case notificationSettingTapped
    }
    
    enum Mutation {
        case setOpenSettings
    }
    
    struct State {
        @Pulse var shouldOpenSettings: Void?
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .notificationSettingTapped:
            return Observable.just(.setOpenSettings)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setOpenSettings:
            newState.shouldOpenSettings = ()
        }
        
        return newState
    }
}
