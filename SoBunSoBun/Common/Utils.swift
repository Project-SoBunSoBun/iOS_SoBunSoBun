//
//  Utils.swift
//  SoBunSoBun
//
//  Created by 허성필 on 9/5/25.
//

import Foundation
import UIKit
import OSLog

// safearea
let scenes = UIApplication.shared.connectedScenes
let windowScene = scenes.first as? UIWindowScene
let window = windowScene?.windows.first

let safeareaTop = window?.safeAreaInsets.top ?? 0
let safeareaBottom = window?.safeAreaInsets.bottom ?? 0

// API URL
let API_URL = Bundle.main.object(forInfoDictionaryKey: "API_URL") as! String

// 재발급 중
var isRefreshing: Bool = false

// ISO8601 Datetime에서 Date형 변환
func ISO8601ToDate(_ iso8601DatetimeString: String) -> Date? {
    let isoFormatter = ISO8601DateFormatter()
    isoFormatter.formatOptions = [.withFullDate, .withFullTime]
    
    return isoFormatter.date(from: iso8601DatetimeString)
}

// ISO8601 Datetime에서 현지화 Datetime 문자열 변환
func ISO8601ToLocalizedDateTimeString(_ iso8601DatetimeString: String) -> String {
    let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "Utils"
    )

    if let date = ISO8601ToDate(iso8601DatetimeString) {
        let calendar = Calendar.current
        let minutes = calendar.component(.minute, from: date)
        
        let dateFormatter = DateFormatter()
        let template = minutes == 0 ? "MMMd (E) a h" : "MMMd (E) a h:mm"
        dateFormatter.setLocalizedDateFormatFromTemplate(template)
        let formattedString = dateFormatter.string(from: date)
        
        switch Locale.current.language.languageCode?.identifier {
        case "ko":
            return minutes == 0 ?
                    formattedString :
                    formattedString.replacingOccurrences(of: ":", with: String(localized: "TimeHour") + " ")
                    + String(localized: "TimeMinute")
        default:
            return formattedString
        }
    } else {
        logger.fault("isoFormatter.date 생성 중 오류 발생: \(iso8601DatetimeString)")
        return "Error!"
    }
}

// ISO8601 Datetime에서 D-Day 계산
func ISO8601ToDDay(_ iso8601DatetimeString: String) -> String {
    let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "Utils"
    )
    
    if let date = ISO8601ToDate(iso8601DatetimeString) {
        let calendar = Calendar.current
        let now = calendar.startOfDay(for: Date())
        let targetDay = calendar.startOfDay(for: date)
        
        let components = calendar.dateComponents([.day], from: now, to: targetDay)
        guard let day = components.day else {
            logger.fault("components.day 생성 중 오류 발생: \(iso8601DatetimeString)")
            return "Error!"
        }
        
        if day > 0 {
            return "D-\(day)"
        } else if day == 0 {
            return "D-Day"
        } else {
            return "D+\(-day)"
        }
    } else {
        logger.fault("isoFormatter.date 생성 중 오류 발생: \(iso8601DatetimeString)")
        return "Error!"
    }
}

func ISO8601ToRelativeString(_ iso8601DatetimeString: String) -> String {
    let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "Utils"
    )
    
    if let date = ISO8601ToDate(iso8601DatetimeString) {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale.current
        formatter.unitsStyle = .short
        formatter.dateTimeStyle = .named
        
        return formatter.localizedString(for: date, relativeTo: Date())
    } else {
        logger.fault("isoFormatter.date 생성 중 오류 발생: \(iso8601DatetimeString)")
        return "Error!"
    }
}

// 위치 권한 설정 알림창
func showLocationSettingAlert(_ vc: UIViewController) {
    let alert = CustomAlertView(
        title: String(localized: "LocationSettingTitle")
    )
    
    alert.onPrimaryTapped = {
        // 설정 앱으로 이동
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
    
    alert.onCancelTapped = {
        
    }
    
    alert.show(on: vc)
}

extension Encodable {
    func toDictionary() -> [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        guard let dictionary = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }
        
        return dictionary
    }
}

// 미리보기
#if DEBUG
import SwiftUI

struct UIViewControllerPreview: UIViewControllerRepresentable {
    let viewController: () -> UIViewController
    
    init(_ viewController: @escaping () -> UIViewController) {
        self.viewController = viewController
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        return viewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
#endif
