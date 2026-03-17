//
//  SettlementConfirmRecator.swift
//  SoBunSoBun
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
        subsystem: "SoBunSoBun",
        category: "SettleUp.SettlementConfirm.Reactor"
    )
    
    private let networkManager = SettleUpNetworkManager()
    
    enum Action {
        case viewDidLoad
    }
    
    enum Mutation {
        case setItem(SettlementModel)
        case setSortedParticipants([SettlementParticipantModel])
        case setError(String)
    }
    
    struct State {
        let settlementId: Int
        var item: SettlementModel?
        var sortedParticipants: [SettlementParticipantModel] = []
        @Pulse var errorMessage: String?
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            loadItems(settlementId: currentState.settlementId)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setItem(let item):
            newState.item = item
            
        case .setSortedParticipants(let participants):
            newState.sortedParticipants = participants
            
        case .setError(let message):
            newState.errorMessage = message
        }
        
        return newState
    }
    
    private func loadItems(settlementId: Int) -> Observable<Mutation> {
        let currentUserId = KeyChain.shared.get(key: "USER_ID").flatMap { Int($0) } ?? -1
        
        return networkManager.getSettlement(settlementId: settlementId)
            .asObservable()
            .flatMap { model -> Observable<Mutation> in
                let item = model.data
                
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
            }
            .catch { [weak self] error in
                guard let self = self else { return Observable.empty() }
                
                self.logger.critical("정산 상세 데이터 조회 실패: \(error.localizedDescription)")
                
                return Observable.just(.setError("정산 상세 데이터 조회 실패"))
            }
    }
}
