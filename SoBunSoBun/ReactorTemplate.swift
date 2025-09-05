import ReactorKit
import Foundation
import RxSwift

class ____Reactor: Reactor {
    var initialState: State

    private let disposeBag = DisposeBag()
    
    init(initialState: State) {
        self.initialState = initialState
    }
    
    enum Action {
        
    }
    
    enum Mutation {
        
    }
    
    struct State {
        
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
            
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
            
        }
        return newState
    }
}
