//
//  SignUpCompletedReactor.swift
//  SoBunSoBun
//
//  Created by 허성필 on 11/6/25.
//

import UIKit
import ReactorKit

class SignUpCompletedReactor: Reactor {
    let initialState = State()
    
    private let commonNetworkManager = CommonNetworkManager()
    
    enum Action {
        case viewDidLoad
        case closeButtonTapped
        case startButtonTapped
    }
    
    enum Mutation {
        case setNickname(String)
        case setLoading(Bool)
        case setError(String)
        case setNavigateToHome
    }
    
    struct State {
        var nickname: String = ""
        var isLoading: Bool = false
        @Pulse var errorMessage: String?
        @Pulse var shouldNavigateToHome: Void?
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action { 
        case .viewDidLoad:
            return fetchUserProfile()
            
        case .closeButtonTapped, .startButtonTapped:
            return Observable.just(.setNavigateToHome)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setNickname(let nickname):
            newState.nickname = nickname
            
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
            
        case .setError(let message):
            newState.errorMessage = message
            
        case .setNavigateToHome:
            newState.shouldNavigateToHome = ()
        }
        return newState
    }
    
    private func fetchUserProfile() -> Observable<Mutation> {
        return Observable.concat([
            Observable.just(.setLoading(true)),
            
            commonNetworkManager.myProfile()
                .asObservable()
                .flatMap { userInfo -> Observable<Mutation> in
                    Observable.just(.setNickname(userInfo.nickname ?? "Error"))
                }
                .catch { error in
                    return Observable.just(.setError(error.localizedDescription))
                },
            Observable.just(.setLoading(false))
        ])
    }
}
