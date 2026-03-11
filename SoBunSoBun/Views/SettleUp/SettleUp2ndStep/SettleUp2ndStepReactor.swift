//
//  SettleUp2ndStepReactor.swift
//  SoBunSoBun
//
//  Created by 허성필 on 1/12/26.
//

import ReactorKit
import OSLog

class SettleUp2ndStepReactor: Reactor {
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "SettleUp.SettleUp2ndStep.Reactor"
    )
    
    init(settlementId: Int, participants: [ParticipantModel], authorId: Int) {
        self.initialState = State(
            settlementId: settlementId,
            participants: participants,
            authorId: authorId
        )
    }
    
    let initialState: State
    
    enum Action {
        case registerButtonTapped([SettleUpProductSelectionModel])
    }
    
    enum Mutation {
        case setNextStepData(SettleUp3rdStepDataModel)
        case setValidationError(String)
    }
    
    struct State {
        var settlementId: Int // 넘어온 postId
        var participants: [ParticipantModel]
        var authorId: Int
        @Pulse var shouldNavigateToNextStep: SettleUp3rdStepDataModel?
        @Pulse var validationError: String?
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .registerButtonTapped(let selections):
            //수량 검증
            let hasInvalid = selections.contains { product in
                let inputTotal = product.selections.map { $0.value }.reduce(0, +)
                
                return inputTotal != product.totalCount
            }
            
            if hasInvalid {
                return Observable.just(.setValidationError("ValidationError"))
            }
            
            let model = buildNextStepModel(selections: selections)
            
            return Observable.just(.setNextStepData(model))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setNextStepData(let model):
            newState.shouldNavigateToNextStep = model
            
        case .setValidationError(let message):
            newState.validationError = message
        }
        
        return newState
    }
    
    // selections → SettleUp3rdStepModel 변환 (참여자별 금액 정산)
    private func buildNextStepModel(selections: [SettleUpProductSelectionModel]) -> SettleUp3rdStepDataModel {
        // nickname → userId 매핑
        let nicknameToUserId: [String: Int] = Dictionary(
            uniqueKeysWithValues: currentState.participants.map { ($0.nickname, $0.userId) }
        )
        
        // authorId에 해당하는 nickname 찾기
        let authorNickname = currentState.participants
            .first { $0.userId == currentState.authorId }?.nickname ?? ""
        
        // 참여자별로 그룹핑
        var participantItems: [String: (assignedAmount: Int, items: [SettleUpItemDetailModel])] = [:]
        
        selections.forEach { product in
            let totalCount = product.selections.map { $0.value }.reduce(0, +)
            guard totalCount > 0 else { return }
            
            // 각 참여자별 금액 계산 (소수점 버림)
            var calculatedAmounts: [String: Int] = [:]
            product.selections.forEach { selection in
                let amount = (selection.value * product.totalPrice) / totalCount
                let nickname = selection.userNickname.replacingOccurrences(of: "(나)", with: "")
                calculatedAmounts[nickname] = amount
            }
            
            // 나머지 계산 → 방장에게 추가
            let distributedTotal = calculatedAmounts.values.reduce(0, +)
            var remainder = product.totalPrice - distributedTotal
            
            if remainder != 0 {
                if calculatedAmounts[authorNickname] != nil {
                    // 방장이 참여 중이면 나머지 전부 방장에게
                    calculatedAmounts[authorNickname]! += remainder
                } else {
                    // 방장 미참여시 참여자들에게 1원씩 순서대로 분배
                    for nickname in calculatedAmounts.keys {
                        guard remainder > 0 else { break }
                        calculatedAmounts[nickname]! += 1
                        remainder -= 1
                    }
                }
            }
            
            product.selections.forEach { selection in
                let nickname = selection.userNickname.replacingOccurrences(of: "(나)", with: "")
                let amount = calculatedAmounts[nickname] ?? 0
                
                let item = SettleUpItemDetailModel(
                    itemName: product.productName,
                    quantity: selection.value,
                    unitIndex: product.unitIndex,
                    amount: amount
                )
                
                if participantItems[nickname] == nil {
                    participantItems[nickname] = (assignedAmount: 0, items: [])
                }
                
                participantItems[nickname]?.assignedAmount += amount
                participantItems[nickname]?.items.append(item)
            }
        }
        
        let participants = participantItems.map { nickname, data in
            SettleUpParticipantModel(
                userId: nicknameToUserId[nickname] ?? -1,
                nickname: nickname,
                assignedAmount: data.assignedAmount,
                items: data.items
            )
        }
        
        let totalAmount = participants.map { $0.assignedAmount }.reduce(0, +)
        
        return SettleUp3rdStepDataModel(
            settlementId: currentState.settlementId,
            totalAmount: totalAmount,
            participants: participants
        )
    }
}
