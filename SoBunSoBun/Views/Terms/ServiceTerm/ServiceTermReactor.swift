//
//  ServiceTermReactor.swift
//  SoBunSoBun
//
//  Created by 허성필 on 10/23/25.
//

import UIKit
import ReactorKit
import OSLog

class ServiceTermReactor: Reactor {
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "ServiceTerm.Reactor"
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
        return networkManager.getTermsService()
            .asObservable()
            .flatMap { model -> Observable<Mutation> in
                return Observable.just(.setContent(model.data.content))
            }
            .catch { [weak self] error in
                guard let self = self else { return Observable.empty() }
                
                self.logger.critical("서비스 이용 약관 조회 실패: \(error.localizedDescription)")
                
                return Observable.just(.setError(String(localized: "FailToLoadServiceTerm", table: "Settings")))
            }
    }
}
