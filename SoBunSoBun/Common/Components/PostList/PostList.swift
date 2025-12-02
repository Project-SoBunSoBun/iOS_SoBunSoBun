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
    private let categoriesWrappingView = LabelsWrappingView(customLabelType: CategoryMini.self, spacingX: 8, spacingY: 8)
    
    private let titleLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = .neutral900
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
    
    // 설명 label 컴포넌트
    private func descLabel() -> UILabel {
        let lb = UILabel()
        lb.font = body14.font
        lb.textColor = .neutral500
        lb.textAlignment = .left
        
        return lb
    }
    
    private lazy var locationStackView: UIStackView = descStackView()
    
    private lazy var locationIcon: UIImageView = iconImage(image: .greyLocationS)
    
    private lazy var locationLabel: UILabel = descLabel()
    
    private lazy var dateStackView: UIStackView = descStackView()
    
    private lazy var dateIcon: UIImageView = iconImage(image: .greyClockS)
    
    private lazy var dateLabel: UILabel = descLabel()
    
    private let joinedLabel: UILabel = {
        let lb = UILabel()
        lb.font = title12.font
        lb.textAlignment = .right
        
        return lb
    }()
    
    private let divider: UIView = {
        let view = UIView()
        view.backgroundColor = .primary100
        
        return view
    }()
    
    // MARK: - 레이아웃 설정
    private func configure(model: PostModel) {
        // 키워드
        let tempList: [String] = model.categoryCode.components(separatedBy: ",")
        let categoryList: [String] = tempList.map {
            NSLocalizedString("Category\($0)", comment: "Category \($0)") // 동적 문자열 대응
        }
        categoriesWrappingView.labels = categoryList
        
        addSubview(categoriesWrappingView)
        
        categoriesWrappingView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(16)
        }
        
        // 제목
        titleLabel.attributedText = NSAttributedString(string: model.title, attributes: title18.attributes(alignment: .left))
        
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(categoriesWrappingView.snp.bottom).offset(8)
        }
        
        // 장소
        locationStackView.addArrangedSubview(locationIcon)
        locationStackView.addArrangedSubview(locationLabel)
        locationLabel.text = model.locationName
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
        dateLabel.text = ISO8601ToLocalizedDateTimeString(model.meetAt, isFormatColon: false)
        dateLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        dateLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        dateStackView.addArrangedSubview(joinedLabel)
        joinedLabel.text = "\(model.joinedMembers)/\(model.maxMembers)"
        joinedLabel.textColor = model.joinedMembers + 1 >= model.maxMembers ? .primary400 : .neutral300
            
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
