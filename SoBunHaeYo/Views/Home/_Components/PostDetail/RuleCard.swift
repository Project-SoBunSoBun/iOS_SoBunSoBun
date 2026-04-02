//
//  RuleCard.swift
//  SoBunHaeYo
//
//  Created by 김태은 on 11/3/25.
//

import UIKit
import SnapKit

class RuleCard: UIView {
    /// desc의 줄 구분은 |(수직바)를 이용하십시오
    init(frame: CGRect = .zero, title: String, desc: String) {
        super.init(frame: frame)
        
        configure(title: title, desc: desc)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 디자인 요소
    private let titleLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 0
        
        return lb
    }()
    
    private let descLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 0
        
        return lb
    }()
    
    // pretendard regular 기준 body 14 bullet point list 설정
    private let bulletPointSpacing: CGFloat = 7
    
    private func bulletPointList(string: String) -> NSAttributedString {
        let bulletPoint: String = "•"
        
        // 기존 폰트 구조
        let fontStruct = body14
        var attrs = fontStruct.attributes()
        attrs[.foregroundColor] = UIColor.neutral700
        
        // 불렛 너비
        let bulletPointWidth = (bulletPoint as NSString).size(withAttributes: [.font: fontStruct.font]).width
        
        // 새 paragraphStyle
        let paragraphStyle = NSMutableParagraphStyle()
        
        // 새 paragraphStyle에 기존 paragraphStyle 복사
        if let existingStyle = attrs[.paragraphStyle] as? NSParagraphStyle {
            paragraphStyle.setParagraphStyle(existingStyle)
        }
        
        // 새 paragraphStyle에 headIndent, tab 설정
        paragraphStyle.headIndent = bulletPointWidth + bulletPointSpacing
        paragraphStyle.tabStops = [NSTextTab(textAlignment: .left, location: bulletPointWidth + bulletPointSpacing)]
        
        // 기존 attributes에 새 paragraphStyle 덮어쓰기
        attrs[.paragraphStyle] = paragraphStyle
        
        // 문자열 분리 및 bullet point list로 가공
        let separatedString = string.components(separatedBy: "|")
        let list = separatedString.map({ "\(bulletPoint)\t\($0)" }).joined(separator: "\n")

        return NSAttributedString(string: list, attributes: attrs)
    }
    
    // MARK: - 레이아웃 설정
    private func configure(title: String, desc: String) {
        self.backgroundColor = .neutral50
        self.layer.cornerRadius = 16
        self.clipsToBounds = true
        
        // 제목
        var titleAttributes: [NSAttributedString.Key: Any] = title14.attributes()
        titleAttributes[.foregroundColor] = UIColor.primary300
        titleLabel.attributedText = NSAttributedString(string: title, attributes: titleAttributes)
        
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.horizontalEdges.top.equalToSuperview().inset(16)
        }
        
        // 설명
        descLabel.attributedText = bulletPointList(string: desc)
        
        addSubview(descLabel)
        
        descLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16 + bulletPointSpacing)
            make.trailing.bottom.equalToSuperview().inset(16)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
        }
    }
}
