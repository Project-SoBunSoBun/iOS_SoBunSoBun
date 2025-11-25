//
//  HomeReactor.swift
//  SoBunSoBun
//
//  Created by 김태은 on 11/17/25.
//

import Foundation
import ReactorKit
import RxSwift

class HomeReactor: Reactor {
    private let disposeBag = DisposeBag()
    let initialState: State = State()
    
    enum Action {
        case initialized
        case addCategoryTapped
        case getSelectedCategories([String])
    }
    
    enum Mutation {
        case verifyLocation(String)
        case setAddCategoryTapped
        case setSelectedCategories([String])
        case setShowLocationSettingAlert
    }
    
    struct State {
        var isLocationVerified: Bool = false
        @Pulse var shouldShowBottomCategorySheet: Void?
        var selectedCategories: [String] = []
        var verifiedLocation: String = "\(String(localized: "Loading"))..."
        @Pulse var shouldShowLocationSettingAlert: Bool = false
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .initialized:
            return currentState.isLocationVerified ? .empty() : verifyLocation()
        case .addCategoryTapped:
            return Observable.just(.setAddCategoryTapped)
        case .getSelectedCategories(let selectedCategories):
            return Observable.just(.setSelectedCategories(selectedCategories))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .verifyLocation(let address):
            newState.verifiedLocation = address
            newState.isLocationVerified = !address.isEmpty && address != String(localized: "Error") && address != String(localized: "LocationPermissionDenied")
        case .setAddCategoryTapped:
            newState.shouldShowBottomCategorySheet = ()
        case .setSelectedCategories(let selectedCategories):
            newState.selectedCategories = selectedCategories
        case .setShowLocationSettingAlert:
            newState.shouldShowLocationSettingAlert = true
        }
        
        return newState
    }
    
    private func verifyLocation() -> Observable<Mutation> {
        return NetworkManager.shared.getLocationVefirication()
            .asObservable()
            .flatMap { model -> Observable<Mutation> in
                if let address = model.address, !model.expired {
                    return Observable.just(.verifyLocation(address))
                } else {
                    return self.getLocation()
                }
            }
            .catch { error in
                print("서버로부터 위치 인증 정보 불러오기 실패: \(error.localizedDescription)")
                return Observable.just(.verifyLocation(String(localized: "Error")))
            }
    }
    
    // 위치 가져오기
    private func getLocation() -> Observable<Mutation> {
        LocationManager.shared.requestCurrentLocation()
        
        return LocationManager.shared.currentLocation
            .compactMap { $0 }
            .take(1) // 1번만
            .timeout(.seconds(10), scheduler: MainScheduler.instance) // 10초 타임아웃
            .flatMap { coords -> Observable<Mutation> in
                return self.getAddressFromGeocoder(latitude: coords.latitude,longitude: coords.longitude)
            }
            .catch { error in
                print("위치 권한 문제: \(error.localizedDescription)")
                return Observable.just(.setShowLocationSettingAlert)
            }
    }
    
    // 지오코더 API 호출
    private func getAddressFromGeocoder(latitude: Double, longitude: Double) -> Observable<Mutation> {
        return NetworkManager.shared.getAddresFromGeocoder(latitude: latitude, longitude: longitude)
            .asObservable()
            .flatMap { model -> Observable<Mutation> in
                let structure = model.response.result[0].structure
                let text = [structure.level1, structure.level2, structure.level3]
                    .joined(separator: " ")
                
                return self.patchLocationVerification(address: text)
            }
            .catch { error in
                print("지오코드 API 호출 실패: \(error.localizedDescription)")
                return Observable.just(.verifyLocation(String(localized: "Error")))
            }
    }
    
    // 위치 인증 갱신
    private func patchLocationVerification(address: String) -> Observable<Mutation> {
        return NetworkManager.shared.patchLocationVerification(address: address)
            .asObservable()
            .map { model -> Mutation in
                if let address = model.address {
                    return .verifyLocation(address)
                } else {
                    print("patch 후에도 address 적용 안 됨")
                    return .verifyLocation(String(localized: "Error"))
                }
            }
            .catch { error in
                print("위치 인증 실패: \(error.localizedDescription)")
                return Observable.just(.verifyLocation(String(localized: "Error")))
            }
    }
}
