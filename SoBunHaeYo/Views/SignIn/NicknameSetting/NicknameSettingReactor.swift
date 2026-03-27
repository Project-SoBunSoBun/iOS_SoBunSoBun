//
//  NicknameSettingReactor.swift
//  SoBunHaeYo
//
//  Created by 허성필 on 10/23/25.
//

import UIKit
import ReactorKit
import RxSwift
import OSLog

class NicknameSettingReactor: Reactor {
    private let logger = Logger(
        subsystem: "SoBunHaeYo",
        category: "NicknameSetting.Reactor"
    )
    
    let initialState = State()
    private let disposeBag = DisposeBag()
    
    private let networkManager = SignInNetworkManager()
    
    enum Action {
        case backButtonTapped // 뒤로가기 버튼 클릭
        case nicknameChanged(String)
        case profileImageSelected(UIImage)
        case nextButtonTapped
        case cameraImageTapped
    }
    
    enum Mutation {
        case setBackButtonTapped
        case setNickname(String)
        case setProfileImage(UIImage)
        case setLoading(Bool)
        case setProfileSaved
        case setErrorMessage(String)
        case showImagePicker
    }
    
    struct State {
        @Pulse var shouldPopViewController: Void?
        var nickname: String = ""
        var profileImage: UIImage?
        var isLoading: Bool = false
        @Pulse var profileSaved: Void?
        @Pulse var errorMessage: String?
        @Pulse var shouldShowImagePicker: Void?
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .backButtonTapped:
            return Observable.just(.setBackButtonTapped)
            
        case .nicknameChanged(let nickname):
            return Observable.just(.setNickname(nickname))
            
        case .profileImageSelected(let image):
            return Observable.just(.setProfileImage(image))
            
        case .nextButtonTapped:
            return saveProfile()
            
        case .cameraImageTapped:
            return Observable.just(.showImagePicker)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setBackButtonTapped:
            newState.shouldPopViewController = ()
            
        case .setNickname(let nickname):
            newState.nickname = nickname
            
        case .setProfileImage(let image):
            newState.profileImage = image
            
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
            
        case .setProfileSaved:
            newState.profileSaved = ()
            
        case .setErrorMessage(let message):
            newState.errorMessage = message
            
        case .showImagePicker:
            newState.shouldShowImagePicker = ()
        }
        
        return newState
    }
    
    private func saveProfile() -> Observable<Mutation> {
        let nickname = currentState.nickname
        let profileImage = currentState.profileImage
        
        // 닉네임이 비어있는지 확인
        guard !nickname.isEmpty else {
            return Observable.just(.setErrorMessage("닉네임을 입력해주세요."))
        }
        
        return Observable.concat([
            Observable.just(.setLoading(true)),
            networkManager.saveProfile(nickname: nickname, profileImage: profileImage)
                .asObservable()
                .flatMap { response -> Observable<Mutation> in
                    if response.success {
                        return Observable.just(.setProfileSaved)
                    } else {
                        if let errorCode = response.errorCode {
                            let errorMessage = NSLocalizedString(errorCode, tableName: "Error", comment: "")
                            let fallback = String(format: String(localized: "ErrorMessageWithCode", table: "Error"), errorCode)
                            return Observable.just(.setErrorMessage(errorMessage != errorCode ? errorMessage : fallback))
                        } else {
                            return Observable.just(.setErrorMessage(String(localized: "ErrorMessage", table: "Error")))
                        }
                    }
                }
                .catch { error in
                    return Observable.just(.setErrorMessage(String(format: String(localized: "ErrorMessageWithReason", table: "Error"), error.localizedDescription)))
                },
            Observable.just(.setLoading(false))
        ])
    }
}
