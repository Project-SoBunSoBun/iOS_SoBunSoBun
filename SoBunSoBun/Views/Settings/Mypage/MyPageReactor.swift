//
//  MyPageReactor.swift
//  SoBunSoBun
//
//  Created by 허성필 on 1/24/26.
//

import ReactorKit
import RxSwift
import OSLog

class MyPageReactor: Reactor {
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "MyPage.Reactor"
    )
    
    let initialState = State()
    
    private let disposeBag = DisposeBag()
    
    enum Action {
        case viewDidLoad
    }
    
    enum Mutation {
        case setProfile(MyProfileModel)
        case setLoading(Bool)
        case setError(String)
    }
    
    struct State {
        var profile: MyProfileModel?
        var isLoading: Bool = false
        var errorMessage: String?
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
            
        case .viewDidLoad:
            return Observable.concat([
                Observable.just(.setLoading(true)),
                NetworkManager.shared.getMeProfile()
                    .asObservable()
                    .flatMap { profile -> Observable<Mutation> in
                        return Observable.just(.setProfile(profile))
                    }
                    .catch { error in
                        self.logger.error("getMeProfile 실패: \(error.localizedDescription)")
                        return Observable.just(.setError(error.localizedDescription))
                    },
                Observable.just(.setLoading(false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
            
        case .setProfile(let profile):
            newState.profile = profile
            newState.errorMessage = nil
            
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
            
        case .setError(let message):
            newState.errorMessage = message
        }
        
        return newState
    }
}
