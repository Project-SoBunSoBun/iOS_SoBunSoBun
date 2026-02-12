//
//  CustomerSupportReactor.swift
//  SoBunSoBun
//
//  Created by 허성필 on 2/6/26.
//

import ReactorKit
import RxSwift
import OSLog

class CustomerSupportReactor: Reactor {
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "Settings.CustomerSupport.Reactor"
    )
    
    let initialState = State()
    
    enum ViewType {
        case bugReport
        case supportInquiries
    }
    
    enum Action {
        case supportBugTapped
        case supportInquiriesTapped
    }
    
    enum Mutation {
        case setNavigate(ViewType)
    }
    
    struct State {
        @Pulse var shouldNavigate: ViewType? = nil
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
            
        case .supportBugTapped:
            return Observable.just(.setNavigate(.bugReport))
            
        case .supportInquiriesTapped:
            return Observable.just(.setNavigate(.supportInquiries))
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
