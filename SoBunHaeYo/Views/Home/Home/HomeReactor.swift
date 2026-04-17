//
//  HomeReactor.swift
//  SoBunHaeYo
//
//  Created by 김태은 on 11/17/25.
//

import Foundation
import ReactorKit
import RxSwift
import OSLog

class HomeReactor: Reactor {
    private let logger = Logger(
        subsystem: "SoBunHaeYo",
        category: "Home.Home.Reactor"
    )
    
    private let disposeBag = DisposeBag()
    private let networkManager = HomeNetworkManager()
    
    let initialState: State = State()
    private let PAGE_SIZE: Int = 20
    
    enum Action {
        case viewWillAppear // viewWillAppear 생명주기 실행
        
        case notificationsTapped // 알림 아이콘 tap
        case myProfileTapped // 내 프로필 tap
        
        case searchTapped // 검색창 tap
        
        case sortButtonTapped // 정렬 목록 버튼 tap
        case sortTapped(String) // 정렬 tap
        
        case addCategoryTapped // 카테고리 추가 버튼 tap
        case getSelectedCategories([String]) // 선택한 카테고리 bind
        
        case loadMorePosts // 페이지네이션
        case refresh // 새로고침
        case createPostTapped // 글 쓰기 버튼 tap
        case postTapped(PostModel) // 게시글 tap
    }
    
    enum Mutation {
        case verifyLocation(String) // 위치 인증
        case setShowLocationSettingAlert // 위치 권환 알림 표시
        
        case setNotificationsView // 알림 뷰로 이동
        case setMyProfileView // 내 프로필로 이동
        
        case setSearchView // 검색 뷰로 이동
        
        case setIsSortButtonOpen(Bool) // 정렬 목록 버튼 열림 여부
        case setSort(String) // 정렬 설정
        
        case setAddCategoryTapped // 카테고리 추가 뷰 표시
        case setSelectedCategories([String]) // 선택한 카테고리 적용
        
        case setLoading(Bool)
        case setRefreshing(Bool)
        case setPosts([PostModel]) // 게시글 설정
        case appendPosts([PostModel]) // 페이지네이션 게시글 추가
        case setPage(Int) // 페이지네이션 페이지 번호 설정
        case setHasMore(Bool) // 페이지네이션 추가 가능 여부 설정
        case setCreatePostView // 글 쓰기 뷰로 이동
        case setPostDetailView(PostModel) // 게시글 상세 뷰로 이동
    }
    
    struct State {
        var isLocationVerified: Bool = false // 위치 인증 여부
        var verifiedLocation: String = "\(String(localized: "Loading", table: "Common"))..." // 인증된 위치 정보
        @Pulse var shouldShowLocationSettingAlert: Void? // 위치 권한 알림 표시
        
        @Pulse var shouldPushNotificationsView: Void? // 알림 뷰로 이동
        
        @Pulse var shouldPushMyProfileView: Void? // 내 프로필 뷰로 이동
        
        @Pulse var shouldPushSearchView: Void? // 검색 뷰로 이동
        
        var isSortButtonOpen: Bool = false // 정렬 목록 버튼 열림
        var sortBy: String = "SortByLatest" // 정렬
        
        @Pulse var shouldShowBottomCategorySheet: Void? // 카테고리 추가 뷰 표시
        var selectedCategories: [String] = [] // 선택된 카테고리
        
        var page: Int = 0 // 페이지네이션 페이지 번호
        var posts: [PostModel] = [] // 게시글
        var isLoading: Bool = false
        var isRefreshing: Bool = false
        var hasMore: Bool = true // 페이지네이션 추가 가능 여부
        @Pulse var shouldPushCreatePostView: Void? // 글 쓰기 뷰로 이동
        @Pulse var shouldPushPostDetailView: PostModel? // 게시글 상세 뷰로 이동
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return Observable.concat([
                Observable.just(.setPage(0)),
                loadPosts(sortBy: currentState.sortBy, page: 0, isFirst: true, categories: currentState.selectedCategories),
                currentState.isLocationVerified ? Observable.empty() : verifyLocation()
            ])
            
        case .notificationsTapped:
            return Observable.just(.setNotificationsView)
            
        case .myProfileTapped:
            return Observable.just(.setMyProfileView)
            
        case .searchTapped:
            return Observable.just(.setSearchView)
            
        case .sortButtonTapped:
            return Observable.just(.setIsSortButtonOpen(!currentState.isSortButtonOpen))
            
