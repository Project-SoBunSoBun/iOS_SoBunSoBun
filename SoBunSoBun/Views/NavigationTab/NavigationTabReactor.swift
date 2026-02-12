//
//  NavigationTabReactor.swift
//  SoBunSoBun
//
//  Created by 김태은 on 10/22/25.
//

import ReactorKit
import RxSwift

class NavigationTabReactor: Reactor {
    let initialState = State()
    
    private let commonNetworkManaer = CommonNetworkManager()
    
    enum Action {
        case viewDidLoad
        case selectIndex(Int)
    }
    
    enum Mutation {
        case setSelectedIndex(Int)
        case setErrorMessage(String)
    }
    
    struct State {
        var selectedIndex: Int = 0
        @Pulse var errorMessage: String? = nil
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return Observable.concat([
                getMyData()
            ])
            
        case .selectIndex(let index):
            return Observable.just(.setSelectedIndex(index))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setSelectedIndex(let index):
            newState.selectedIndex = index
            
        case .setErrorMessage(let message):
            newState.errorMessage = message
        }
        
        return newState
    }
    
    private func getMyData() -> Observable<Mutation> {
        if KeyChain.shared.get(key: "USER_ID") != nil,
           KeyChain.shared.get(key: "EMAIL") != nil {
            return Observable.empty()
        }
            
        return commonNetworkManaer.myProfile()
            .asObservable()
            .flatMap { userInfo -> Observable<Mutation> in
                KeyChain.shared.set(key: "USER_ID", value: String(userInfo.id))
                KeyChain.shared.set(key: "EMAIL", value: userInfo.email)
                
                return Observable.empty()
            }
            .catch { error in
                return Observable.just(.setErrorMessage(String(localized: "ErrorMessage")))
            }
    }
}
