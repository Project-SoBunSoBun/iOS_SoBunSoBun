//
//  UserPagePostListDeletableCellView.swift
//  SoBunSoBun
//
//  Created by 허성필 on 2/27/26.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxGesture

class UserPagePostListDeletableCellView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func dotIconFrameInWindow() -> CGRect {
        return dotIcon.convert(dotIcon.bounds, to: nil)
    }
    
    private let disposeBag = DisposeBag()
    
    let didTap = PublishRelay<Void>()
    
    // MARK: - 디자인 요소
    private let categoriesWrappingView = HorizontalWrappingView(horizontalSpacing: 8, verticalSpacing: 8)
    
    // 아이콘 컴포넌트
    private func iconImage(image: UIImage) -> UIImageView {
        let iv = UIImageView()
        iv.image = image.resize(.init(width: 24, height: 24))
        iv.contentMode = .scaleAspectFit
        
        return iv
    }
    
    private lazy var dotIcon = iconImage(image: .greyHorizontalDot)
    
    private let titleLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 0
        
        return lb
    }()
    
    // 설명(장소 및 시간) attributes 컴포넌트
    private func descAttributes() -> [NSAttributedString.Key: Any] {
        var attributes: [NSAttributedString.Key: Any] = body14.attributes()
        attributes[.foregroundColor] = UIColor.neutral500
        
        return attributes
    }
    
    private let locationLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 0
        
        return lb
    }()
    
    // stackview 컴포넌트
    private func descStackView() -> UIStackView {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 8
        sv.alignment = .firstBaseline
        sv.distribution = .fill
        
        return sv
    }
    
    private lazy var dateStackView: UIStackView = descStackView()
    
    private let dateLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 0
        
        return lb
    }()
    
    private let joinedLabel: UILabel = UILabel()
    
    // MARK: - 레이아웃 설정
    private func configureUI() {
        self.backgroundColor = .primary50
        self.layer.cornerRadius = 12
        self.clipsToBounds = true
        
        [categoriesWrappingView, dotIcon, titleLabel, locationLabel, dateStackView].forEach {
            addSubview($0)
        }
        
        // 카테고리
        categoriesWrappingView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(dotIcon.snp.leading).offset(-8)
            make.top.equalToSuperview().offset(16)
        }
        
        // 메뉴 버튼
        dotIcon.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(16)
            make.size.equalTo(24)
        }
        
        // 제목
        titleLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(categoriesWrappingView.snp.bottom).offset(8)
        }
        
        // 장소
        locationLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
        }
        
        // 시간 및 인원 표시
        [dateLabel, joinedLabel].forEach {
            dateStackView.addArrangedSubview($0)
        }
        
        dateLabel.setContentHuggingPriority(.init(249), for: .horizontal)
        joinedLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        dateLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        joinedLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        dateStackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(locationLabel.snp.bottom).offset(4)
            make.bottom.equalToSuperview().inset(16)
        }
    }
    
    func configureUI(model: PostModel) {
        // 카테고리
        let categoryViews = model.categoryCode.components(separatedBy: ",")
            .map {
                let view = CategoryMini()
                let category = NSLocalizedString("Category\($0)", tableName: "Category", comment: "")
                
                view.text = category
                
                return view
            }
        
        categoriesWrappingView.removeAllArrangedSubviews()
        categoriesWrappingView.addArrangedSubviews(categoryViews)
        
        // 제목
        var titleAttributes: [NSAttributedString.Key: Any] = title18.attributes(alignment: .left)
        titleAttributes[.foregroundColor] = UIColor.neutral900
        
        titleLabel.attributedText = NSAttributedString(string: model.title, attributes: titleAttributes)
        
        // 장소
        locationLabel.attributedText = NSAttributedString(string: model.locationName, attributes: descAttributes())
        
        // 시간 및 인원 표시
        dateLabel.attributedText = NSAttributedString(string: ISO8601ToLocalizedDateTimeString(model.meetAt), attributes: descAttributes())
        
        var joinedAttributes: [NSAttributedString.Key: Any] = title12.attributes(alignment: .right)
        joinedAttributes[.foregroundColor] = model.joinedMembers + 1 >= model.maxMembers ? UIColor.primary400 : UIColor.neutral300
        
        joinedLabel.attributedText = NSAttributedString(string: "\(model.joinedMembers)/\(model.maxMembers)", attributes: joinedAttributes)
    }
    
    private func bind() {
        dotIcon.rx
            .tapGesture()
            .when(.recognized)
            .map { _ in () }
            .bind(to: didTap)
            .disposed(by: disposeBag)
    }
}
