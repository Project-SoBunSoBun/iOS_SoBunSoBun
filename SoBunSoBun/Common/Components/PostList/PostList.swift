//
//  PostList.swift
//  SoBunSoBun
//
//  Created by 김태은 on 10/22/25.
//

import UIKit
import SnapKit

class PostList: UIView {
    init(frame: CGRect = .zero, model: PostModel) {
        super.init(frame: frame)
        
        configure(model: model)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 구분선 표시 여부
    var isDividerHidden: Bool = true {
        didSet {
            changeShowDivider(isDividerHidden)
        }
    }
    
    // MARK: - 디자인 요소
    private let categoriesWrappingView = HorizontalWrappingView(horizontalSpacing: 8, verticalSpacing: 8)
    
    private let titleLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 0
        
        return lb
    }()
    
    // stackview 컴포넌트
    private func descStackView() -> UIStackView {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 4
        sv.alignment = .center
        
        return sv
    }
    
    // 아이콘 컴포넌트
    private func iconImage(image: UIImage) -> UIImageView {
        let iv = UIImageView()
        iv.image = image
        iv.contentMode = .scaleAspectFit
        
        iv.snp.makeConstraints { make in
            make.size.equalTo(20)
        }
        
        return iv
    }
    
    // 설명(장소 및 시간) attributes 컴포넌트
    private func descAttributes() -> [NSAttributedString.Key: Any] {
        var attributes: [NSAttributedString.Key: Any] = body14.attributes()
        attributes[.foregroundColor] = UIColor.neutral500
        
        return attributes
    }
    
    private lazy var locationStackView: UIStackView = descStackView()
    
    private lazy var locationIcon: UIImageView = iconImage(image: .greyLocationS)
    
    private lazy var locationLabel: UILabel = UILabel()
    
    private lazy var dateStackView: UIStackView = descStackView()
    
    private lazy var dateIcon: UIImageView = iconImage(image: .greyClockS)
    
    private lazy var dateLabel: UILabel = UILabel()
    
    private let joinedLabel: UILabel = UILabel()
    
    private let divider: UIView = {
        let view = UIView()
        view.backgroundColor = .primary100
        
        return view
    }()
    
    // MARK: - 레이아웃 설정
    private func configure(model: PostModel) {
        // 카테고리
        let categoryViews = model.categoryCode.components(separatedBy: ",")
            .map {
                let view = CategoryMini()
                let category = NSLocalizedString("Category\($0)", tableName: "Category", comment: "")
                
                view.text = category
                
                return view
            }
        
        categoriesWrappingView.addArrangedSubviews(categoryViews)
        
        addSubview(categoriesWrappingView)
        
        categoriesWrappingView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(16)
        }
        
        // 제목
        var titleAttributes: [NSAttributedString.Key: Any] = title18.attributes(alignment: .left)
        titleAttributes[.foregroundColor] = UIColor.neutral900
        
        titleLabel.attributedText = NSAttributedString(string: model.title, attributes: titleAttributes)
        
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(categoriesWrappingView.snp.bottom).offset(8)
        }
        
        // 장소
        locationStackView.addArrangedSubview(locationIcon)
        locationStackView.addArrangedSubview(locationLabel)
        
        locationLabel.attributedText = NSAttributedString(string: model.locationName, attributes: descAttributes())
        locationLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        locationLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        addSubview(locationStackView)
        
        locationStackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
        }
        
        // 시간 및 인원 표시
        dateStackView.addArrangedSubview(dateIcon)
        dateStackView.addArrangedSubview(dateLabel)
        
        dateLabel.attributedText = NSAttributedString(string: ISO8601ToLocalizedDateTimeString(model.meetAt), attributes: descAttributes())
        dateLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        dateLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        dateStackView.addArrangedSubview(joinedLabel)
        
        var joinedAttributes: [NSAttributedString.Key: Any] = title12.attributes(alignment: .right)
        joinedAttributes[.foregroundColor] = model.joinedMembers + 1 >= model.maxMembers ? UIColor.primary400 : UIColor.neutral300
        
        joinedLabel.attributedText = NSAttributedString(string: "\(model.joinedMembers)/\(model.maxMembers)", attributes: joinedAttributes)
            
        addSubview(dateStackView)
        
        dateStackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(locationStackView.snp.bottom).offset(4)
        }
        
        // 구분선
        addSubview(divider)
        
        divider.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalToSuperview()
            make.top.equalTo(dateStackView.snp.bottom).offset(16)
            make.height.equalTo(1)
        }
    }
    
    // 구분선 표시 변경 함수
    private func changeShowDivider(_ isDividerHidden: Bool) {
        divider.isHidden = isDividerHidden
    }
}
