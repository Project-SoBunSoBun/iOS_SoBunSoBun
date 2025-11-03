//
//  CustomAlertView.swift
//  SoBunSoBun
//
//  Created by 허성필 on 10/18/25.
//

import UIKit
import SnapKit

class CustomAlertView: UIView {
    var onSettingsTapped: (() -> Void)?
    var onCancelTapped: (() -> Void)?
    
    private let containerView: UIView = {
        let ctView = UIView()
        ctView.backgroundColor = .appleWhite
        ctView.layer.cornerRadius = 16
        
        return ctView
    }()
    
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textColor = .neutral900
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        
        return titleLabel
    }()
    
    private let buttonStackView: UIStackView = {
        let buttonStackView = UIStackView()
        buttonStackView.axis = .vertical // 확인 필요
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 0
        
        return buttonStackView
    }()
    
    private let settingsButton: UIButton = {
        let button = UIButton()
        button.setTitle(String(localized: "ToGoSetting"), for: .normal)
        button.setTitleColor(.primary400, for: .normal)
        button.titleLabel?.font = body16.font
        
        return button
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle(String(localized: "Cancel"), for: .normal)
        button.setTitleColor(.neutral700, for: .normal)
        button.titleLabel?.font = body16.font
        
        return button
    }()
    
    private let topDivider: UIView = {
        let divider = UIView()
        divider.backgroundColor = .separator
        
        return divider
    }()
    
    private let verticalDivider: UIView = {
        let divider = UIView()
        divider.backgroundColor = .separator
        
        return divider
    }()
    
    init(title: String) {
        super.init(frame: .zero)
        configureUI(title: title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI(title: String) {
        backgroundColor = UIColor.appleBlack.withAlphaComponent(0.4)
        
        let attributedText = NSAttributedString(
            string: title,
            attributes: title16.attributes(alignment: .center)
        )
        titleLabel.attributedText = attributedText
        
        self.addSubview(containerView)
        
        [titleLabel, buttonStackView].forEach {
            containerView.addSubview($0)
        }
        
        [settingsButton, cancelButton].forEach {
            buttonStackView.addArrangedSubview($0)
        }
        
        settingsButton.addTarget(self, action: #selector(settingsTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        
        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.72)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.horizontalEdges.equalToSuperview().inset(16)
        }
        
        buttonStackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.5333) // 0.266
        }
        
        containerView.addSubview(topDivider)
        
        topDivider.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(buttonStackView.snp.top)
            make.height.equalTo(0.5)
        }

        containerView.addSubview(verticalDivider)
        
        verticalDivider.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(settingsButton.snp.bottom)
            make.height.equalTo(0.5)
        }
    }
    
    @objc private func settingsTapped() {
        onSettingsTapped?()
        removeFromSuperview()
    }
    
    @objc private func cancelTapped() {
        onCancelTapped?()
        removeFromSuperview()
    }
    
    func show(on viewController: UIViewController) {
        guard let window = viewController.view.window else { return }
        window.addSubview(self)
        self.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 애니메이션
        alpha = 0
        containerView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
            self.containerView.transform = .identity
        }
    }
}
