//
//  SettleUpReactor.swift
//  SoBunSoBun
//
//  Created by 허성필 on 11/14/25.
//

import ReactorKit
import RxSwift
import OSLog

enum SettleUpCategory: Int {
    case all = 0
    case incomplete = 1
    case complete = 2
}

class SettleUpReactor: Reactor {
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "SettleUp.SettleUp.Reactor"
    )
    
    let initialState = State()
    
    private let disposeBag = DisposeBag()
    
    private let networkManager = SettleUpNetworkManager()
    
    enum Action {
        case viewDidLoad
        case categorySelected(SettleUpCategory)
        case deleteSettleUpTapped(id: Int)
    }
    
    enum Mutation {
        case setSelectedCategory(SettleUpCategory)
        case setItems([SettleUpItemModel])
        case setLoading(Bool)
        case setError(String)
    }
    
    struct State {
        var selectedCategory: SettleUpCategory = .all
        var items: [SettleUpItemModel] = []
        var isLoading: Bool = false
        @Pulse var errorMessage: String?
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
            
        case .deleteSettleUpTapped(id: let id):
            return deleteSettleUp(id: id)
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
            
        case .setError(let message):
            newState.errorMessage = message
        }
        return newState
    }
    
    private func loadItems(for category: SettleUpCategory? = nil) -> Observable<Mutation> {
        let selectedCategory = category ?? currentState.selectedCategory
        let status: String
        
        switch selectedCategory {
        case .all:
            status = "ALL"
            
        case .incomplete:
            status = "PENDING"
            
        case .complete:
            status = "COMPLETED"
        }
        
        return Observable.concat([
            Observable.just(.setLoading(true)),
            networkManager.mySettleUps(status: status, page: 0, size: 20)
                .asObservable()
                .flatMap { SettleUpModel -> Observable<Mutation> in
                    let items: [SettleUpItemModel] = SettleUpModel.data.content.map { content in
                        let isCompleted = (content.status == "COMPLETED")
                        
                        return SettleUpItemModel(
                            settlementId: content.id,
                            authorId: content.authorId,
                            settlementStatus: isCompleted,
                            title: content.groupPostTitle,
                            location: content.locationName,
                            meetingDate: content.meetAt,
                            participants: content.participants
                        )
                    }
                    
                    return Observable.just(.setItems(items))
                }
                .catch { [weak self] error in
                    guard let self = self else { return Observable.empty() }
                    
                    self.logger.critical("정산 목록 로드 실패: \(error.localizedDescription)")
                    return Observable.just(.setError("정산 목록을 불러오는데 실패했습니다."))
                },
            Observable.just(.setLoading(false))
        ])
    }
    
    private func deleteSettleUp(id: Int) -> Observable<Mutation> {
        return Observable.concat([
            Observable.just(.setLoading(true)),
            networkManager.deleteSettleUp(id: id)
                .asObservable()
                .flatMap { [weak self] _ -> Observable<Mutation> in
                    guard let self = self else { return Observable.empty() }
                    
                    self.logger.debug("정산 삭제 성공 id: \(id)")
                    // 삭제 성공 후 목록 다시 로드
                    return self.loadItems()
                }
                .catch { [weak self] error in
                    guard let self = self else { return Observable.empty() }
                    
                    self.logger.critical("정산 삭제 실패: \(error.localizedDescription)")
                    return Observable.just(.setError("정산을 삭제하지 못했습니다."))
                },
            Observable.just(.setLoading(false))
        ])
    }
}
