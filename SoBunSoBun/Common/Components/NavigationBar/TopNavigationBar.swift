//
//  TopNavigationBar.swift
//  SoBunSoBun
//
//  Created by 김태은 on 12/8/25.
//

import UIKit
import SnapKit
import RxSwift

class TopNavigationBar: UIView {
    private let disposeBag = DisposeBag()
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    weak var parentViewController: UIViewController?
    
    private let backButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = .blackLeft
        config.preferredSymbolConfigurationForImage = .init(pointSize: 24)
        config.contentInsets = .init(top: 12, leading: 12, bottom: 12, trailing: 12)
        
        let btn = UIButton(configuration: config)
        
        return btn
    }()
    
    private let titleLabel: UILabel = {
        let lb = UILabel()
        lb.font = title16.font
        lb.textColor = .neutral900
        lb.textAlignment = .center
        
        return lb
    }()
    
    private let buttonStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 0
        sv.alignment = .center
        
        return sv
    }()
    
    var title: String = "" {
        didSet {
            setTitle(title)
        }
    }
    
    var buttons: [UIButton] = [] {
        didSet {
            setButtons(buttons)
        }
    }
    
    private func configureUI() {
        self.backgroundColor = .backgroundWhite
        
        [backButton, titleLabel, buttonStackView].forEach {
            addSubview($0)
        }
        
        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.verticalEdges.equalToSuperview()
        }
        
        backButton.rx.tap
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                
                parentViewController?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        buttonStackView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
        }
    }
    
    private func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    private func setButtons(_ buttons: [UIButton]) {
        buttonStackView.arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
        
        buttons.forEach {
            buttonStackView.addArrangedSubview($0)
        }
    }
}
