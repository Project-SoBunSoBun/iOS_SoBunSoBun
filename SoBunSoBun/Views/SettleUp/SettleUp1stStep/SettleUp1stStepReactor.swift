//
//  SettleUp1stStepReactor.swift
//  SoBunSoBun
//
//  Created by 허성필 on 12/11/25.
//

import ReactorKit

class SettleUp1stStepReactor: Reactor {
    let initialState = State()
    
    private let disposeBag = DisposeBag()
    
    enum Action {
        case backButtonTapped // 뒤로가기 버튼 클릭
    }
    
    enum Mutation {
        case setBackButtonTapped
    }
    
    struct State {
        @Pulse var shouldPopViewController: Void?
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .backButtonTapped:
            return Observable.just(.setBackButtonTapped)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setBackButtonTapped:
            newState.shouldPopViewController = ()
        }
        
        return newState
    }
}
