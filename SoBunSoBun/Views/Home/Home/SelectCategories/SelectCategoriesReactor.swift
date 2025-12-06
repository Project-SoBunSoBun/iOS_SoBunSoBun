//
//  SelectCategoriesReactor.swift
//  SoBunSoBun
//
//  Created by 김태은 on 11/15/25.
//

import Foundation
import ReactorKit
import RxSwift
import RxCocoa
import OSLog

class SelectCategoriesReactor: Reactor {
    private static let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "SelectCategories.Reactor"
    )
    
    let initialState: State
    
    init(selectedCategories: [String]) {
        self.initialState = State(
            selectedCategories: selectedCategories,
            groups: Self.getCategoriesFromLocalizableString()
        )
    }
    
    enum Action {
        case toggleCategory(String)
    }
    
    enum Mutation {
        case addCategory(String)
        case removeCategory(String)
    }
    
    struct State {
        var selectedCategories: [String]
        var groups: [String]
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .toggleCategory(let category):
            if currentState.selectedCategories.contains(category) {
                return Observable.just(.removeCategory(category))
            } else {
                return Observable.just(.addCategory(category))
            }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .addCategory(let category):
            newState.selectedCategories.append(category)
        case .removeCategory(let category):
            newState.selectedCategories.removeAll { $0 == category }
        }
        
        return newState
    }
    
    private static func getCategoriesFromLocalizableString() -> [String] {
        let bundle = Bundle.main
        guard let path = bundle.path(forResource: "Localizable", ofType: "strings"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: String] else {
            logger.fault("Localizable.strings not found")
            return []
        }
        
        let matchedKeys = dict.filter { $0.key.contains("CategoryGroup") }
        
        return matchedKeys
            .sorted { $0.key < $1.key }
            .map { String($0.key.suffix(2)) }
    }
}
