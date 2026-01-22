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
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "SelectCategories.Reactor"
    )
    
    let initialState: State = State()
    
    enum Action {
        case viewDidLoad([String])
        case selectCategory(String)
    }
    
    enum Mutation {
        case setCategories([String])
        case addSelectedCategory(String)
        case removeSelectedCategory(String)
    }
    
    struct State {
        var selectedCategories: [String] = []
        var categories: [String] = []
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad(let selectedCategories):
            let setSelectedCategories = selectedCategories.map {
                Observable.just(Mutation.addSelectedCategory($0))
            }
            
            return Observable.concat([getCategoriesFromLocalizableString()] + setSelectedCategories)
            
        case .selectCategory(let category):
            // Array는 순차로 검색하지만, Set은 해시 함수를 통해 더 빨리 검색함
            let selectedSet = Set(currentState.selectedCategories)
            
            if selectedSet.contains(category) {
                return Observable.just(.removeSelectedCategory(category))
            } else {
                return Observable.just(.addSelectedCategory(category))
            }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setCategories(let categories):
            newState.categories = categories
        case .addSelectedCategory(let category):
            newState.selectedCategories.append(category)
        case .removeSelectedCategory(let category):
            newState.selectedCategories.removeAll { $0 == category }
        }
        
        return newState
    }
    
    private func getCategoriesFromLocalizableString() -> Observable<Mutation> {
        let bundle = Bundle.main
        guard let path = bundle.path(forResource: "Localizable", ofType: "strings"),
              let dict = NSDictionary(contentsOfFile: path) as? [String: String] else {
            logger.critical("Localizable.strings not found")
            return Observable.just(.setCategories([]))
        }
        
        let categories = dict.keys
            .filter { $0.hasPrefix("Category") }
            .compactMap { key -> String? in
                let id = String(key.suffix(4))
                return Int(id) != nil ? id : nil
            }
            .sorted()
        
        return Observable.just(.setCategories(categories))
    }
}
