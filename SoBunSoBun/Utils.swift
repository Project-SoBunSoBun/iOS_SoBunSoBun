//
//  Utils.swift
//  SoBunSoBun
//
//  Created by 허성필 on 9/5/25.
//

import Foundation
import UIKit

// API URL
let API_URL = Bundle.main.object(forInfoDictionaryKey: "API_URL") as! String

// 재발급 중
var isRefreshing: Bool = false

// 문자열에서 날짜 변환(토큰 만료 시간 계산에만 사용)
func stringToDate(string: String, format: String) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    dateFormatter.locale = Locale(identifier: "ko_KR")
    
    return dateFormatter.date(from: string)!
}

// 날짜에서 문자열 변환(토큰 만료 시간 계산에만 사용)
func dateToString(date: Date, format: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    dateFormatter.locale = Locale(identifier: "ko_KR")
    
    return dateFormatter.string(from: date)
}

// ISO8601 Datetime에서 현지화 Datetime 문자열 변환
func ISO8601ToLocalizedDateTimeString(_ iso8601DatetimeString: String, isFormatColon: Bool = true) -> String {
    let isoFormatter = ISO8601DateFormatter()
    isoFormatter.formatOptions = [.withFullDate, .withFullTime]
    
    if let date = isoFormatter.date(from: iso8601DatetimeString) {
        let dateFormatter = DateFormatter()
        let calendar = Calendar.current
        let minutes = calendar.component(.minute, from: date)
        
        if isFormatColon {
            dateFormatter.setLocalizedDateFormatFromTemplate("MMMd (E) a hh:mm")
            return dateFormatter.string(from: date)
        } else {
            if minutes == 0 {
                dateFormatter.setLocalizedDateFormatFromTemplate("MMMd (E) a h")
                return dateFormatter.string(from: date)
            } else {
                dateFormatter.setLocalizedDateFormatFromTemplate("MMMd (E) a h:mm")
                return dateFormatter.string(from: date)
                    .replacingOccurrences(of: ":", with: String(localized: "TimeHour") + " ")
                + String(localized: "TimeMinute")
            }
        }
    } else {
        print("isoFormatter.date 생성 중 오류 발생")
        return "Error!"
    }
}

// ISO8601 Datetime에서 D-Day 계산
func ISO8601ToDDay(_ iso8601DatetimeString: String) -> String {
    let isoFormatter = ISO8601DateFormatter()
    isoFormatter.formatOptions = [.withFullDate, .withFullTime]
    
    if let date = isoFormatter.date(from: iso8601DatetimeString) {
        let calendar = Calendar.current
        let now = calendar.startOfDay(for: Date())
        let targetDay = calendar.startOfDay(for: date)
        
        let components = calendar.dateComponents([.day], from: now, to: targetDay)
        guard let day = components.day else {
            print("components.day 생성 중 오류 발생")
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
        print("isoFormatter.date 생성 중 오류 발생")
        return "Error!"
    }
}

func ISO8601ToRelativeString(_ iso8601DatetimeString: String) -> String {
    let isoFormatter = ISO8601DateFormatter()
    isoFormatter.formatOptions = [.withFullDate, .withFullTime]
    
    if let date = isoFormatter.date(from: iso8601DatetimeString) {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale.current
        formatter.unitsStyle = .short
        formatter.dateTimeStyle = .named
        
        return formatter.localizedString(for: date, relativeTo: Date())
    } else {
        print("isoFormatter.date 생성 중 오류 발생")
        return "Error!"
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
