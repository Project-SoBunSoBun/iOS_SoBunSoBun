//
//  NicknameReactor.swift
//  SoBunHaeYo
//
//  Created by 허성필 on 10/1/25.
//

import ReactorKit
import Foundation
import RxSwift
import Moya
import RxMoya
import OSLog

class NicknameReactor: Reactor {
    private let logger = Logger(
        subsystem: "SoBunHaeYo",
        category: "Nickname.Reactor"
    )
    
    let initialState = State()
    
    private let disposeBag = DisposeBag()
    
    private let networkManager = SignInNetworkManager()
    
    enum Action {
        case isDuplicationCheckButtonTapped(input: String?) // 중복확인 버튼을 눌렀을 때
        case textFieldChanged(String?) // TextField가 변경 되었을 때
        case textFieldBeginEditing // 중복 확인 후 TextField를 클릭했을 때
    }
    
    enum Mutation {
        case available // 사용 가능할 때
        case unAvailable // 사용중인 상태일 때
        case invalidInput // 텍스트 필드가 비어있을 때 or 유효하지 않은 입력값
        case error // 오류 발생 시
        case setButtonEnabled(Bool) // 중복확인 버튼을 비활성화, 활성화 시키기
        case resetValidation // 중복 검사를 reset
    }
    
    struct State {
        var nickNameAvailable: Bool? // 서버에 통신해서 true, false
        var infoMessage: String? // 안내 메세지, 오류 메세지
        var isButtonEnabled: Bool = false // 중복 검사 버튼 비활성화
        @Pulse var shouldClearText: Bool = false // 텍스트 초기화 플래그
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .isDuplicationCheckButtonTapped(input: let input):
            if let nickname = input {
                // 닉네임 정규식
                let regex = "^[가-힣a-zA-Z0-9]{2,8}$"
                // 닉네임 정규식 검사
                let result = nickname.range(of: regex, options: .regularExpression) != nil
                if result {
                    // 서버와 통신 닉네임 중복 검사
                    return networkManager.checkNickname(nickname: nickname)
                        .asObservable()
                        .flatMap { checkNickname in
                            // infoMessage 출력
                            if checkNickname.available {
                                // 닉네임이 사용 가능할 때
                                return Observable.just(Mutation.available)
                            } else {
                                // 닉네임이 중복일 때
                                return Observable.just(Mutation.unAvailable)
                            }
                        }
                        .catch { [weak self] error in
                            guard let self = self else { return Observable.empty() }
                            
                            // 에러 코드 및 메시지 출력
                            self.logger.critical("통신 에러 발생: \(error.localizedDescription)")
                            return Observable.just(Mutation.error)
                        }
                } else {
                    // 정규식 검사를 통과하지 못했을 때
                    return Observable.just(Mutation.invalidInput)
                }
            } else {
                // TextField가 비어있을 때
                return Observable.just(Mutation.invalidInput)
            }
        case .textFieldChanged(let text):
            // 아무것도 입력하지 않거나 공백만을 입력했을 때 중복확인 버튼을 비활성화
            let isEmpty = (text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            return .just(.setButtonEnabled(!isEmpty))
        case .textFieldBeginEditing:
            return .just(.resetValidation)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .available:
            newState.nickNameAvailable = true
            newState.infoMessage = String(localized: "AvailableNickname", table: "Common")
        case .unAvailable:
            newState.nickNameAvailable = false
            newState.infoMessage = String(localized: "UnavailableNickname", table: "Common")
        case .invalidInput:
            newState.nickNameAvailable = false
            newState.infoMessage = String(localized: "DenyNicknameInput", table: "Common")
        case .error:
            newState.nickNameAvailable = false
            newState.infoMessage = String(localized: "ErrorMessage", table: "Common")
        case .setButtonEnabled(let isEnabled):
            newState.isButtonEnabled = isEnabled
        case .resetValidation:
            if let isAvailable = newState.nickNameAvailable, isAvailable {
                newState.nickNameAvailable = nil
                newState.infoMessage = ""
                newState.shouldClearText = true
                newState.isButtonEnabled = false
            } else {
                newState.shouldClearText = false
            }
        }
        return newState
    }
}
