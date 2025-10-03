//
//  Fonts.swift
//  SoBunSoBun
//
//  Created by 허성필 on 9/17/25.
//

import UIKit

struct FontStyle {
    let fontName: String
    let fontSize: CGFloat
    let lineHeightMultiple: CGFloat // 행간 비율
    
    // UIFont 타입 대응 변수
    var font: UIFont { return UIFont(name: fontName, size: fontSize)! }
    
    var paragraphStyle: NSParagraphStyle {
        let style = NSMutableParagraphStyle()
        let lineHeight = fontSize * lineHeightMultiple
        
        style.lineHeightMultiple = lineHeightMultiple
        style.maximumLineHeight = lineHeight
        style.minimumLineHeight = lineHeight
        
        return style
    }
    
    var attributes: [NSAttributedString.Key: Any] {
        [
            .font: UIFont(name: fontName, size: fontSize)!,
            .paragraphStyle: paragraphStyle,
            .baselineOffset: ((fontSize * lineHeightMultiple) - UIFont(name: fontName, size: fontSize)!.lineHeight) / 2
        ]
    }
}

let body14 = FontStyle(
    fontName: "Pretendard-Regular",
    fontSize: 14,
    lineHeightMultiple: 1.5
)

let body16 = FontStyle(
    fontName: "Pretendard-Regular",
    fontSize: 16,
    lineHeightMultiple: 1.5
)

let body18 = FontStyle(
    fontName: "Pretendard-Regular",
    fontSize: 18,
    lineHeightMultiple: 1.5
)

let title14 = FontStyle(
    fontName: "Pretendard-Semibold",
    fontSize: 14,
    lineHeightMultiple: 1.35
)

let title16 = FontStyle(
    fontName: "Pretendard-Semibold",
    fontSize: 16,
    lineHeightMultiple: 1.35
)

let title18 = FontStyle(
    fontName: "Pretendard-Semibold",
    fontSize: 18,
    lineHeightMultiple: 1.35
)

let title20 = FontStyle(
    fontName: "Pretendard-Semibold",
    fontSize: 20,
    lineHeightMultiple: 1.35
)

let title24 = FontStyle(
    fontName: "Pretendard-Semibold",
    fontSize: 24,
    lineHeightMultiple: 1.35
)
