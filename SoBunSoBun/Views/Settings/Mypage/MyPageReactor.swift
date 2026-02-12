//
//  MyPageReactor.swift
//  SoBunSoBun
//
//  Created by 허성필 on 1/24/26.
//

import ReactorKit
import RxSwift
import OSLog

class MyPageReactor: Reactor {
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "Settings.MyPage.Reactor"
    )
    
    let initialState = State()
    
    private let disposeBag = DisposeBag()
    
    enum ViewType {
        case editProfile
        case groupBuyingRecord
        case myPost
        case saveList
        case appSetting
        case myLocaionSetting
    }
    
    enum Action {
        case viewWillAppear
        case settingButtonTapped
        case editProfileButtonTapped
        case groupBuyingRecordTapped
        case myPostTapped
        case saveListTapped
        case appSettingTapped
        case myLocationSettingTapped
    }
    
    enum Mutation {
        case setProfile(MyProfileModel)
        case setLoading(Bool)
        case setError(String)
        case setNavigate(ViewType)
    }
    
    struct State {
        var profile: MyProfileModel?
        var isLoading: Bool = false
        var errorMessage: String?
        @Pulse var shouldNavigate: ViewType? = nil
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {  
        case .viewWillAppear:
            return Observable.concat([
                Observable.just(.setLoading(true)),
                NetworkManager.shared.getMeProfile()
                    .asObservable()
                    .flatMap { profile -> Observable<Mutation> in
                        return Observable.just(.setProfile(profile))
                    }
                    .catch { error in
                        self.logger.error("getMeProfile 실패: \(error.localizedDescription)")
                        return Observable.just(.setError(error.localizedDescription))
                    },
                Observable.just(.setLoading(false))
            ])
            
        case .settingButtonTapped:
            return Observable.just(.setNavigate(.appSetting))
            
        case .editProfileButtonTapped:
            return Observable.just(.setNavigate(.editProfile))
            
        case .groupBuyingRecordTapped:
            return Observable.just(.setNavigate(.groupBuyingRecord))
            
        case .myPostTapped:
            return Observable.just(.setNavigate(.myPost))
            
        case .saveListTapped:
            return Observable.just(.setNavigate(.saveList))
            
        case .appSettingTapped:
            return Observable.just(.setNavigate(.appSetting))
        
        case .myLocationSettingTapped:
            return Observable.just(.setNavigate(.myLocaionSetting))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setProfile(let profile):
            newState.profile = profile
            
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
            
        case .setError(let message):
            newState.errorMessage = message
        
        case .setNavigate(let viewType):
            newState.shouldNavigate = viewType
        }
        
        return newState
    }
}
