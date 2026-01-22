//
//  SettingCardCell.swift
//  SoBunSoBun
//
//  Created by 허성필 on 1/22/26.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxGesture

class SettingCardCell: UIStackView {
    private let title: String
    private let subTitle: String?
    
    private let disposeBag = DisposeBag()
    
    enum CellType {
        case button
        case text
        case empty
    }
    
    init(frame: CGRect = .zero, title: String, subTitle: String? = nil, type: CellType) {
        self.title = title
        self.subTitle = subTitle
        
        super.init(frame: frame)
        
        configure(type: type)
        
        if type == .button {
            bind()
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 외부에서 터치를 감지할 변수
    let didTap = PublishRelay<Void>()
    
    // MARK: - 디자인 요소
    // titleLabel
    private let titleLabel = UILabel()
    
    // subTitleLabel
    private let subTitleLabel = UILabel()
    
    // 아이콘 이미지 뷰
    private let nextButtonImage: UIImageView = { // imageView로 바꾸기
        let iv = UIImageView()
        iv.image = .blackChevronRight
        iv.contentMode = .scaleAspectFit
        
        iv.snp.makeConstraints { make in
            make.size.equalTo(24)
        }
        
        return iv
    }()
    
    // MARK: - 레이아웃 설정
    private func configure(type: CellType) {
        self.backgroundColor = .clear
        self.axis = .horizontal
        self.spacing = 8
        self.alignment = .center
        
        setLabelAndButton(title: title)
        setLabelText(title: title, subTitle: subTitle ?? "")
        
        if type == .button {
            [titleLabel, nextButtonImage].forEach {
                self.addArrangedSubview($0)
            }
        } else if type == .text {
            [titleLabel, subTitleLabel].forEach {
                self.addArrangedSubview($0)
            }
        }
    }
    
    private func setLabelAndButton(title: String) {
        var attributes = body16.attributes(alignment: .left)
        attributes[.foregroundColor] = UIColor.neutral900
        
        let attributedText = NSAttributedString(
            string: title,
            attributes: attributes
        )
        
        titleLabel.attributedText = attributedText
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }
    
    private func setLabelText(title: String, subTitle: String) {
        // titleLabel 폰트 및 폰트 컬러 설정
        var titleAttributes = body16.attributes(alignment: .left)
        titleAttributes[.foregroundColor] = UIColor.neutral900
        
        let titleAttributedText = NSAttributedString(
            string: title,
            attributes: titleAttributes
        )
        
        titleLabel.attributedText = titleAttributedText
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        // subTitleLabel 폰트 및 폰트 컬러 설정
        var subTitleAttributes = body16.attributes(alignment: .right)
        subTitleAttributes[.foregroundColor] = UIColor.neutral500
        
        let subTitleAttributedText = NSAttributedString(
            string: subTitle,
            attributes: subTitleAttributes
        )
        
        subTitleLabel.attributedText = subTitleAttributedText
    }
    
    private func bind() {
        self.rx
            .tapGesture()
            .when(.recognized)
            .map { _ in () }
            .bind(to: didTap)
            .disposed(by: disposeBag)
    }
}
