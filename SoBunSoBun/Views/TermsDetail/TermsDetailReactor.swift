//
//  TermsReactor.swift
//  SoBunSoBun
//
//  Created by 허성필 on 3/20/26.
//

import ReactorKit
import OSLog

class TermsDetailReactor: Reactor {
    let initialState: State
    
    init(termsType: String) {
        self.initialState = State(termsType: termsType)
    }
    
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "TermsDetail.Reactor"
    )
    
    private let networkManager = SettingNetworkManager()
    
    enum Action {
        case viewDidLoad
    }
    
    enum Mutation {
        case setContent(String)
        case setError(String)
    }
    
    struct State {
        var termsType: String
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
        let request: Single<TermsResponseModel>
        let errorLogMessage: String
        let errorKey: String
        
        switch currentState.termsType {
        case "service":
            request = networkManager.getTermsService()
            errorLogMessage = "서비스 이용약관 조회 실패"
            errorKey = "FailToLoadServiceTerm"
            
        case "privacy":
            request = networkManager.getTermsPrivacy()
            errorLogMessage = "개인정보처리방침 조회 실패"
            errorKey = "FailToLoadPrivacyTerm"
            
        case "location":
            request = networkManager.getTermsLocation()
            errorLogMessage = "위치기반서비스 이용약관 조회 실패"
            errorKey = "FailToLoadLocationTerm"
            
        default:
            return Observable.empty()
        }
        
        return request
            .asObservable()
            .flatMap { model -> Observable<Mutation> in
                return Observable.just(.setContent(model.data.content))
            }
            .catch { [weak self] error in
                guard let self = self else { return Observable.empty() }
                
                self.logger.critical("\(errorLogMessage): \(error.localizedDescription)")
                return Observable.just(.setError(String(localized: String.LocalizationValue(errorKey), table: "Settings")))
            }
    }
}