        case .sortTapped(let sortBy):
            return Observable.concat([
                Observable.just(.setIsSortButtonOpen(false)),
                Observable.just(.setSort(sortBy)),
                loadPosts(sortBy: sortBy, page: 0, isFirst: true)
            ])
            
        case .addCategoryTapped:
            return Observable.just(.setAddCategoryTapped)
            
        case .getSelectedCategories(let selectedCategories):
            guard Set(selectedCategories) != Set(currentState.selectedCategories) else {
                return Observable.empty()
            }
            
            return Observable.concat([
                Observable.just(.setSelectedCategories(selectedCategories)),
                Observable.just(.setRefreshing(true)),
                Observable.just(.setPage(0)),
                loadPosts(sortBy: currentState.sortBy, page: 0, isFirst: true, categories: selectedCategories),
                Observable.just(.setRefreshing(false))
            ])
            
        case .loadMorePosts:
            guard !currentState.isLoading && currentState.hasMore else {
                return Observable.empty()
            }
            
            let nextPage = currentState.page + 1
            
            return Observable.concat([
                Observable.just(.setPage(nextPage)),
                loadPosts(sortBy: currentState.sortBy, page: nextPage, isFirst: false, categories: currentState.selectedCategories)
            ])
            
        case .refresh:
            return Observable.concat([
                Observable.just(.setRefreshing(true)),
                Observable.just(.setPage(0)),
                loadPosts(sortBy: currentState.sortBy, page: 0, isFirst: true, categories: currentState.selectedCategories),
                Observable.just(.setRefreshing(false))
            ])
            
        case .createPostTapped:
            return Observable.just(.setCreatePostView)
            
        case .postTapped(let model):
            return Observable.just(.setPostDetailView(model))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .verifyLocation(let address):
            newState.verifiedLocation = address
            newState.isLocationVerified = !address.isEmpty &&
            [String(localized: "ErrorMessage", table: "Error"), String(localized: "LocationPermissionDenied", table: "Home")].contains(address) == false
            
        case .setShowLocationSettingAlert:
            newState.shouldShowLocationSettingAlert = ()
            newState.verifiedLocation = String(localized: "LocationPermissionDenied", table: "Home")
            
        case .setNotificationsView:
            newState.shouldPushNotificationsView = ()
            
        case .setMyProfileView:
            newState.shouldPushMyProfileView = ()
            
        case .setSearchView:
            newState.shouldPushSearchView = ()
            
        case .setIsSortButtonOpen(let isOpen):
            newState.isSortButtonOpen = isOpen
            
        case .setSort(let sortBy):
            newState.sortBy = sortBy
            
        case .setAddCategoryTapped:
            newState.shouldShowBottomCategorySheet = ()
            
        case .setSelectedCategories(let selectedCategories):
            newState.selectedCategories = selectedCategories
            
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
            
        case .setCreatePostView:
            newState.shouldPushCreatePostView = ()
            
        case .setPostDetailView(let model):
            newState.shouldPushPostDetailView = model
        }
        
