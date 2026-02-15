//
//  SettingListCard.swift
//  SoBunSoBun
//
//  Created by 김태은 on 2/16/26.
//

import UIKit
import SnapKit

class SettingListCard: UIView {
    private let title: String
    
    init(frame: CGRect = .zero, title: String) {
        self.title = title
        
        super.init(frame: frame)
        
        configure()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 디자인 요소
    private lazy var titleLabel: UILabel = {
        var attributes: [NSAttributedString.Key: Any] = body16.attributes()
        attributes[.foregroundColor] = UIColor.neutral900
        
        let lb = UILabel()
        lb.attributedText = NSAttributedString(string: title, attributes: attributes)
        
        return lb
    }()
    
    // SettingCard 하위 컴포넌트가 들어갈 stackView
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 16
        sv.alignment = .leading
        
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
    private func configure() {
        self.backgroundColor = .backgroundWhite
        
        // 모서리
        self.layer.cornerRadius = 16
        
        // 그림자
        self.layer.shadowOffset = .zero
        self.layer.shadowColor = UIColor.primary300.withAlphaComponent(0.16).cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 24
        self.clipsToBounds = false
        
        [titleLabel, stackView].forEach {
            addSubview($0)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.horizontalEdges.top.equalToSuperview().inset(16)
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.horizontalEdges.bottom.equalToSuperview().inset(16)
        }
    }
    
    func addCells(cells: [UIView]) {
        stackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
        
        cells.forEach {
            stackView.addArrangedSubview($0)
            
            $0.snp.makeConstraints { make in
                make.horizontalEdges.equalToSuperview()
            }
        }
    }
}
