//
//  TermsCheckBoxView.swift
//  SoBunSoBun
//
//  Created by 허성필 on 10/10/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class TermsCheckBoxView: UIView {
    private let disposeBag = DisposeBag()
    
    let isChecked = BehaviorRelay<Bool>(value: false)
    
    let detailButtonTapped = PublishRelay<Void>()
    
    private var isCheckedValue: Bool = false {
        didSet {
            updateCheckboxAppearance()
        }
    }
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        configureUI()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 디자인 요소
    private let checkButton: UIButton = {
        let bt = UIButton()
        bt.setImage(UIImage(named: "GreyCheck"), for: .normal)
        bt.setImage(UIImage(named: "BlueCheck"), for: .selected)
        
        return bt
    }()
    
    private let titleLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = .neutral600
        
        return lb
    }()
    
    private let detailButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = .greyChevronRight.resize(.init(width: 24, height: 24))
        config.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        let btn = UIButton(configuration: config)
        
        return btn
    }()
    
    private let tapAreaButton: UIButton = {
        let bt = UIButton()
        bt.backgroundColor = .clear
        
        return bt
    }()
    
    // MARK: - 레이아웃 설정
    private func configureUI() {
        [checkButton, titleLabel, detailButton, tapAreaButton].forEach {
            addSubview($0)
        }
        
        checkButton.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.size.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(checkButton.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualTo(detailButton.snp.leading).offset(-8)
        }
        
        detailButton.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel.snp.trailing).offset(8)
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.size.equalTo(24)
        }
        
        tapAreaButton.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalTo(detailButton.snp.leading).offset(-8)
            make.top.bottom.equalToSuperview()
        }
    }
    
    // MARK: - 바인딩 설정
    private func bind() {
        // 체크박스 + 텍스트 터치 시 체크 상태 토글
        tapAreaButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                let newValue = !self.isCheckedValue
                self.isCheckedValue = newValue
                self.isChecked.accept(newValue)
            })
            .disposed(by: disposeBag)
        
        // 상세보기 버튼 탭
        detailButton.rx.tap
            .bind(to: detailButtonTapped)
            .disposed(by: disposeBag)
    }
    
    // 체크박스 UI 업데이트
    private func updateCheckboxAppearance(animated: Bool = false) {
        if animated {
            UIView.transition(with: checkButton, duration: 0.2, options: .transitionCrossDissolve) { [weak self] in
                self?.checkButton.isSelected = self?.isCheckedValue ?? false
            }
        } else {
            checkButton.isSelected = isCheckedValue
        }
    }
    
    // 텍스트 색상 업데이트 메서드 추가
    func updateTextColor(_ color: UIColor, animated: Bool = false) {
        if animated {
            UIView.transition(with: titleLabel, duration: 0.2, options: .transitionCrossDissolve) { [weak self] in
                guard let self = self,
                      let currentText = self.titleLabel.attributedText?.string,
                      let currentFont = self.titleLabel.font else { return }
                
                let attributedString = NSAttributedString(
                    string: currentText,
                    attributes: [
                        .font: currentFont,
                        .foregroundColor: color
                    ]
                )
                self.titleLabel.attributedText = attributedString
            }
        } else {
            guard let currentText = titleLabel.attributedText?.string,
                  let currentFont = titleLabel.font else { return }
            
            let attributedString = NSAttributedString(
                string: currentText,
                attributes: [
                    .font: currentFont,
                    .foregroundColor: color
                ]
            )
            titleLabel.attributedText = attributedString
        }
    }
    
    func configure(title: String, hasDetail: Bool, font: UIFont, textColor: UIColor) {
        let attributedString = NSAttributedString(
            string: title,
            attributes: [
                .font: font,
                .foregroundColor: textColor
            ]
        )
        titleLabel.attributedText = attributedString
        detailButton.isHidden = !hasDetail
    }
    
    func setChecked(_ checked: Bool, animated: Bool = false) {
        isCheckedValue = checked
        updateCheckboxAppearance(animated: animated)
    }
    
    var currentCheckedState: Bool {
        return isCheckedValue
    }
}
