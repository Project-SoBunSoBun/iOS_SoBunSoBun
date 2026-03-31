//
//  SettleUp3rdStepReactor.swift
//  SoBunHaeYo
//
//  Created by 허성필 on 3/11/26.
//

import ReactorKit
import RxSwift
import OSLog

class SettleUp3rdStepReactor: Reactor {
    let initialState: State
    
    init(model: SettleUp3rdStepDataModel, authorId: Int) {
        self.initialState = State(model: model, authorId: authorId)
    }
    
    private let logger = Logger(
        subsystem: "SoBunHaeYo",
        category: "SettleUp.SettleUp3rdStep.Reactor"
    )
    
    private let networkManager = SettleUpNetworkManager()
    private let disposeBag = DisposeBag()
    
    enum Action {
        case saveButtonTapped
        case alertButtonTapped
    }
    
    enum Mutation {
        case setLoading(Bool)
        case setShouldShowSaveAlert
        case setNavigateToSettleUpView
        case setErrorMessage(String)
    }
    
    struct State {
        let model: SettleUp3rdStepDataModel
        let authorId: Int
        
        var sortedParticipants: [SettleUp3rdStepParticipantModel] {
            model.participants.sorted { lhs, rhs in
                let lhsIsAuthor = lhs.userId == authorId
                let rhsIsAuthor = rhs.userId == authorId
                
                if lhsIsAuthor != rhsIsAuthor {
                    return lhsIsAuthor
                }
                
                return false
            }
        }
        var isLoading: Bool = false
        
        @Pulse var shouldShowSaveAlert: Void? = nil
        @Pulse var shouldNavigateToSettleUpView: Void? = nil
        @Pulse var errorMessage: String? = nil
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .saveButtonTapped:
            return Observable.just(.setShouldShowSaveAlert)
            
        case .alertButtonTapped:
            return putSettlementComplete(model: currentState.model)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
            
        case .setShouldShowSaveAlert:
            newState.shouldShowSaveAlert = ()
            
        case .setNavigateToSettleUpView:
            newState.shouldNavigateToSettleUpView = ()
            
        case .setErrorMessage(let message):
            newState.errorMessage = message
        }
        
        return newState
    }
    
    private func putSettlementComplete(model: SettleUp3rdStepDataModel) -> Observable<Mutation> {
        return Observable.deferred {
            Observable.concat([
                Observable.just(.setLoading(true)),
                self.networkManager.putSettlementComplete(model: model)
                    .asObservable()
                    .flatMap { [weak self] response -> Observable<Mutation> in
                        guard let self = self else { return Observable.empty() }
                        
                        if response.success {
                            self.logger.debug("정산 등록 성공")
                            
                            return Observable.just(.setNavigateToSettleUpView)
                        } else {
                            if let errorCode = response.errorCode {
                                self.logger.critical("정산 등록 실패(\(errorCode)) - \(response.message ?? "")")
                                
                                return Observable.just(.setErrorMessage(localizedErrorMessage(errorCode)))
                            } else {
                                self.logger.critical("정산 등록 실패: \(response.message ?? "")")
                                
                                return Observable.just(.setErrorMessage(localizedErrorMessage(nil)))
                            }
                        }
                    }
                    .catch { [weak self] error in
                        guard let self = self else { return Observable.empty() }
                        
                        self.logger.error("정산 등록 실패: \(error.localizedDescription)")
                        
                        return Observable.just(.setErrorMessage(String(format: String(localized: "ErrorMessageWithReason", table: "Error"), error.localizedDescription)))
                    },
                Observable.just(.setLoading(false))
            ])
        }
    }
}
