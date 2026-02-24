//
//  BugReportReactor.swift
//  SoBunSoBun
//
//  Created by 허성필 on 2/20/26.
//

import ReactorKit
import OSLog
import UIKit

class BugReportReactor: Reactor {
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "Settings.BugReport.Reactor"
    )
    
    let initialState = State()
    let networkManager = SettingNetworkManager()
    
    enum Action {
        // 버그 발생 위치 메뉴 선택시
        case menuBoxTapped(Bool)
        // 드랍 다운 메뉴 선택시
        case dropDownCellTapped(Int)
        // 문의 내용 변경시
        case detailChanged(String)
        // 이미지 피커 선택시
        case selectedImageTapped
        // 이미지 선택 완료시
        case bugImageSelected(UIImage)
        // 이미지 삭제 버튼 선택시
        case deleteImage(Int)
        // 동의 체크박스 선택시
        case agreeCheckBoxTapped(Bool)
        // 신고하기 버튼 선택시
        case bugReportButtonTapped
    }
    
    enum Mutation {
        // 버그 발생 위치 메뉴 선택시
        case setIsMenuOpen(Bool)
        // 드롭 다운 메뉴 선택시
        case setMenuNumber(Int)
        // 문의 내용 변경시
        case setDetail(String)
        // 이미지 피커 선택시
        case showImagePicker
        // 이미지 선택 완료시
        case appendImage(UIImage)
        // 이미지 삭제 버튼 선택시
        case removeImage(Int)
        // 동의 체크박스 선택시
        case setIsAgree(Bool)
        // 로딩 상태
        case setLoading(Bool)
        // 신고하기 전송 성공
        case setBugReportCompleted
        // 에러
        case setError(String)
    }
    
    struct State {
        var isMenuOpen: Bool = false
        var menuNumber: Int?
        var detailString: String?
        
        @Pulse var shouldShowIamgePicker: Void?
        var selectedImages: [UIImage] = []
        
        var isAgree: Bool = false
        var isLoading: Bool = false
        @Pulse var bugReportCompleted: Void?
        @Pulse var errorMessage: String?
        
        // 버튼 활성화 여부
        var isButtonEnabled: Bool {
            let isMenuSelected = menuNumber != nil
            let isDetailInputted = !(detailString?.isEmpty ?? true)
            
            return isMenuSelected && isAgree && isDetailInputted && !isLoading
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
            
        case .selectedImageTapped:
            return Observable.just(.showImagePicker)
            
        case .bugImageSelected(let image):
            return Observable.just(.appendImage(image))
            
        case .deleteImage(let index):
            return Observable.just(.removeImage(index))
            
        case .agreeCheckBoxTapped(let isAgree):
            return Observable.just(.setIsAgree(isAgree))
            
        case .bugReportButtonTapped:
            return Observable.concat([
                Observable.just(.setLoading(true)),
                bugReport(),
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
            newState.shouldShowIamgePicker = ()
            
        case .appendImage(let image):
            newState.selectedImages.append(image)
            
        case .removeImage(let index):
            if newState.selectedImages.indices.contains(index) {
                newState.selectedImages.remove(at: index)
            }
            
        case .setIsAgree(let isAgree):
            newState.isAgree = isAgree
            
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
            
        case .setBugReportCompleted:
            newState.bugReportCompleted = ()
            
        case .setError(let message):
            newState.errorMessage = message
        }
        
        return newState
    }
    
    private func bugReport() -> Observable<Mutation> {
        guard let menuNumber = currentState.menuNumber else {
            logger.error("문의 사유가 선택되지 않음")
            
            return Observable.just(.setError(String(localized: "SelectBugLocation", table: "Settings")))
        }
        
        let typeCode = String(format: "%03d", menuNumber)
        let content = currentState.detailString ?? ""
        
        let deviceModel = UIDevice.current.name // ex) iPhone 12 mini
        let deviceOS = UIDevice.current.systemName // ex) iOS
        let deviceVersion = UIDevice.current.systemVersion // ex) 18.2
        let deviceInfo = "\(deviceModel) / \(deviceOS) \(deviceVersion)"
        
        let selectedImages = currentState.selectedImages
        
        return networkManager.postBugReport(
            typeCode: typeCode,
            content: content,
            deviceInfo: deviceInfo,
            selectedImages: selectedImages
        )
        .asObservable()
        .flatMap { _ -> Observable<Mutation> in
            self.logger.debug("버그 신고 완료")
            
            return Observable.just(.setBugReportCompleted)
        }
        .catch { error in
            self.logger.debug("버그 신고 에러: \(error)")
            
            return Observable.just(.setError(error.localizedDescription))
        }
    }
}
