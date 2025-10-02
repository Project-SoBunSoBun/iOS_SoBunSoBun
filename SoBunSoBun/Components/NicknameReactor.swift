//
//  NicknameReactor.swift
//  SoBunSoBun
//
//  Created by 허성필 on 10/1/25.
//

import ReactorKit
import Foundation
import RxSwift
import Moya
import RxMoya

class NicknameReactor: Reactor {
    let initialState = State()
    
    private let disposeBag = DisposeBag()
    
    enum Action {
        case isDuplicationCheckButtonTapped(input: String?) // 중복확인 버튼을 눌렀을 때
    }
    
    enum Mutation {
        case available // 사용 가능할 때
        case unAvailable // 사용중인 상태일 때
        case invalidInput // 텍스트 필드가 비어있을 때 or 유효하지 않은 입력값
        case error // 오류 발생 시
    }
    
    struct State {
        var inputStatus: Bool? // 정규식 검사 상태 true, false
        var nickNameAvailable: Bool? // 서버에 통신해서 true, false
        var infoMessage: String? // 안내 메세지, 오류 메세지
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .isDuplicationCheckButtonTapped(input: let input):
            if let nickname = input {
                let regex = "^[가-힣a-zA-Z0-9]{2,8}$" // 닉네임 정규식
                let result = nickname.range(of: regex, options: .regularExpression) != nil // 닉네임 정규식 검사
                if result {
                    // 서버 통신
                    return NetworkManager.shared.checkNickname(nickname: nickname) // 서버와 통신 닉네임 중복 검사
                        .asObservable()
                        .flatMap { checkNickname in
                            // infoMessage 출력 (ex. 사용 가능한 닉네임 or 이미 사용 중인 닉네임)
                            if checkNickname.available {
                                return Observable.just(Mutation.available) // 닉네임이 사용 가능할 때
                            } else {
                                return Observable.just(Mutation.unAvailable) // 닉네임이 중복일 때
                            }
                        }
                        .catch { error in
                            print("통신 에러 발생:", error.localizedDescription)  // 에러 코드 및 메시지 출력
                            return Observable.just(Mutation.error) // 에러 시 Mutation 반환 예시
                        }
                } else {
                    // infoMessage 출력 (ex. 2-8자로 한글.... 입력 가능합니다)
                    // Invalid input
                    return Observable.just(Mutation.invalidInput)
                }
            } else { // infoMessage 출력 (ex. 닉네임을 적어주세요)
                // empty
                return Observable.just(Mutation.invalidInput)
            }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .available:
            newState.inputStatus = true
            newState.infoMessage = String(localized: "AvailableNickname") // 다국어 지원
            newState.nickNameAvailable = true
        case .unAvailable:
            newState.inputStatus = true
            newState.infoMessage = String(localized: "Unavailable") // 다국어 지원
            newState.nickNameAvailable = false
        case .invalidInput:
            newState.inputStatus = false
            newState.infoMessage = ""
            newState.nickNameAvailable = nil
        case .error:
            newState.inputStatus = true
            newState.infoMessage = String(localized: "Error") // 다국어 지원
            newState.nickNameAvailable = false
        }
        return newState
    }
}
