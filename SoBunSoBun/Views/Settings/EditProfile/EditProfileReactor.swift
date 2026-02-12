//
//  EditProfileReactor.swift
//  SoBunSoBun
//
//  Created by 허성필 on 2/3/26.
//

import UIKit
import ReactorKit
import RxSwift
import Moya
import OSLog

class EditProfileReactor: Reactor {
    private let logger = Logger(
        subsystem: "SoBunSoBun", 
        category: "Settings.EditProfile.Reactor"
    )
    
    let initialState = State()
    private let disposeBag = DisposeBag()
    
    enum Action {
        case cameraImageTapped
        case nicknameChanged(String)
        case profileImageSelected(UIImage)
        case completeButtonTapped
        case isNicknameEmpty
    }
    
    enum Mutation {
        case showImagePicker
        case setNickname(String?)
        case setProfileImage(UIImage)
        case setCompleteButtonEnabled(Bool)
        case setError(String)
        case setProfileSaved
    }
    
    struct State {
        var isCompleteButtonEnabled: Bool = false
        var nickname: String?
        var profileImage: UIImage?
        @Pulse var shouldShowImagePicker: Void?
        @Pulse var errorMessage: String?
        @Pulse var profileSaved: Void?
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .cameraImageTapped:
            return Observable.just(.showImagePicker)
            
        case .nicknameChanged(let nickname):
            return Observable.concat([
                Observable.just(.setNickname(nickname)),
                Observable.just(.setCompleteButtonEnabled(true))
            ])
            
        case .profileImageSelected(let image):
            return Observable.concat([
                Observable.just(.setProfileImage(image)),
                Observable.just(.setCompleteButtonEnabled(true))
            ])
            
        case .completeButtonTapped:
            return determineApiCall()
            
        case .isNicknameEmpty:
            let profileImage = currentState.profileImage
            
            return Observable.concat([
                Observable.just(.setNickname(nil)),
                Observable.just(.setCompleteButtonEnabled(profileImage != nil))
            ])    
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation{
        case .showImagePicker:
            newState.shouldShowImagePicker = ()
            
        case .setNickname(let nickname):
            newState.nickname = nickname
            
        case .setProfileImage(let image):
            newState.profileImage = image
            
        case .setCompleteButtonEnabled(let enabled):
            newState.isCompleteButtonEnabled = enabled
        
        case .setError(let message):
            newState.errorMessage = message
            
        case .setProfileSaved:
            newState.profileSaved = ()
        }
        
        return newState
    }
    
    // 변경 사항에 따른 API 호출
    private func determineApiCall() -> Observable<Mutation> {
        let nickname = currentState.nickname
        let profileImage = currentState.profileImage
        
        if nickname != nil && profileImage != nil {
            logger.debug("닉네임과 프로필 이미지 모두 변경됨")
            return saveProfileImageAndNickname()
        } else if nickname != nil && profileImage == nil {
            logger.debug("닉네임만 변경됨")
            return saveNickname()
        } else if nickname == nil && profileImage != nil {
            logger.debug("프로필 이미지만 변경됨")
            return saveProfileImage()
        } else {
            logger.debug("변경 사항 없음")
            return Observable.just(.setError("변경된 내용이 없습니다."))
        }
    }
    
    // 프로필 이미지만 변경
    private func saveProfileImage() -> Observable<Mutation> {
        guard let profileImage = currentState.profileImage else {
            return Observable.empty()
        }
        
        return NetworkManager.shared.patchProfileImage(profileImage: profileImage)
            .asObservable()
            .flatMap { _ -> Observable<Mutation> in
                return Observable.just(.setProfileSaved)
            }
            .catch { error in
                return Observable.just(.setError(error.localizedDescription))
            }
    }
    
    // 닉네임만 변경
    private func saveNickname() -> Observable<Mutation> {
        guard let nickname = currentState.nickname else { return Observable.empty() }
        
        return NetworkManager.shared.patchNickname(nickname: nickname)
            .asObservable()
            .flatMap { _ -> Observable<Mutation> in
                return Observable.just(.setProfileSaved)
            }
            .catch { error in
                return Observable.just(.setError(error.localizedDescription))
            }
    }
    
    // 프로필 이미지와 닉네임 모두 변경
    private func saveProfileImageAndNickname() -> Observable<Mutation> {
        guard let nickname = currentState.nickname else { return Observable.empty() }
        let profileImage = currentState.profileImage
        
        return NetworkManager.shared.saveProfile(nickname: nickname, profileImage: profileImage)
            .asObservable()
            .flatMap { _ -> Observable<Mutation> in
                return Observable.just(.setProfileSaved)
            }
            .catch { error in
                return Observable.just(.setError(error.localizedDescription))
            }
    }
    
}
