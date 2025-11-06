//
//  HomeList.swift
//  SoBunSoBun
//
//  Created by 김태은 on 10/22/25.
//

import UIKit
import SnapKit

class HomeList: UIView {
    init(frame: CGRect = .zero,
         categories: String,
         title: String,
         location: String,
         meetingDate: String, // ISO 8601 문자열
         joinedCount: Int,
         maxCount: Int) {
        super.init(frame: frame)
        
        configure(categories: categories,
                  title: title,
                  location: location,
                  meetingDate: meetingDate,
                  joinedCount: joinedCount,
                  maxCount: maxCount)
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
    
    private lazy var bottomStackView: UIStackView = {
        let sv = descStackView()
        sv.distribution = .fill
        
        return sv
    }()
    
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
        
        view.snp.makeConstraints { make in
            make.height.equalTo(1)
        }
        
        return view
    }()
    
    // MARK: - 레이아웃 설정
    private func configure(
        categories: String,
        title: String,
        location: String,
        meetingDate: String,
        joinedCount: Int,
        maxCount: Int) {
        // 키워드
        let tempList: [String] = categories.components(separatedBy: ",")
        let categoryList: [String] = tempList.map { k in
            NSLocalizedString("Category\(k)", comment: "Category \(k)") // 동적 문자열 대응
        }
        categoriesWrappingView.labels = categoryList
        
        addSubview(categoriesWrappingView)
        
        categoriesWrappingView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(16)
        }
        
        // 제목
        titleLabel.attributedText = NSAttributedString(string: title, attributes: title18.attributes)
        
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(categoriesWrappingView.snp.bottom).offset(8)
        }
        
        // 장소
        locationStackView.addArrangedSubview(locationIcon)
        locationStackView.addArrangedSubview(locationLabel)
        locationLabel.text = location
        
        addSubview(locationStackView)
        
        locationStackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
        }
        
        // 시간 및 인원 표시
        bottomStackView.addArrangedSubview(dateStackView)
        
        dateStackView.addArrangedSubview(dateIcon)
        dateStackView.addArrangedSubview(dateLabel)
        dateLabel.text = ISO8601ToLocalizedDateTimeString(meetingDate, isFormatColon: false)
        
        bottomStackView.addArrangedSubview(joinedLabel)
        joinedLabel.text = "\(joinedCount)/\(maxCount)"
        joinedLabel.textColor = joinedCount + 1 >= maxCount ? .primary400 : .neutral300
            
        addSubview(bottomStackView)
        
        bottomStackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(locationStackView.snp.bottom).offset(4)
        }
        
        // 구분선
        addSubview(divider)
        
        divider.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalToSuperview()
            make.top.equalTo(bottomStackView.snp.bottom).offset(16)
        }
    }
    
    // 구분선 표시 변경 함수
    private func changeShowDivider(_ isDividerHidden: Bool) {
        divider.isHidden = isDividerHidden
    }
}
