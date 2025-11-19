//
//  SettleUpReactor.swift
//  SoBunSoBun
//
//  Created by 허성필 on 11/14/25.
//

import ReactorKit
import RxSwift

enum SettleUpCategory: Int {
    case all = 0
    case incomplete = 1
    case complete = 2
}

struct SettleUpItem {
    let settleUpStatus: Bool
    let title: String
    let location: String
    let meetingDate: String
}

class SettleUpReactor: Reactor {
    let initialState = State()
    
    private let disposeBag = DisposeBag()
    
    enum Action {
        case viewDidLoad
        case categorySelected(SettleUpCategory)
    }
    
    enum Mutation {
        case setSelectedCategory(SettleUpCategory)
        case setItems([SettleUpItem])
        case setLoading(Bool)
    }
    
    struct State {
        var selectedCategory: SettleUpCategory = .all
        var items: [SettleUpItem] = []
        var isLoading: Bool = false
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
            
        case .viewDidLoad:
            return loadItems()
        case .categorySelected(let category):
            return Observable.concat([
                Observable.just(.setSelectedCategory(category)),
                loadItems(for: category)
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
            
        case .setSelectedCategory(let category):
            newState.selectedCategory = category
        case .setItems(let items):
            newState.items = items
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
        }
        return newState
    }
    
    private func loadItems(for category: SettleUpCategory? = nil) -> Observable<Mutation> {
        // TODO: NetworkManager를 사용해서 서버에서 데이터 받아오기
        let selectedCategory = category ?? currentState.selectedCategory
        
        return Observable.concat([
            Observable.just(.setLoading(true)),
            
            // 백엔드에서 API가 만들어지지 않아 임시의 목업데이터를 사용하여 테스트
            // 추후 API가 만들어지면 수정 예정
            Observable.just([
                SettleUpItem(settleUpStatus: false, title: "공동구매 1", location: "서울시 관악구", meetingDate: "2025-11-19T15:00:00+09:00"),
                SettleUpItem(settleUpStatus: false, title: "공동구매 2", location: "서울시 송파구", meetingDate: "2025-11-23T15:00:00+09:00"),
                SettleUpItem(settleUpStatus: false, title: "공동구매 3", location: "서울시 동작구", meetingDate: "2025-11-28T15:00:00+09:00"),
                SettleUpItem(settleUpStatus: true, title: "공동구매 4", location: "서울시 동작구", meetingDate: "2025-11-28T15:00:00+09:00"),
            ])
            .map { items -> [SettleUpItem] in
                switch selectedCategory {
                case .all:
                    return items
                case .incomplete:
                    return items.filter { !$0.settleUpStatus }
                case .complete:
                    return items.filter { $0.settleUpStatus }
                }
            }
            .map { .setItems($0) },
            
            Observable.just(.setLoading(false))
        ])
    }
}
