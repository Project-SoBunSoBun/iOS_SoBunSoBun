//
//  AppSettingReactor.swift
//  SoBunHaeYo
//
//  Created by 허성필 on 1/28/26.
//

import ReactorKit
import RxSwift
import OSLog

class AppSettingReactor: Reactor {
    private let logger = Logger(
        subsystem: "SoBunHaeYo",
        category: "Settings.AppSetting.Reactor"
    )
    
    let initialState = State()
    
    enum ViewType {
        case notificationSetting
        case managingAccountInfo
        case announcement
        case customerSupport
        case terms
    }
    
    enum Action {
        case notificationSettingTapped
        case managingAccountInfoTapped
        case announcementTapped
        case customerSupportTapped
        case termsTapped
    }
    
    enum Mutation {
        case setNavigate(ViewType)
    }
    
    struct State {
        @Pulse var shouldNavigate: ViewType? = nil
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
            
        case .notificationSettingTapped:
            return Observable.just(.setNavigate(.notificationSetting))
            
        case .managingAccountInfoTapped:
            return Observable.just(.setNavigate(.managingAccountInfo))
            
        case .announcementTapped:
            return Observable.just(.setNavigate(.announcement))
            
        case .customerSupportTapped:
            return Observable.just(.setNavigate(.customerSupport))
            
        case .termsTapped:
            return Observable.just(.setNavigate(.terms))
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
