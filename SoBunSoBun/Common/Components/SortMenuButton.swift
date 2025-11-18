//
//  SortMenuButton.swift
//  SoBunSoBun
//
//  Created by 김태은 on 11/13/25.
//

import UIKit
import SnapKit

class SortMenuButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 디자인 요소
    let view: UIView = {
        let view = UIView()
        view.backgroundColor = .neutral800
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        
        return view
    }()
    
    let label: UILabel = {
        let lb = UILabel()
        lb.font = title14.font
        lb.textColor = .backgroundWhite
        lb.numberOfLines = 1
        
        return lb
    }()
    
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = .whiteChevronDown
        iv.contentMode = .scaleAspectFit
        
        iv.snp.makeConstraints { make in
            make.size.equalTo(24)
        }
        
        return iv
    }()
    
    // MARK: - 레이아웃 설정
    private func configureUI() {
        self.addSubview(view)
        
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        [iconImageView, label].forEach {
            view.addSubview($0)
        }
        
        iconImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(10)
            make.verticalEdges.equalToSuperview().inset(4)
        }
        
        label.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalTo(iconImageView.snp.leading)
            make.centerY.equalTo(iconImageView)
        }
        
        var config = UIButton.Configuration.plain()
        config.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        self.configuration = config
    }
}
