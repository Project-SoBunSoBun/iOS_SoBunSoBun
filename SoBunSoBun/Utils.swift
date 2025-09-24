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

// 문자열에서 날짜 계산
func stringToDate(string: String, format: String) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    dateFormatter.locale = Locale(identifier: "ko_KR")
    dateFormatter.amSymbol = "오전"
    dateFormatter.pmSymbol = "오후"
    
    return dateFormatter.date(from: string)!
}

// 날짜에서 문자열 계산
func dateToString(date: Date, format: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    dateFormatter.locale = Locale(identifier: "ko_KR")
    dateFormatter.amSymbol = "오전"
    dateFormatter.pmSymbol = "오후"
    
    return dateFormatter.string(from: date)
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
