//
//  LocationManager.swift
//  SoBunHaeYo
//
//  Created by 허성필 on 10/17/25.
//

import UIKit
import CoreLocation
import RxSwift
import RxCocoa
import OSLog

final class LocationManager: NSObject {
    static let shared = LocationManager()
    
    private override init() {
        super.init()
        
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // 초기 상태 설정
        authorizationStatus.accept(locationManager.authorizationStatus)
    }
    
    private let logger = Logger(
        subsystem: "SoBunHaeYo",
        category: "LocationManager"
    )
    
    private let locationManager = CLLocationManager()
    
    private let authorizationStatus = BehaviorRelay<CLAuthorizationStatus>(value: .notDetermined)
    var currentAuthorizationStatus: Observable<CLAuthorizationStatus> {
        return authorizationStatus.asObservable()
    }
    
    private let currentLocationRelay = BehaviorRelay<CLLocationCoordinate2D?>(value: nil)
    var currentLocation: Observable<CLLocationCoordinate2D?> {
        return currentLocationRelay.asObservable()
    }
    
    // 권한 요청하기
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    // 권한 상태 가져오기
    func getCurrentAuthorizationStatus() -> CLAuthorizationStatus {
        return locationManager.authorizationStatus
    }
    
    func isLocationAuthorized() -> Bool {
        let status = getCurrentAuthorizationStatus()
        return status == .authorizedWhenInUse || status == .authorizedAlways
    }
    
    // 위치 가져오기
    func requestCurrentLocation() {
        guard isLocationAuthorized() else {
            logger.fault("위치 권한 없음")
            requestLocationPermission()
            return
        }
        
        locationManager.requestLocation()
    }
    
    // 좌표 가져오기
    func getCurrentCoordinate() -> CLLocationCoordinate2D? {
        return currentLocationRelay.value
    }
    
}

extension LocationManager: CLLocationManagerDelegate {
    // 권한 업데이트
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus.accept(status)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus.accept(manager.authorizationStatus)
    }
    
    // 위치 업데이트
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        let coordinate = location.coordinate
        
        currentLocationRelay.accept(coordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        logger.fault("위치 가져오기 실패: \(error.localizedDescription)")
        
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                logger.fault("위치 권한 거부됨")
            case .locationUnknown:
                logger.fault("위치를 확인할 수 없음")
            default:
                logger.fault("기타 위치 오류: \("\(clError.code)")")
            }
        }
    }
}
