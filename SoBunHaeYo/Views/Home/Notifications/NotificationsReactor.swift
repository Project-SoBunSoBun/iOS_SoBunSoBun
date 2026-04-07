//
//  NotificationsReactor.swift
//  SoBunHaeYo
//
//  Created by 김태은 on 3/20/26.
//

import Foundation
import ReactorKit
import RxSwift
import OSLog

class NotificationsReactor: Reactor {
    private let logger = Logger(
        subsystem: "SoBunHaeYo",
        category: "Home.Notifications.Reactor"
    )
    
    let initialState = State()
    
    private let disposeBag = DisposeBag()
    
    private let homeNetworkManager = HomeNetworkManager()
    private let notificationsNetworkManager = NotificationNetworkManager()
    private let PAGE_SIZE: Int = 20
    
    enum Action {
        case viewWillAppear
        case cellTapped(NotificationModel) // 테이블 뷰 셀 클릭
        case refresh
        case loadMore
        case viewWillDisappear
    }
    
    enum Mutation {
        case setNotifications([NotificationModel]) // 초기 알림 목록
        case setLoading(Bool)
        case appendNotifications([NotificationModel]) // 알림 목록 추가
        case setPage(Int)
        case setHasMore(Bool)
        case setRefreshing(Bool)
        case setShouldPushView(NotificationModel)
        case setErrorMessage(String)
    }
    
    struct State {
        var notifications: [NotificationModel] = []
        var isLoading: Bool = false
        var page: Int = 0
        var hasMore: Bool = true
        var isRefreshing: Bool = false
        
        @Pulse var shouldPushView: NotificationModel?
        @Pulse var errorMessage: String?
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return Observable.concat([
                Observable.just(.setPage(0)),
                loadNotifications(page: currentState.page, size: PAGE_SIZE, isFirst: true)
            ])
            
        case .cellTapped(let model):
            return Observable.just(.setShouldPushView(model))
            
        case .refresh:
            return Observable.concat([
                Observable.just(.setRefreshing(true)),
                Observable.just(.setPage(0)),
                loadNotifications(page: 0, size: PAGE_SIZE, isFirst: true),
                Observable.just(.setRefreshing(false))
            ])
            
        case .loadMore:
            guard !currentState.isLoading && currentState.hasMore else {
                return Observable.empty()
            }
            
            let nextPage = currentState.page + 1
            
            return Observable.concat([
                Observable.just(.setPage(nextPage)),
                loadNotifications(page: nextPage, size: PAGE_SIZE, isFirst: false)
            ])
            
        case .viewWillDisappear:
            return readAllNotifications()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setNotifications(let models):
            newState.notifications = models
            
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
            
        case .appendNotifications(let models):
            newState.notifications.append(contentsOf: models)
            
        case .setPage(let page):
            newState.page = page
            
        case .setHasMore(let hasMore):
            newState.hasMore = hasMore
            
        case .setRefreshing(let isRefreshing):
            newState.isRefreshing = isRefreshing
            
        case .setShouldPushView(let model):
            newState.shouldPushView = model
            
        case .setErrorMessage(let message):
            newState.errorMessage = message
        }
        
        return newState
    }
    
    private func loadNotifications(page: Int, size: Int, isFirst: Bool) -> Observable<Mutation> {
        return notificationsNetworkManager.getNotifications(page: page, size: size)
            .asObservable()
            .flatMap { response -> Observable<Mutation> in
                self.logger.debug("알림 목록 조회 성공")
                
                let mutations: Observable<Mutation> = isFirst
                ? Observable.just(.setNotifications(response.data.content))
                : Observable.just(.appendNotifications(response.data.content))
                
                return Observable.concat([
                    mutations,
                    Observable.just(.setHasMore(!response.data.page.last))
                ])
            }
            .catch { error in
                self.logger.critical("알림 목록 불러오기 실패: \((error as? APIErrorModel)?.message ?? error.localizedDescription)")
                
                return Observable.concat([
                    isFirst ? Observable.just(.setNotifications([])) : Observable.empty(),
                    Observable.just(.setErrorMessage(String(localized: "FetchErrorMessage", table: "Notifications"))),
                    Observable.just(.setHasMore(false)),
                    Observable.just(.setPage(0))
                ])
            }
    }
    
    private func readAllNotifications() -> Observable<Mutation> {
        return notificationsNetworkManager.readAllNotifications()
            .asObservable()
            .flatMap { [weak self] model -> Observable<Mutation> in
                guard let self else { return Observable.empty() }
                
                if model.success {
                    self.logger.debug("알림 모두 읽음 완료")
                    NotificationCenter.default.post(name: .didReadAllNotifications, object: nil)
                } else {
                    if let errorCode = model.errorCode {
                        self.logger.critical("알림 모두 읽음 실패(\(errorCode)) - \(model.message ?? "")")
                    } else {
                        self.logger.critical("알림 모두 읽음 실패: \(model.message ?? "")")
                    }
                }
                
                return Observable.empty()
            }
            .catch { [weak self] error in
                guard let self else { return Observable.empty() }
                
                self.logger.critical("알림 모두 읽음 실패: \((error as? APIErrorModel)?.message ?? error.localizedDescription)")
                
                return Observable.empty()
            }
    }
}
