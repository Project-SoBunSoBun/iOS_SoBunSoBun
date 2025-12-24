//
//  RegisterPostSuccessView.swift
//  SoBunSoBun
//
//  Created by 김태은 on 12/18/25.
//

import UIKit
import SnapKit

class RegisterPostSuccessView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 16
        sv.alignment = .center
        sv.backgroundColor = .backgroundWhite
        sv.isLayoutMarginsRelativeArrangement = true
        sv.directionalLayoutMargins = .init(top: 20, leading: 20, bottom: 20, trailing: 20) // RTL 언어 지원
        sv.layer.cornerRadius = 16
        sv.clipsToBounds = true
        
        return sv
    }()
    
    private let symbol: UIView = {
        let view = UIView()
        view.backgroundColor = .primary100
        view.layer.cornerRadius = 40
        view.clipsToBounds = true
        
        view.snp.makeConstraints { make in make.size.equalTo(80) }
        
        let iv = UIImageView()
        iv.image = .blueCheck
        iv.contentMode = .scaleAspectFit
        
        view.addSubview(iv)
        
        iv.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(view)
        }
        
        return view
    }()
    
    private let label: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 0
        
        var attributes: [NSAttributedString.Key: Any] = title20.attributes(alignment: .center)
        attributes[.foregroundColor] = UIColor.primary400
        
        lb.attributedText = NSAttributedString(string: String(localized: "RegisterPostSuccess"), attributes: attributes)
        
        lb.snp.makeConstraints { make in make.width.equalTo(182) }
        
        return lb
    }()
    
    private func configureUI() {
        self.backgroundColor = .alertBackgroundBlack
        
        addSubview(stackView)
        
        stackView.snp.makeConstraints { make in make.center.equalToSuperview() }
        
        [symbol, label].forEach { stackView.addArrangedSubview($0) }
    }
}
