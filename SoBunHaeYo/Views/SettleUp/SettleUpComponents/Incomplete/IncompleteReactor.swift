//
//  IncompleteReactor.swift
//  SoBunHaeYo
//
//  Created by 허성필 on 11/13/25.
//

import ReactorKit
import RxSwift

// 임시 작성 Reactor. 추후 화면 디자인 나오면 수정 예정
class IncompleteReactor: Reactor {
    let initialState = State()
    
    private let disposeBag = DisposeBag()
    
    enum Action {
        case settleUpButtonTapped // 정산하기 버튼
        case statementCheckButtonTapped // 정산서 확인 버튼
        case shareButtonTapped // 공유하기 버튼
        case menuButtonTapped // 메뉴 버튼
    }
    
    enum Mutation {
        case setSettleButtonTapped
        case setStateCheckButtonTapped
        case setShareButtonTapped
        case setMenuButtonTapped
    }
    
    struct State {
        
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .settleUpButtonTapped:
            return Observable.just(.setSettleButtonTapped)
        case .statementCheckButtonTapped:
            return Observable.just(.setStateCheckButtonTapped)
        case .shareButtonTapped:
            return Observable.just(.setShareButtonTapped)
        case .menuButtonTapped:
            return Observable.just(.setMenuButtonTapped)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        return newState
    }
}
