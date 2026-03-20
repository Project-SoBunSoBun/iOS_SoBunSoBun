//
//  ProfileManagableReactor.swift
//  SoBunSoBun
//
//  Created by 김태은 on 3/14/26.
//

import Foundation
import ReactorKit
import RxSwift
import OSLog

class ProfileManagableReactor: Reactor {
    private let userId: Int
    
    init(userId: Int) {
        self.userId = userId
    }
    
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "ProfileManagable.Reactor"
    )
    
    private let disposeBag = DisposeBag()
    private let networkManager = ProfileNetworkManager()
    
    let initialState: State = State()
    private let PAGE_SIZE: Int = 20
    
    enum Action {
        case viewWillAppear
        case reportButtonTapped
        case blockButtonTapped
        case blockUser
        case unBlockUser
    }
    
    enum Mutation {
        case setUserInfo(ProfileUserInfoResponseDataModel)
        case setShouldPushUserReportView
        case setShouldShowBlockAlert
        case setShouldShowBlockDoneAlert
        case setShouldShowUnBlockAlert
        case setShouldShowUnBlockDoneAlert
        case setErrorMessage(String)
    }
    
    struct State {
        var userInfo: ProfileUserInfoResponseDataModel? // 유저 정보 모델
        var page: Int = 0 // 페이지네이션 페이지 번호
        var posts: [PostModel] = [] // 게시글
        var isLoading: Bool = false
        var hasMore: Bool = true // 페이지네이션 추가 가능 여부
        var isRefreshing: Bool = false
        @Pulse var shouldPushPostDetailView: PostModel?
        @Pulse var shouldPushUserReportView: Void?
        @Pulse var shouldShowBlockAlert: Void?
        @Pulse var shouldShowBlockDoneAlert: Void?
        @Pulse var shouldShowUnBlockAlert: Void?
        @Pulse var shouldShowUnBlockDoneAlert: Void?
        @Pulse var errorMessage: String?
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return loadPosts(page: 0, isFirst: true)
            
        case .reportButtonTapped:
            return Observable.just(.setShouldPushUserReportView)
            
        case .blockButtonTapped:
            guard let userInfo = currentState.userInfo else {
                return Observable.empty()
            }
            
            if userInfo.isBlocked {
                return Observable.just(.setShouldShowUnBlockAlert)
            } else {
                return Observable.just(.setShouldShowBlockAlert)
            }
            
        case .blockUser:
            return blockUser()
            
        case .unBlockUser:
            return unBlockUser()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setUserInfo(let model):
            newState.userInfo = model
            
        case .setShouldPushUserReportView:
            newState.shouldPushUserReportView = ()
            
        case .setShouldShowBlockAlert:
            newState.shouldShowBlockAlert = ()
            
        case .setShouldShowBlockDoneAlert:
            newState.shouldShowBlockDoneAlert = ()
            
        case .setShouldShowUnBlockAlert:
            newState.shouldShowUnBlockAlert = ()
            
        case .setShouldShowUnBlockDoneAlert:
            newState.shouldShowUnBlockDoneAlert = ()
            
        case .setErrorMessage(let message):
            newState.errorMessage = message
        }
        
        return newState
    }
    
    // 홈 게시글 목록 API 호출
    private func loadPosts(page: Int, isFirst: Bool) -> Observable<Mutation> {
        return networkManager.getProfilePostList(userId: self.userId, page: page, size: self.PAGE_SIZE)
            .asObservable()
            .flatMap { response -> Observable<Mutation> in
                if let data = response.data {
                    return Observable.just(.setUserInfo(data))
                } else {
                    self.logger.critical("게시글 목록 조회 중 오류")
                    
                    return Observable.empty()
                }
            }
            .catch { error in
                self.logger.critical("게시글 목록 불러오기 실패: \(error.localizedDescription)")
                
                return Observable.just(.setErrorMessage(String(localized: "ErrorMessage", table: "Common")))
            }
    }
    
    private func blockUser() -> Observable<Mutation> {
        let userInfo = currentState.userInfo
        
        return networkManager.blockUser(userId: userId)
            .asObservable()
            .flatMap { [weak self] model -> Observable<Mutation> in
                guard let self = self else { return Observable.empty() }
                
                if model.success {
                    if var info = userInfo {
                        info.isBlocked.toggle()
                        
                        self.logger.debug("차단 완료")
                        
                        return Observable.concat([
                            Observable.just(.setUserInfo(info)),
                            Observable.just(.setShouldShowBlockDoneAlert)
                        ])
                    } else {
                        self.logger.fault("차단 중 userInfo가 없음")
                        
                        return Observable.just(.setErrorMessage(String(localized: "ErrorMessage", table: "Common")))
                    }
                } else {
                    if let errorCode = model.errorCode {
                        self.logger.critical("차단 중 오류: \(model.message ?? "")")
                        
                        return Observable.just(.setErrorMessage(String(format: String(localized: "ErrorMessageWithCode", table: "Common"), errorCode)))
                    } else {
                        self.logger.critical("차단 중 오류")
                        
                        return Observable.just(.setErrorMessage(String(localized: "ErrorMessage", table: "Common")))
                    }
                }
            }
            .catch { [weak self] error -> Observable<Mutation> in
                guard let self = self else { return Observable.empty() }
                
                self.logger.critical("차단 중 오류: \(error.localizedDescription)")
                
                return Observable.just(.setErrorMessage(String(localized: "ErrorMessage", table: "Common")))
            }
    }
    
    private func unBlockUser() -> Observable<Mutation> {
        let userInfo = currentState.userInfo
        
        return networkManager.unBlockUser(userId: userId)
            .asObservable()
            .flatMap { [weak self] model -> Observable<Mutation> in
                guard let self = self else { return Observable.empty() }
                
                if model.success {
                    if var info = userInfo {
                        info.isBlocked.toggle()
                        
                        self.logger.debug("차단 해제 완료")
                        
                        return Observable.concat([
                            Observable.just(.setUserInfo(info)),
                            Observable.just(.setShouldShowUnBlockDoneAlert)
                        ])
                    } else {
                        self.logger.fault("차단 해제 중 userInfo가 없음")
                        
                        return Observable.just(.setErrorMessage(String(localized: "ErrorMessage", table: "Common")))
                    }
                } else {
                    if let errorCode = model.errorCode {
                        self.logger.critical("차단 해제 중 오류: \(model.message ?? "")")
                        
                        return Observable.just(.setErrorMessage(String(format: String(localized: "ErrorMessageWithCode", table: "Common"), errorCode)))
                    } else {
                        self.logger.critical("차단 해제 중 오류")
                        
                        return Observable.just(.setErrorMessage(String(localized: "ErrorMessage", table: "Common")))
                    }
                }
            }
            .catch { [weak self] error -> Observable<Mutation> in
                guard let self = self else { return Observable.empty() }
                
                self.logger.critical("차단 해제 중 오류: \(error.localizedDescription)")
                
                return Observable.just(.setErrorMessage(String(localized: "ErrorMessage", table: "Common")))
            }
    }
}
