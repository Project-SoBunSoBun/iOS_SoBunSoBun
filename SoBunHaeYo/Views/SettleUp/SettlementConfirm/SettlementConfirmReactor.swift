//
//  SettlementConfirmReactor.swift
//  SoBunHaeYo
//
//  Created by 허성필 on 3/17/26.
//

import ReactorKit
import OSLog

class SettlementConfirmReactor: Reactor {
    let initialState: State
    
    init(settlementId: Int) {
        self.initialState = State(settlementId: settlementId)
    }
    
    private let logger = Logger(
        subsystem: "SoBunHaeYo",
        category: "SettleUp.SettlementConfirm.Reactor"
    )
    
    private let settleUpNetworkManager = SettleUpNetworkManager()
    private let notificationNetworkManager = NotificationNetworkManager()
    
    enum Action {
        // 알림 읽음
        case readNotification(Int)
        
        case viewDidLoad
    }
    
    enum Mutation {
        case setItem(SettlementModel)
        case setSortedParticipants([SettlementParticipantModel])
        case setErrorMessage(String)
    }
    
    struct State {
        let settlementId: Int
        var item: SettlementModel?
        var sortedParticipants: [SettlementParticipantModel] = []
        @Pulse var errorMessage: String?
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .readNotification(let id):
            return readNotification(id: id)
            
        case .viewDidLoad:
            return loadItems(settlementId: currentState.settlementId)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setItem(let item):
            newState.item = item
            
        case .setSortedParticipants(let participants):
            newState.sortedParticipants = participants
            
        case .setErrorMessage(let message):
            newState.errorMessage = message
        }
        
        return newState
    }
    
    private func readNotification(id: Int) -> Observable<Mutation> {
        return notificationNetworkManager.readNotification(id: id)
            .asObservable()
            .flatMap{ [weak self] response -> Observable<Mutation> in
                guard let self else { return Observable.empty() }
                
                if let errorCode = response.errorCode {
                    self.logger.critical("알림 읽음 실패(\(errorCode)): \(response.message ?? "")")
                } else {
                    self.logger.debug("알림 읽음 완료")
                }
                
                return Observable.empty()
            }
            .catch { [weak self] error in
                guard let self else { return Observable.empty() }
                
                self.logger.critical("알림 읽음 실패: \(error.localizedDescription)")
                
                return Observable.empty()
            }
    }
    
    private func loadItems(settlementId: Int) -> Observable<Mutation> {
        guard let userIdString = KeyChain.shared.get(key: "USER_ID"),
              let currentUserId = Int(userIdString) else {
            return Observable.empty()
        }
        
        return Observable.deferred {
            self.settleUpNetworkManager.getSettlement(settlementId: settlementId)
                .asObservable()
                .flatMap { [weak self] response -> Observable<Mutation> in
                    guard let self else { return Observable.empty() }
                    
                    if response.success {
                        let item = response.data
                        
                        let sortedParticipants = item.participants.sorted { lhs, rhs in
                            let lhsIsCurrentUser = lhs.userId == currentUserId
                            let rhsIsCurrentUser = rhs.userId == currentUserId
                            
                            if lhsIsCurrentUser != rhsIsCurrentUser {
                                return lhsIsCurrentUser
                            }
                            
                            return false
                        }
                        
                        return Observable.concat([
                            .just(.setItem(item)),
                            .just(.setSortedParticipants(sortedParticipants))
                        ])
                    } else {
                        if let errorCode = response.errorCode {
                            self.logger.critical("정산 상세 데이터 조회 실패(\(errorCode)): \(response.message ?? "")")
                            let errorMessage = NSLocalizedString(errorCode, tableName: "Error", comment: "")
                            let fallback = String(format: String(localized: "ErrorMessageWithCode", table: "Error"), errorCode)

                            return Observable.just(.setErrorMessage(errorMessage != errorCode ? errorMessage : fallback))
                        } else {
                            self.logger.critical("정산 상세 데이터 조회 실패")
                            
                            return Observable.just(.setErrorMessage(String(localized: "ErrorMessage", table: "Error")))
                        }
                    }
                }
                .catch { [weak self] error in
                    guard let self = self else { return Observable.empty() }
                    
                    self.logger.critical("정산 상세 데이터 조회 실패: \(error.localizedDescription)")
                    
                    let errorMessage = String(format: String(localized: "ErrorMessageWithReason", table: "Error"), error.localizedDescription)

                    return Observable.just(.setErrorMessage(errorMessage))
                }
        }
    }
}