        return newState
    }
    
    // 서버로부터 위치 인증 정보 불러오기
    private func verifyLocation() -> Observable<Mutation> {
        return networkManager.getLocationVefirication()
            .asObservable()
            .flatMap { model -> Observable<Mutation> in
                if let address = model.address, !model.expired {
                    return Observable.just(.verifyLocation(address))
                } else {
                    return self.getLocation()
                }
            }
            .catch { [weak self] error in
                guard let self = self else { return Observable.empty() }
                
                logger.critical("서버로부터 위치 인증 정보 불러오기 실패: \((error as? APIErrorModel)?.message ?? error.localizedDescription)")
                
                return Observable.just(.verifyLocation(String(localized: "ErrorMessage", table: "Error")))
            }
    }
    
    // 디바이스로부터 위치 정보 가져오기
    private func getLocation() -> Observable<Mutation> {
        // 현재 권한 상태 확인
        let authStatus = LocationManager.shared.getCurrentAuthorizationStatus()
        
        switch authStatus {
        case .notDetermined:
            LocationManager.shared.requestLocationPermission()
            
            return LocationManager.shared.currentAuthorizationStatus
                .skip(1) // 현재 상태 스킵
                .filter { status in // 권한 요청 후 상태만
                    status != .notDetermined
                }
                .take(1) // 한 번만
                .timeout(.seconds(10), scheduler: MainScheduler.instance) // 10초 타임아웃
                .flatMap { status -> Observable<Mutation> in
                    switch status {
                    case .authorizedWhenInUse, .authorizedAlways: // 권한 허용
                        
                        return self.requestLocationAndProcess()
                        
                    case .denied, .restricted: // 권한 거부됨
                        self.logger.fault("위치 권한 요청 후 거부됨")
                        
                        return Observable.just(.setShowLocationSettingAlert)
                        
                    default: // 뭔가 잘못 됨
                        self.logger.fault("위치 권한 요청 후 무언가 잘못 됨: \(status.rawValue)")
                        
                        return Observable.just(.verifyLocation(String(localized: "ErrorMessage", table: "Error")))
                    }
                }
                .catch { error in
                    self.logger.fault("위치 권한 요청 오류: \(error.localizedDescription)")
                    
                    return Observable.just(.setShowLocationSettingAlert)
                }
            
        case .authorizedWhenInUse, .authorizedAlways: // 이미 권한이 있는 경우
            return requestLocationAndProcess()
            
        case .denied, .restricted: // 권한 거부
            logger.fault("위치 권한 거부됨")
            
            return Observable.just(.setShowLocationSettingAlert)
            
        default:
            logger.fault("위치 권한이 무언가 잘못 됨: \(authStatus.rawValue)")
            
            return Observable.just(.verifyLocation(String(localized: "ErrorMessage", table: "Error")))
        }
    }
    
    // 디바이스로부터 현재 위치 정보 불러온 후 지오코더 API 호출
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
                
                logger.fault("위치 가져오기 실패: \(error.localizedDescription)")
                
                return Observable.just(.verifyLocation(String(localized: "ErrorMessage", table: "Error")))
            }
    }
    
    // 지오코더 API 호출
    private func getAddressFromGeocoder(longitude: Double, latitude: Double) -> Observable<Mutation> {
        return networkManager.getAddressFromGeocoder(longitude: longitude, latitude: latitude)
            .asObservable()
            .flatMap { model -> Observable<Mutation> in
                let structure = model.response.result[0].structure
                let text = [structure.level1, structure.level2, structure.level3]
                    .joined(separator: " ")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                
                return self.patchLocationVerification(address: text)
            }
            .catch { [weak self] error in
                guard let self = self else { return Observable.empty() }

                logger.critical("지오코드 API 호출 실패: \(error.localizedDescription)")
                
                return Observable.just(.verifyLocation(String(localized: "ErrorMessage", table: "Error")))
            }
    }
    
    // 서버에 위치 인증 갱신
    private func patchLocationVerification(address: String) -> Observable<Mutation> {
        return networkManager.patchLocationVerification(address: address)
            .asObservable()
            .map { model -> Mutation in
                if let address = model.address {
                    return .verifyLocation(address)
                } else {
                    self.logger.critical("patch 후에도 address 적용 안 됨")
                    
                    return .verifyLocation(String(localized: "ErrorMessage", table: "Error"))
                }
            }
            .catch { [weak self] error in
                guard let self = self else { return Observable.empty() }
                
                logger.fault("위치 인증 실패: \(error.localizedDescription)")
                
                return Observable.just(.verifyLocation(String(localized: "ErrorMessage", table: "Error")))
            }
    }
    
    // 홈 게시글 목록 API 호출
    private func loadPosts(sortBy: String, page: Int, isFirst: Bool, categories: [String] = []) -> Observable<Mutation> {
        let sortBy = sortBy.replacingOccurrences(of: "SortBy", with: "").lowercased()
        
        // API 호출
        let api: Single<PostListResponseModel> = categories.isEmpty
        ? networkManager.getHomeList(sortBy: sortBy, page: page, size: PAGE_SIZE)
        : networkManager.getHomeListByCategories(categories: categories, sortBy: sortBy, page: page, size: PAGE_SIZE)
        
        return Observable.deferred {
            Observable.concat([
                Observable.just(.setLoading(true)),
                api.asObservable()
                    .flatMap { response -> Observable<Mutation> in
                        let mutations: Observable<Mutation> = isFirst
                            ? Observable.just(.setPosts(response.posts))
                            : Observable.just(.appendPosts(response.posts))

                        return Observable.concat([
                            mutations,
                            Observable.just(.setHasMore(!response.pageInfo.last))
                        ])
                    }
                    .catch { error in
                        self.logger.critical("게시글 목록 불러오기 실패: \((error as? APIErrorModel)?.message ?? error.localizedDescription)")

                        return Observable.concat([
                            isFirst ? Observable.just(.setPosts([])) : Observable.empty(),
                            Observable.just(.setHasMore(false)),
                            Observable.just(.setPage(0))
                        ])
                    },
                Observable.just(.setLoading(false))
            ])
        }
    }
}
