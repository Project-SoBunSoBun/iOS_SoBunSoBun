//
//  InquiriesReactor.swift
//  SoBunHaeYo
//
//  Created by 허성필 on 2/20/26.
//

import ReactorKit
import OSLog
import UIKit

class InquiriesReactor: Reactor {
    private let logger = Logger(
        subsystem: "SoBunHaeYo",
        category: "Settings.Inquiries.Reactor"
    )
    
    let initialState = State()
    let networkManager = SettingNetworkManager()
    
    enum Action {
        // 문의 내용 메뉴 선택시
        case menuBoxTapped(Bool)
        // 드랍 다운 메뉴 선택시
        case dropDownCellTapped(Int)
        // 문의 내용 변경시
        case detailChanged(String)
        // 이미지 피커 선택시
        case selectImageTapped
        // 이미지 선택 완료시
        case inquiriesImageSelected([UIImage])
        // 이미지 삭제 버튼 선택시
        case deleteImage(Int)
        // 이메일 입력
        case emailChanged(String)
        // 동의 체크박스 선택시
        case agreeCheckBoxTapped(Bool)
        // 문의하기 버튼 선택시
        case inquiriesButtonTapped
    }
    
    enum Mutation {
        // 문의 내용 메뉴 선택시
        case setIsMenuOpen(Bool)
        // 드롭 다운 메뉴 선택시
        case setMenuNumber(Int)
        // 문의 내용 변경시
        case setDetail(String)
        // 이미지 피커 선택시
        case showImagePicker
        // 이미지 선택 완료시
        case appendImage([UIImage])
        // 이미지 삭제 버튼 선택시
        case removeImage(Int)
        // 이메일 입력
        case setEmail(String)
        // 동의 체크박스 선택시
        case setIsAgree(Bool)
        // 로딩 상태
        case setLoading(Bool)
        // 문의 전송 성공
        case setInquiriesCompleted
        // 에러
        case setErrorMessage(String)
    }
    
    struct State {
        var isMenuOpen: Bool = false
        var menuNumber: Int?
        var isAgree: Bool = false
        var detailString: String?
        
        @Pulse var shouldShowImagePicker: Void?
        var selectedImages: [UIImage] = []
        
        var emailString: String?
        var isLoading: Bool = false
        @Pulse var inquiriesCompleted: Void?
        @Pulse var errorMessage: String?
        
        // 버튼 활성화 여부
        var isButtonEnabled: Bool {
            let isMenuSelected = menuNumber != nil
            let isDetailInputted = !(detailString?.isEmpty ?? true)
            let isEmailInputted = !(emailString?.isEmpty ?? true)
            
            return isMenuSelected && isAgree && isDetailInputted && isEmailInputted && !isLoading
        }
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .menuBoxTapped(let isMenuOpen):
            return Observable.just(.setIsMenuOpen(isMenuOpen))
            
        case .dropDownCellTapped(let menuNumber):
            return Observable.just(.setMenuNumber(menuNumber))
            
        case .detailChanged(let detail):
            return Observable.just(.setDetail(detail))
            
        case .selectImageTapped:
            return Observable.just(.showImagePicker)
            
        case .inquiriesImageSelected(let images):
            return Observable.just(.appendImage(images))
            
        case .deleteImage(let index):
            return Observable.just(.removeImage(index))
            
        case .emailChanged(let email):
            return Observable.just(.setEmail(email))
            
        case .agreeCheckBoxTapped(let isAgree):
            return Observable.just(.setIsAgree(isAgree))
            
        case .inquiriesButtonTapped:
            return Observable.concat([
                Observable.just(.setLoading(true)),
                inquiries(),
                Observable.just(.setLoading(false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setIsMenuOpen(let isMenuOpen):
            newState.isMenuOpen = isMenuOpen
            
        case .setMenuNumber(let menuNumber):
            newState.menuNumber = menuNumber
            
        case .setDetail(let detail):
            newState.detailString = detail
            
        case .showImagePicker:
            newState.shouldShowImagePicker = ()
            
        case .appendImage(let images):
            newState.selectedImages.append(contentsOf: images)
            
        case .removeImage(let index):
            if newState.selectedImages.indices.contains(index) {
                newState.selectedImages.remove(at: index)
            }
            
        case .setEmail(let email):
            newState.emailString = email
            
        case .setIsAgree(let isAgree):
            newState.isAgree = isAgree
            
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
            
        case .setInquiriesCompleted:
            newState.inquiriesCompleted = ()
            
        case .setErrorMessage(let message):
            newState.errorMessage = message
        }
        
        return newState
    }
    
    private func inquiries() -> Observable<Mutation> {
        guard let menuNumber = currentState.menuNumber else {
            logger.error("문의 사유가 선택되지 않음")
            
            return Observable.just(.setErrorMessage(String(localized: "SelectInquiries", table: "Settings")))
        }
        
        let typeCode = String(format: "%03d", menuNumber)
        let content = currentState.detailString ?? ""
        
        guard let replyEmail = currentState.emailString, !replyEmail.isEmpty else {
            return Observable.just(.setErrorMessage(String(localized: "PleaseInputEmail", table: "Settings")))
        }
        
        guard isValidEmail(replyEmail) else {
            return Observable.just(.setErrorMessage(String(localized: "InvalidEmailFormat", table: "Settings")))
        }
        
        let selectedImages = currentState.selectedImages
        
        return networkManager.postInquiries(
            typeCode: typeCode,
            content: content,
            replyEmail: replyEmail,
            selectedImages: selectedImages
        )
        .asObservable()
        .flatMap { response -> Observable<Mutation> in
            self.logger.debug("문의 전송 완료")
            
            if response.success {
                return Observable.just(.setInquiriesCompleted)
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
            self.logger.debug("문의 전송 에러: \(error)")
            
            return Observable.just(.setErrorMessage(String(format: String(localized: "ErrorMessageWithReason", table: "Error"), error.localizedDescription)))
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        return email.range(of: emailRegEx, options: .regularExpression) != nil
    }
}
