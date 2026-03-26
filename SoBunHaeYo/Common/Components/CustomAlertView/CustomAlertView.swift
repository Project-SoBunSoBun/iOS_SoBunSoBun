//
//  CustomAlertView.swift
//  SoBunHaeYo
//
//  Created by 허성필 on 10/18/25.
//

import UIKit
import SnapKit
import ReactorKit
import RxSwift
import RxCocoa

class CustomAlertView: UIView {
    typealias Reactor = CustomAlertViewReactor
    private let reactor = CustomAlertViewReactor()
    
    var onPrimaryTapped: (() -> Void)?
    var onCancelTapped: (() -> Void)?
    
    var disposeBag = DisposeBag()
    
    init(title: String,
         subTitle: String? = nil,
         primaryTitleKey: String,
         cancelTitleKey: String? = nil,
         frame: CGRect = .zero
    ){
        super.init(frame: frame)
        
        configureUI(
            title: title,
            subtitle: subTitle,
            primaryTitleKey: primaryTitleKey,
            cancelTitleKey: cancelTitleKey
        )
        
        bind(reactor: reactor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let containerView: UIStackView = {
        let ctView = UIStackView()
        ctView.axis = .vertical
        ctView.spacing = 0
        ctView.alignment = .center
        ctView.backgroundColor = .backgroundWhite
        ctView.layer.cornerRadius = 16
        ctView.clipsToBounds = true
        ctView.isLayoutMarginsRelativeArrangement = true
        ctView.layoutMargins = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
        
        return ctView
    }()
    
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textColor = .neutral900
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        
        return titleLabel
    }()
    
    private let subtitleLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = .neutral900
        lb.textAlignment = .center
        lb.numberOfLines = 0
        
        return lb
    }()
    
    private let buttonStackView: UIStackView = {
        let buttonStackView = UIStackView()
        buttonStackView.axis = .vertical
        buttonStackView.spacing = 0
        
        return buttonStackView
    }()
    
    private let primaryButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)
        
        let button = UIButton(configuration: config)
        
        button.configurationUpdateHandler = { button in
            switch button.state {
            case .highlighted:
                button.configuration?.background.backgroundColor = .neutral100
                
            default:
                button.configuration?.background.backgroundColor = .clear
            }
        }
        
        return button
    }()
    
    private let cancelButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)
        
        let button = UIButton(configuration: config)
        
        button.configurationUpdateHandler = { button in
            switch button.state {
            case .highlighted:
                button.configuration?.background.backgroundColor = .neutral100
                
            default:
                button.configuration?.background.backgroundColor = .clear
            }
        }
        
        return button
    }()
    
    private let firstDivider: UIView = {
        let divider = UIView()
        divider.backgroundColor = .neutral400
        
        return divider
    }()
    
    private let secondDivider: UIView = {
        let divider = UIView()
        divider.backgroundColor = .neutral400
        
        return divider
    }()
    
    private func configureUI(
        title: String,
        subtitle: String?,
        primaryTitleKey: String,
        cancelTitleKey: String?
    ) {
        self.backgroundColor = .alertBackgroundBlack
        self.addSubview(containerView)
        
        [titleLabel, subtitleLabel, firstDivider, primaryButton, secondDivider, cancelButton].forEach {
            containerView.addArrangedSubview($0)
        }
        
        // title
        let titleAttributedText = NSAttributedString(
            string: title,
            attributes: title16.attributes(alignment: .center)
        )
        titleLabel.attributedText = titleAttributedText
        
        // subTitle
        if let subtitle = subtitle {
            subtitleLabel.attributedText = NSAttributedString(
                string: subtitle,
                attributes: body14.attributes(alignment: .center)
            )
        }
        
        setTitleSpacing(isSubtitleEnabled: subtitle != nil)
        
        // primary localized
        var primaryAttributes: [NSAttributedString.Key:Any] = title16.attributes(alignment: .center)
        primaryAttributes[.foregroundColor] = UIColor.primary400
        
        let primaryAttributedTitle = NSAttributedString(
            string: primaryTitleKey,
            attributes: primaryAttributes
        )
        
        primaryButton.configuration?.attributedTitle = AttributedString(primaryAttributedTitle)
        
        // cancel localized
        var cancelAttributes: [NSAttributedString.Key:Any] = title16.attributes(alignment: .center)
        cancelAttributes[.foregroundColor] = UIColor.neutral700
        
        if let cancelTitleKey = cancelTitleKey {
            let cancelAttributedTitle = NSAttributedString(
                string: cancelTitleKey,
                attributes: cancelAttributes
            )
            
            cancelButton.configuration?.attributedTitle = AttributedString(cancelAttributedTitle)
        } else {
            secondDivider.isHidden = true
            cancelButton.isHidden = true
        }
        
        containerView.setCustomSpacing(16, after: titleLabel)
        
        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.72)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
        }
        
        firstDivider.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(1)
        }
        
        primaryButton.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
        }
        
        cancelButton.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
        }
        
        secondDivider.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    private func setTitleSpacing(isSubtitleEnabled: Bool) {
        subtitleLabel.isHidden = !isSubtitleEnabled
        
        containerView.setCustomSpacing(isSubtitleEnabled ? 10 : 16, after: titleLabel)
        
        if isSubtitleEnabled {
            containerView.setCustomSpacing(16, after: subtitleLabel)
        }
    }
    
    func show(on viewController: UIViewController) {
        guard let window = viewController.view.window else { return }
        window.addSubview(self)
        self.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 애니메이션
        self.alpha = 0
        containerView.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
            self.containerView.transform = .identity
        }
    }
}

extension CustomAlertView {
    private func bind(reactor: CustomAlertViewReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    private func bindAction(reactor: CustomAlertViewReactor) {
        // 설정 버튼 탭
        primaryButton.rx.tap
            .map { Reactor.Action.settingButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 취소 버튼 탭
        cancelButton.rx.tap
            .map { Reactor.Action.cancelButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(reactor:CustomAlertViewReactor) {
        reactor.pulse(\.$shouldOpenSettings)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                self.onPrimaryTapped?()
                self.removeFromSuperview()
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$shouldDismiss)
            .compactMap { $0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.onCancelTapped?()
                self?.removeFromSuperview()
            })
            .disposed(by: disposeBag)
    }
}
