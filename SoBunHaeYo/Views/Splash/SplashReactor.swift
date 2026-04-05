//
//  SplashReactor.swift
//  SoBunHaeYo
//
//  Created by 허성필 on 9/4/25.
//

import Foundation
import ReactorKit
import RxSwift

class SplashReactor: Reactor {
    enum Destination {
        case main
        case login
    }
    
    enum Action {
        case viewDidAppear
    }
    
    enum Mutation {
        case setDestination(Destination)
    }
    
    struct State {
        @Pulse var destination: Destination?
    }
    
    let initialState = State()
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidAppear:
            return checkAuthentication()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setDestination(let destination):
            newState.destination = destination
        }
        
        return newState
    }
    
    private func checkAuthentication() -> Observable<Mutation> {
        let now = Date()
        
        if KeyChain.shared.get(key: "REFRESH_TOKEN") != nil,
           let refreshTokenExpireAtKST = KeyChain.shared.get(key: "REFRESH_TOKEN_EXPIRE_AT_KST"),
           let dateRefreshTokenExpireAtKST = ISO8601ToDate(refreshTokenExpireAtKST),
           dateRefreshTokenExpireAtKST > now {
            return Observable.just(.setDestination(.main))
        } else {
            return Observable.just(.setDestination(.login))
        }
    }
}
