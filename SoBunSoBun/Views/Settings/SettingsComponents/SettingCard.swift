//
//  SettingCard.swift
//  SoBunSoBun
//
//  Created by 허성필 on 1/21/26.
//

import UIKit
import SnapKit

class SettingCard: UIView {
    init(frame: CGRect = .zero, cells: [SettingCardCell]) {
        super.init(frame: frame)
        
        configure(cells: cells)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 디자인 요소
    // SettingCard 하위 컴포넌트가 들어갈 stackView
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 16
        sv.alignment = .center
        sv.distribution = .fillEqually
        
        return sv
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: 16
        ).cgPath
    }
    
    // MARK: - 레이아웃 설정
    private func configure(cells: [SettingCardCell]) {
        self.backgroundColor = .backgroundWhite
        
        // 모서리
        self.layer.cornerRadius = 16
        
        // 그림자
        self.layer.shadowOffset = .zero
        self.layer.shadowColor = UIColor.primary300.withAlphaComponent(0.16).cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 24
        self.clipsToBounds = false
        
        self.addSubview(stackView)
        
        cells.forEach {
            stackView.addArrangedSubview($0)
        }
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
    }
}
