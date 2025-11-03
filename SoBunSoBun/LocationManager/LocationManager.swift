//
//  LocationManager.swift
//  SoBunSoBun
//
//  Created by 허성필 on 10/17/25.
//

import UIKit
import CoreLocation
import RxSwift
import RxCocoa

class LocationManager: NSObject {
    static let shared = LocationManager()
    
    private let locationManager = CLLocationManager()
    private let authorizationStatus = BehaviorRelay<CLAuthorizationStatus>(value: .notDetermined)
    
    var currentAuthorizationStatus: Observable<CLAuthorizationStatus> {
        return authorizationStatus.asObservable()
    }
    
    private override init() {
        super.init()
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // 초기 상태 설정
        if #available(iOS 14.0, *) {
            authorizationStatus.accept(locationManager.authorizationStatus)
        } else {
            authorizationStatus.accept(CLLocationManager.authorizationStatus())
        }
    }
    
    // 권한 요청하기
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    // 권한 상태 가져오기
    func getCurrentAuthorizationStatus() -> CLAuthorizationStatus {
        if #available(iOS 14.0, *) {
            return locationManager.authorizationStatus
        } else {
            return CLLocationManager.authorizationStatus()
        }
    }
    
    func isLocationAuthorized() -> Bool {
        let status = getCurrentAuthorizationStatus()
        return status == .authorizedWhenInUse || status == .authorizedAlways
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus.accept(status)
    }
    
    // iOS 14 이상
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if #available(iOS 14.0, *) {
            authorizationStatus.accept(manager.authorizationStatus)
        }
    }
}
