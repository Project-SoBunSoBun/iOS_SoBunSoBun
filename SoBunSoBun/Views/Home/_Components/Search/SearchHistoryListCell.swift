//
//  SearchHistoryListCell.swift
//  SoBunSoBun
//
//  Created by 김태은 on 1/16/26.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxGesture

class SearchHistoryListCell: UIStackView {
    private let disposeBag = DisposeBag()
    
    let labelTapped = PublishRelay<String>()
    let removeTapped = PublishRelay<String>()
    
    init(frame: CGRect = .zero, history: String) {
        super.init(frame: frame)
        
        configureUI(history: history)
        bind()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let icon: UIImageView = {
        let iv = UIImageView()
        iv.image = .greyClock
        iv.contentMode = .scaleAspectFit
        
        return iv
    }()
    
    private let label: UILabel = UILabel()
    
    private let button: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = .greyClose.resize(.init(width: 24, height: 24))
        config.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        let btn = UIButton(configuration: config)
        
        return btn
    }()
    
    private func configureUI(history: String) {
        self.axis = .horizontal
        self.spacing = 8
        self.alignment = .leading
        
        var attributes: [NSAttributedString.Key: Any] = body16.attributes()
        attributes[.foregroundColor] = UIColor.neutral700
        
        label.attributedText = NSAttributedString(string: history, attributes: attributes)
        
        [icon, label, button].forEach {
            self.addArrangedSubview($0)
        }
        
        icon.snp.makeConstraints { make in
            make.size.equalTo(24)
        }
        
        button.snp.makeConstraints { make in
            make.size.equalTo(24)
        }
        
        icon.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        button.setContentHuggingPriority(.required, for: .horizontal)
    }
    
    private func bind() {
        label.rx
            .tapGesture()
            .when(.recognized)
            .compactMap { [weak self] _ in
                guard let self = self else { return nil }
                
                return label.attributedText?.string
            }
            .bind(to: labelTapped)
            .disposed(by: disposeBag)
        
        button.rx.tap
            .compactMap { [weak self] in
                guard let self = self else { return nil }
                
                return label.attributedText?.string
            }
            .bind(to: removeTapped)
            .disposed(by: disposeBag)
    }
}
