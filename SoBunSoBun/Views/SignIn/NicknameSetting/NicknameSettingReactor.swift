//
//  NicknameSettingReactor.swift
//  SoBunSoBun
//
//  Created by 허성필 on 10/23/25.
//

import UIKit
import ReactorKit
import Moya
import RxSwift
import OSLog

class NicknameSettingReactor: Reactor {
    private let logger = Logger(
        subsystem: "SoBunSoBun",
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
        case setError(String)
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
            
        case .setError(let message):
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
            return Observable.just(.setError("닉네임을 입력해주세요."))
        }
        
        return Observable.concat([
            Observable.just(.setLoading(true)),
            networkManager.saveProfile(nickname: nickname, profileImage: profileImage)
                .asObservable()
                .flatMap { _ -> Observable<Mutation> in
                    return Observable.just(.setProfileSaved)
                }
                .catch { error in
                    let errorMessage = self.handleError(error)
                    return Observable.just(.setError(errorMessage))
                },
            Observable.just(.setLoading(false))
        ])
    }
    
    private func handleError(_ error: Error) -> String {
        if let moyaError = error as? MoyaError {
            switch moyaError {
            case .statusCode(let response):
                if (400...499).contains(response.statusCode) {
                    self.logger.fault("에러 코드 출력: \(response.statusCode)")
                    return "잘못된 요청입니다. 입력 정보를 확인해주세요."
                } else if response.statusCode >= 500 {
                    self.logger.critical("에러 코드 출력: \(response.statusCode)")
                    return "서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요."
                }
            default:
                break
            }
        }
        return "프로필 저장에 실패했습니다. 다시 시도해주세요."
    }
}
