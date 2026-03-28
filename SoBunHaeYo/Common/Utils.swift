//
//  Utils.swift
//  SoBunHaeYo
//
//  Created by 허성필 on 9/5/25.
//

import Foundation
import UIKit
import OSLog
import RxSwift
import RxCocoa

// window
var currentWindow: UIWindow? {
    let windowScene = UIApplication.shared.connectedScenes
        .filter { $0.activationState == .foregroundActive }
        .first { $0 is UIWindowScene } as? UIWindowScene
    
    return windowScene?.windows.first { $0.isKeyWindow }
}

// API URL
let API_URL = Bundle.main.object(forInfoDictionaryKey: "API_URL") as! String

// ISO8601 Datetime에서 Date형 변환
func ISO8601ToDate(_ iso8601DatetimeString: String) -> Date? {
    let isoFormatter = ISO8601DateFormatter()
    
    if let date = isoFormatter.date(from: iso8601DatetimeString) {
        return date
    }
    
    let fallbackFormatter = DateFormatter()
    fallbackFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    fallbackFormatter.timeZone = .current
    
    return fallbackFormatter.date(from: iso8601DatetimeString)
}

// ISO8601 Datetime에서 현지화 Datetime 문자열 변환
func ISO8601ToLocalizedDateTimeString(_ iso8601DatetimeString: String) -> String {
    let logger = Logger(
        subsystem: "SoBunHaeYo",
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
            formattedString.replacingOccurrences(of: ":", with: String(localized: "TimeHour", table: "Home") + " ")
            + String(localized: "TimeMinute", table: "Home")
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
        subsystem: "SoBunHaeYo",
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
        subsystem: "SoBunHaeYo",
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

// ISO8601 DateTime에서 날짜/시간에 적응하는 포맷으로
func ISO8601ToAdaptiveDateString(_ iso8601DatetimeString: String) -> String {
    let logger = Logger(
        subsystem: "SoBunHaeYo",
        category: "Utils"
    )
    
    guard let date = ISO8601ToDate(iso8601DatetimeString) else {
        logger.fault("isoFormatter.date 생성 중 오류 발생: \(iso8601DatetimeString)")
        return ""
    }
    
    let formatter = DateFormatter()
    formatter.locale = Locale.current
    
    if Calendar.current.isDateInToday(date) {
        formatter.timeStyle = .short
        formatter.dateStyle = .none
    } else {
        formatter.setLocalizedDateFormatFromTemplate("MMMd")
    }
    
    return formatter.string(from: date)
}

// String 타입에서 Date 타입 변환
func stringToDate(string: String, format: String) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    dateFormatter.locale = Locale.current
    
    return dateFormatter.date(from: string)
}

// Date 타입에서 String 타입 변환
func dateToString(date: Date, format: String) -> String? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    dateFormatter.locale = Locale.current
    
    return dateFormatter.string(from: date)
}

// Date 타입에서 ISO8601 형태 String 타입 변환
func dateToISO8601String(date: Date) -> String? {
    let dateFormatter = ISO8601DateFormatter()
    dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    
    return dateFormatter.string(from: date)
}

extension Encodable {
    /// Encodable을 Dictionary 타입으로 변환
    func toDictionary() -> [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        guard let dictionary = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }
        
        return dictionary
    }
}

extension Reactive where Base: UITextField {
    /// 천 단위 콤마가 포함된 숫자 텍스트로 변환
    var formattedNumericText: ControlProperty<String> {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.maximumFractionDigits = 0
        
        let source = base.rx.text.orEmpty
            .map { [weak base] text -> String in
                guard let base = base else { return "" }
                
                let numbers = text.filter { $0.isNumber }
                
                guard !numbers.isEmpty, let value = Int(numbers) else {
                    if base.text != "" {
                        base.text = ""
                    }
                    
                    return ""
                }
                
                let formatted = formatter.string(from: NSNumber(value: value)) ?? numbers
                
                if base.text != formatted {
                    base.text = formatted
                }
                
                return numbers
            }
        
        let observer = Binder<String>(base) { textField, text in
            let numbers = text.filter { $0.isNumber }
            guard !numbers.isEmpty, let value = Int(numbers) else {
                if textField.text != "" {
                    textField.text = ""
                }
                
                return
            }
            
            let formatted = formatter.string(from: NSNumber(value: value)) ?? numbers
            if textField.text != formatted {
                textField.text = formatted
            }
        }
        
        return ControlProperty(values: source, valueSink: observer)
    }
}

extension UIImage {
    /// 이미지 리사이즈
    func resize(_ newSize: CGSize) -> UIImage {
        let image = UIGraphicsImageRenderer(size: newSize).image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
        
        return image.withRenderingMode(renderingMode)
    }
}

extension String {
    /// 줄바꿈 개수 제한
    func limitNewLines(limit: Int = 2) -> String {
        let pattern = "\n{\(limit + 1),}"
        let replacement = String(repeating: "\n", count: limit)
        
        return self.replacingOccurrences(
            of: pattern,
            with: replacement,
            options: .regularExpression
        )
    }
}

extension PrimitiveSequence where Trait == SingleTrait, Element == Response {
    /// Model Decode 실패 시 Data 로그를 추가로 출력합니다.
    func tryMap<T: Decodable>(_ type: T.Type) -> Single<T> {
        let logger = Logger(
            subsystem: "SoBunHaeYo",
            category: "MoyaNetworkManager.tryMap"
        )
        
        return flatMap { response in
            do {
                return .just(try response.map(type))
            } catch {
                if let json = try? JSONSerialization.jsonObject(with: response.data),
                   let pretty = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
                   let str = String(data: pretty, encoding: .utf8) {
                    logger.critical("[Decode 오류]\n\ntype: \(type)\nresponse: \(str)")
                } else {
                    logger.critical("[Decode 오류]\n\ntype: \(type)\nresponse(raw): \(String(data: response.data, encoding: .utf8) ?? "String 변환 실패")")
                }
                throw error
            }
        }
    }
}

// 미리보기
#if DEBUG
import SwiftUI
import Moya

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
