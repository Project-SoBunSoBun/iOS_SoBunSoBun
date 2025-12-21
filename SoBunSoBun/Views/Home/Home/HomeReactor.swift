//
//  HomeReactor.swift
//  SoBunSoBun
//
//  Created by 김태은 on 11/17/25.
//

import Foundation
import ReactorKit
import RxSwift
import OSLog

class HomeReactor: Reactor {
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "Home.Home.Reactor"
    )
    
    private let disposeBag = DisposeBag()
    
    let initialState: State = State()
    let pageSize: Int = 20
    
    enum Action {
        case viewWillAppear
        case searchTapped
        case notificationsTapped
        case myProfileTapped
        case addCategoryTapped
        case getSelectedCategories([String])
        case registerPostTapped
        case loadMorePosts
        case refresh
    }
    
    enum Mutation {
        case setSearchView
        
        case verifyLocation(String)
        case setShowLocationSettingAlert
        
        case setNotificationsView
        case setMyProfileView
        
        case setAddCategoryTapped
        case setSelectedCategories([String])
        
        case setRegisterPostView
        
        case setLoading(Bool)
        case setRefreshing(Bool)
        case setPosts([PostModel])
        case appendPosts([PostModel])
        case setPage(Int)
        case setHasMore(Bool)
    }
    
    struct State {
        @Pulse var shouldPushSearchView: Void?
        
        var isLocationVerified: Bool = false
        
        @Pulse var shouldPushNotificationsView: Void?
        @Pulse var shouldPushMyProfileView: Void?
        
        @Pulse var shouldShowBottomCategorySheet: Void?
        var selectedCategories: [String] = []
        var verifiedLocation: String = "\(String(localized: "Loading"))..."
        @Pulse var shouldShowLocationSettingAlert: Void?
        
        @Pulse var shouldPushRegisterPostView: Void?
        
        var page: Int = 0
        var posts: [PostModel] = []
        var isLoading: Bool = false
        var isRefreshing: Bool = false
        var hasMore: Bool = true
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return .concat([
                currentState.isLocationVerified ? .empty() : verifyLocation(),
                .just(.setPage(0)),
                loadPosts(page: 0, isFirst: true, categories: currentState.selectedCategories)
            ])
            
        case .searchTapped:
            return .just(.setSearchView)
            
        case .notificationsTapped:
            return .just(.setNotificationsView)
            
        case .myProfileTapped:
            return .just(.setMyProfileView)
            
        case .addCategoryTapped:
            return .just(.setAddCategoryTapped)
            
        case .getSelectedCategories(let selectedCategories):
            return .concat([
                .just(.setSelectedCategories(selectedCategories)),
                .just(.setRefreshing(true)),
                .just(.setPage(0)),
                loadPosts(page: 0, isFirst: true, categories: selectedCategories),
                .just(.setRefreshing(false))
            ])
            
        case .registerPostTapped:
            return .just(.setRegisterPostView)
            
        case .loadMorePosts:
            guard !currentState.isLoading && currentState.hasMore else {
                return .empty()
            }
            
            let nextPage = currentState.page + 1
            return .concat([
                .just(.setPage(nextPage)),
                loadPosts(page: nextPage, isFirst: false, categories: currentState.selectedCategories)
            ])
            
        case .refresh:
            return .concat([
                .just(.setRefreshing(true)),
                .just(.setPage(0)),
                loadPosts(page: 0, isFirst: true, categories: currentState.selectedCategories),
                .just(.setRefreshing(false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setSearchView:
            newState.shouldPushSearchView = ()
            
        case .verifyLocation(let address):
            newState.verifiedLocation = address
            newState.isLocationVerified = !address.isEmpty && [String(localized: "ErrorMessage"), String(localized: "LocationPermissionDenied")].contains(address) == false
            
        case .setNotificationsView:
            newState.shouldPushNotificationsView = ()
            
        case .setMyProfileView:
            newState.shouldPushMyProfileView = ()
            
        case .setAddCategoryTapped:
            newState.shouldShowBottomCategorySheet = ()
            
        case .setSelectedCategories(let selectedCategories):
            newState.selectedCategories = selectedCategories
            
        case .setShowLocationSettingAlert:
            newState.shouldShowLocationSettingAlert = ()
            newState.verifiedLocation = String(localized: "LocationPermissionDenied")
            
        case .setRegisterPostView:
            newState.shouldPushRegisterPostView = ()
            
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
            
        case .setRefreshing(let isRefreshing):
            newState.isRefreshing = isRefreshing
            
        case .setPosts(let posts):
            newState.posts = posts
            
        case .appendPosts(let posts):
            newState.posts.append(contentsOf: posts)
            
        case .setPage(let page):
            newState.page = page
            
        case .setHasMore(let hasMore):
            newState.hasMore = hasMore
        }
        
        return newState
    }
    
    private func verifyLocation() -> Observable<Mutation> {
        return NetworkManager.shared.getLocationVefirication()
            .asObservable()
            .flatMap { model -> Observable<Mutation> in
                if let address = model.address, !model.expired {
                    return .just(.verifyLocation(address))
                } else {
                    return self.getLocation()
                }
            }
            .catch { [weak self] error in
                guard let self = self else { return Observable.empty() }
                
                logger.critical("서버로부터 위치 인증 정보 불러오기 실패: \(error.localizedDescription)")
                return .just(.verifyLocation(String(localized: "ErrorMessage")))
            }
    }
    
    // 위치 가져오기
    private func getLocation() -> Observable<Mutation> {
        // 현재 권한 상태 확인
        let authStatus = LocationManager.shared.getCurrentAuthorizationStatus()
        
        switch authStatus {
        case .notDetermined:
            LocationManager.shared.requestLocationPermission()
            
            return LocationManager.shared.currentAuthorizationStatus
                .skip(1) // 현재 상태 스킵
                .timeout(.seconds(30), scheduler: MainScheduler.instance) // 30초 타임아웃
                .flatMap { status -> Observable<Mutation> in
                    switch status {
                    case .authorizedWhenInUse, .authorizedAlways: // 권한 허용
                        return self.requestLocationAndProcess()
                        
                    case .denied, .restricted: // 권한 거부됨
                        self.logger.error("위치 권한 거부됨")
                        return .just(.setShowLocationSettingAlert)
                        
                    default:
                        return .just(.verifyLocation(String(localized: "ErrorMessage")))
                    }
                }
                .catch { error in
                    self.logger.error("권한 요청 오류: \(error.localizedDescription)")
                    return .just(.setShowLocationSettingAlert)
                }
            
        case .authorizedWhenInUse, .authorizedAlways: // 이미 권한이 있는 경우
            return requestLocationAndProcess()
            
        case .denied, .restricted: // 권한 거부
            logger.error("위치 권한 거부됨")
            return .just(.setShowLocationSettingAlert)
            
        default:
            return .just(.verifyLocation(String(localized: "ErrorMessage")))
        }
    }

    // 위치 요청 및 처리
    private func requestLocationAndProcess() -> Observable<Mutation> {
        LocationManager.shared.requestCurrentLocation()
        
        return LocationManager.shared.currentLocation
            .compactMap { $0 }
            .take(1) // 1번만
            .timeout(.seconds(10), scheduler: MainScheduler.instance) // 10초 타임아웃
            .flatMap { coords -> Observable<Mutation> in
                return self.getAddressFromGeocoder(longitude: coords.longitude, latitude: coords.latitude)
            }
            .catch { [weak self] error in
                guard let self = self else { return Observable.empty() }
                
                logger.error("위치 가져오기 실패: \(error.localizedDescription)")
                return .just(.verifyLocation(String(localized: "ErrorMessage")))
            }
    }
    
    // 지오코더 API 호출
    private func getAddressFromGeocoder(longitude: Double, latitude: Double) -> Observable<Mutation> {
        return NetworkManager.shared.getAddresFromGeocoder(longitude: longitude, latitude: latitude)
            .asObservable()
            .flatMap { model -> Observable<Mutation> in
                let structure = model.response.result[0].structure
                let text = [structure.level1, structure.level2, structure.level3]
                    .joined(separator: " ")
                
                return self.patchLocationVerification(address: text)
            }
            .catch { [weak self] error in
                guard let self = self else { return Observable.empty() }
                
                logger.critical("지오코드 API 호출 실패: \(error.localizedDescription)")
                return .just(.verifyLocation(String(localized: "ErrorMessage")))
            }
    }
    
    // 위치 인증 갱신
    private func patchLocationVerification(address: String) -> Observable<Mutation> {
        return NetworkManager.shared.patchLocationVerification(address: address)
            .asObservable()
            .map { model -> Mutation in
                if let address = model.address {
                    return .verifyLocation(address)
                } else {
                    self.logger.error("patch 후에도 address 적용 안 됨")
                    return .verifyLocation(String(localized: "ErrorMessage"))
                }
            }
            .catch { [weak self] error in
                guard let self = self else { return Observable.empty() }
                
                logger.fault("위치 인증 실패: \(error.localizedDescription)")
                return .just(.verifyLocation(String(localized: "ErrorMessage")))
            }
    }
    
    // 홈 게시글 목록 API 호출
    private func loadPosts(page: Int, isFirst: Bool, categories: [String] = []) -> Observable<Mutation> {
        // API 호출
        let api: Single<PostListResponseModel> = categories.isEmpty
        ? NetworkManager.shared.getHomeList(page: page, size: pageSize)
        : NetworkManager.shared.getHomeListByCategories(categories: categories, page: page, size: pageSize)
        
        return Observable.concat([
            .just(.setLoading(true)),
            api.asObservable()
                .flatMap { response -> Observable<Mutation> in
                    let mutations: Observable<Mutation> = isFirst
                    ? .just(.setPosts(response.posts))
                    : .just(.appendPosts(response.posts))
                    
                    return .concat([mutations,
                                   .just(.setHasMore(!response.pageInfo.last)),
                                   .just(.setLoading(false)).delay(.seconds(1), scheduler: MainScheduler.instance)
                    ])
                }
                .catch { error in
                    self.logger.fault("게시글 목록 불러오기 실패: \(error.localizedDescription)")
                    return .concat([
                        isFirst ? .just(.setPosts([])) : .empty(),
                        .just(.setLoading(false)).delay(.seconds(1), scheduler: MainScheduler.instance),
                        .just(.setHasMore(false))
                    ])
                }
        ])
    }
}
