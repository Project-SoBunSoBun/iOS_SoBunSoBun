//
//  PrivacyTermReactor.swift
//  SoBunSoBun
//
//  Created by 허성필 on 10/23/25.
//

import UIKit
import ReactorKit
import OSLog

class PrivacyTermReactor: Reactor {
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "PrivacyTerm.Reactor"
    )
    
    let initialState = State()
    
    private let networkManager = SettingNetworkManager()
    
    enum Action {
        case viewDidLoad
    }
    
    enum Mutation {
        case setContent(String)
        case setError(String)
    }
    
    struct State {
        var content: String = ""
        @Pulse var errorMessage: String?
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            loadTerms()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setContent(let content):
            newState.content = content
            
        case .setError(let message):
            newState.errorMessage = message
        }
        return newState
    }
    
    private func loadTerms() -> Observable<Mutation> {
        return networkManager.getTermsPrivacy()
            .asObservable()
            .flatMap { model -> Observable<Mutation> in
                return Observable.just(.setContent(model.data.content))
            }
            .catch { [weak self] error in
                guard let self = self else { return Observable.empty() }
                
                self.logger.critical("개인정보처리 방침 조회 실패: \(error.localizedDescription)")
                
                return Observable.just(.setError(String(localized: "FailToLoadPrivacyTerm", table: "Settings")))
            }
    }
}
