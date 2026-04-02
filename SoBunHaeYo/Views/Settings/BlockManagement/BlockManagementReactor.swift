//
//  BlockManagementReactor.swift
//  SoBunHaeYo
//
//  Created by 김태은 on 3/28/26.
//

import Foundation
import ReactorKit
import RxSwift
import OSLog

class BlockManagementReactor: Reactor {
    private let logger = Logger(
        subsystem: "SoBunHaeYo",
        category: "Settings.BlockManagement.Reactor"
    )
    
    let initialState = State()
    
    private let settingNetworkManager = SettingNetworkManager()
    private let profileNetworkManager = ProfileNetworkManager()
    
    enum Action {
        case viewDidLoad
        case unblockButtonTapped(userId: Int)
        case unblockConfirmed
    }
    
    enum Mutation {
        case setBlockList([BlockListResponseDataModel])
        case setSelectedUserId(Int?)
        case setShouldShowUnblockAlert
        case removeBlockedUser(Int)
        case setErrorMessage(String)
    }
    
    struct State {
        var blockList: [BlockListResponseDataModel] = []
        var selectedUserId: Int? = nil
        @Pulse var shouldShowUnblockAlert: Void?
        @Pulse var errorMessage: String?
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return getBlockList()
            
        case .unblockButtonTapped(let userId):
            return Observable.concat([
                Observable.just(.setSelectedUserId(userId)),
                Observable.just(.setShouldShowUnblockAlert)
            ])
            
        case .unblockConfirmed:
            guard let userId = currentState.selectedUserId else {
                return Observable.empty()
            }
            
            return unblockUser(userId: userId)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setBlockList(let list):
            newState.blockList = list
            
        case .setSelectedUserId(let userId):
            newState.selectedUserId = userId
            
        case .setShouldShowUnblockAlert:
            newState.shouldShowUnblockAlert = ()
            
        case .removeBlockedUser(let userId):
            newState.blockList = newState.blockList.filter { $0.userId != userId }
            newState.selectedUserId = nil
            
        case .setErrorMessage(let message):
            newState.errorMessage = message
        }
        
        return newState
    }
    
    private func getBlockList() -> Observable<Mutation> {
        return settingNetworkManager.getBlockList()
            .asObservable()
            .flatMap { response -> Observable<Mutation> in
                Observable.just(.setBlockList(response.data))
            }
            .catch { [weak self] error in
                guard let self else { return Observable.empty() }
                
                self.logger.critical("차단 목록 조회 실패: \(error.localizedDescription)")
                
                let errorMessage = String(format: String(localized: "ErrorMessageWithReason", table: "Error"), error.localizedDescription)
                
                return Observable.just(.setErrorMessage(errorMessage))
            }
    }
    
    private func unblockUser(userId: Int) -> Observable<Mutation> {
        return profileNetworkManager.unBlockUser(userId: userId)
            .asObservable()
            .flatMap { [weak self] response -> Observable<Mutation> in
                guard let self else { return Observable.empty() }
                
                if response.success {
                    self.logger.debug("차단 해제 성공")
                    
                    return Observable.just(.removeBlockedUser(userId))
                } else {
                    if let errorCode = response.errorCode {
                        self.logger.critical("차단 해제 실패(\(errorCode)) - \(response.message ?? "")")
                        
                        return Observable.just(.setErrorMessage(localizedErrorMessage(errorCode)))
                    } else {
                        self.logger.critical("차단 해제 실패: \(response.message ?? "")")
                        
                        return Observable.just(.setErrorMessage(localizedErrorMessage(nil)))
                    }
                }
            }
            .catch { [weak self] error in
                guard let self else { return Observable.empty() }
                
                self.logger.critical("차단 해제 실패: \(error.localizedDescription)")
                
                let errorMessage = String(format: String(localized: "ErrorMessageWithReason", table: "Error"), error.localizedDescription)
                
                return Observable.just(.setErrorMessage(errorMessage))
            }
    }
}
