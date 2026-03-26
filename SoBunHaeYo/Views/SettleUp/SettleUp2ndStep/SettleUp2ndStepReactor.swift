//
//  SettleUp2ndStepReactor.swift
//  SoBunHaeYo
//
//  Created by 허성필 on 1/12/26.
//

import ReactorKit
import OSLog

class SettleUp2ndStepReactor: Reactor {
    init(settlementId: Int, participants: [SettleUpParticipantModel], authorId: Int) {
        self.initialState = State(
            settlementId: settlementId,
            participants: participants,
            authorId: authorId
        )
    }
    
    private let logger = Logger(
        subsystem: "SoBunHaeYo",
        category: "SettleUp.SettleUp2ndStep.Reactor"
    )
    
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
        var participants: [SettleUpParticipantModel]
        var authorId: Int
        @Pulse var shouldNavigateToNextStep: SettleUp3rdStepDataModel?
        @Pulse var validationError: String?
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .registerButtonTapped(let selections):
            // 음수 입력 검증
            let hasNegative = selections.contains { product in
                product.selections.contains { $0.value < 0 }
            }
            
            if hasNegative {
                return Observable.just(.setValidationError("ValidationNagativeError"))
            }
            
            // 수량 검증
            let hasInvalid = selections.contains { product in
                let inputTotal = product.selections.map { $0.value }.reduce(0, +)
                
                return inputTotal != product.totalCount
            }
            
            if hasInvalid {
                return Observable.just(.setValidationError("ValidationCheckQuantity"))
            }
            
            let model = transformNextStepModel(selections: selections)
            
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
    private func transformNextStepModel(selections: [SettleUpProductSelectionModel]) -> SettleUp3rdStepDataModel {
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
            let totalProductCount = product.selections.map { $0.value }.reduce(0, +)
            guard totalProductCount > 0 else { return }
            
            // 각 참여자별 금액 계산
            var calculatedAmounts: [String: Int] = [:]
            product.selections.forEach { selection in
                let amount = (selection.value * product.totalPrice) / totalProductCount
                let nickname = selection.userNickname.replacingOccurrences(of: String(localized: "Me", table: "SettleUp"), with: "")
                calculatedAmounts[nickname] = amount
            }
            
            // 나머지 계산 → 방장에게 추가
            let distributedTotal = calculatedAmounts.values.reduce(0, +)
            var remainderPrice = product.totalPrice - distributedTotal
            
            if remainderPrice != 0 {
                if calculatedAmounts[authorNickname] != nil {
                    // 방장이 참여 중이면 나머지 전부 방장에게
                    calculatedAmounts[authorNickname]! += remainderPrice
                } else {
                    // 방장 미참여시 참여자들에게 1원씩 순서대로 분배
                    for nickname in calculatedAmounts.keys {
                        guard remainderPrice > 0 else { break }
                        calculatedAmounts[nickname]! += 1
                        remainderPrice -= 1
                    }
                }
            }
            
            product.selections.forEach { selection in
                let nickname = selection.userNickname.replacingOccurrences(of: String(localized: "Me", table: "SettleUp"), with: "")
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
            SettleUp3rdStepParticipantModel(
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
