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
    
    init(postId: Int, participants: [ParticipantModel]) {
        self.initialState = State(
            postId: postId,
            participants: participants
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
        var postId: Int // 넘어온 postId
        var participants: [ParticipantModel]
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
            
            debugPrint3rdStepModel(model)
            
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
    
    // selections → SettleUp3rdStepModel 변환
    private func buildNextStepModel(selections: [SettleUpProductSelectionModel]) -> SettleUp3rdStepDataModel {
        // nickname → userId 매핑
        let nicknameToUserId: [String: Int] = Dictionary(
            uniqueKeysWithValues: currentState.participants.map { ($0.nickname, $0.userId) }
        )
        
        // 참여자별로 그룹핑
        var participantItems: [String: (assignedAmount: Int, items: [SettleUpItemDetailModel])] = [:]
        
        selections.forEach { product in
            let totalCount = product.selections.map { $0.value }.reduce(0, +)
            guard totalCount > 0 else { return }
            
            product.selections.forEach { selection in
                let amount = (selection.value * product.totalPrice) / totalCount  // 소수점 버림
                let item = SettleUpItemDetailModel(
                    itemName: product.productName,
                    quantity: selection.value,
                    unitIndex: product.unitIndex,
                    amount: amount
                )
                
                if participantItems[selection.userNickname] == nil {
                    participantItems[selection.userNickname] = (assignedAmount: 0, items: [])
                }
                
                participantItems[selection.userNickname]?.assignedAmount += amount
                participantItems[selection.userNickname]?.items.append(item)
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
            postId: currentState.postId,
            totalAmount: totalAmount,
            participants: participants
        )
    }
    
    // 3단계 전달 데이터 디버그 출력
    private func debugPrint3rdStepModel(_ model: SettleUp3rdStepDataModel) {
        logger.debug("======= 📌 3단계 전달 데이터 확인 =======")
        logger.debug("📮 postId: \(model.postId)")
        logger.debug("💰 총 금액: \(model.totalAmount)원")
        
        model.participants.forEach { participant in
            logger.debug("👤 \(participant.nickname) (userId: \(participant.userId)) - 총 \(participant.assignedAmount)원")
            participant.items.forEach { item in
                let unit = item.unitIndex == 1 ? "개" : "g"
                logger.debug("   └ \(item.itemName) \(item.quantity)\(unit) → \(item.amount)원")
            }
        }
        logger.debug("========================================")
    }
}
