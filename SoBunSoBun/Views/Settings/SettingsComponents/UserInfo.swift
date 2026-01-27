//
//  UserInfo.swift
//  SoBunSoBun
//
//  Created by 허성필 on 1/26/26.
//

import UIKit

class UserInfo: UIView {
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 디자인 요소
    // 전체 StackView
    private let allStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 16
        
        return sv
    }()
    
    private let mannerStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 12
        sv.alignment = .center
        sv.layoutMargins = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        sv.isLayoutMarginsRelativeArrangement = true
        
        return sv
    }()
    
    private let mannerLabel: UILabel = {
        let lb = UILabel()
        
        var attributes = body14.attributes(alignment: .center)
        attributes[.foregroundColor] = UIColor.neutral900
        
        let attributeText = NSAttributedString(
            string: String(localized: "MannerScore", table: "Settings"),
            attributes: attributes
        )
        lb.attributedText = attributeText
        
        return lb
    }()
    
    private let mannerCountLabel = UILabel()
    
    private let firstDivider: UIView = {
        let v = UIView()
        v.backgroundColor = .primary100
        
        return v
    }()
    
    private let participationStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 12
        sv.alignment = .center
        sv.layoutMargins = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        sv.isLayoutMarginsRelativeArrangement = true
        
        return sv
    }()
    
    private let participationLabel: UILabel = {
        let lb = UILabel()
        
        var attributes = body14.attributes(alignment: .center)
        attributes[.foregroundColor] = UIColor.neutral900
        
        let attributeText = NSAttributedString(
            string: String(localized: "ParticipationCount", table: "Settings"),
            attributes: attributes
        )
        lb.attributedText = attributeText
        
        return lb
    }()
    
    private let participationCountLabel = UILabel()
    
    private let secondDivider: UIView = {
        let v = UIView()
        v.backgroundColor = .primary100
        
        return v
    }()
    
    private let hostStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 12
        sv.alignment = .center
        sv.layoutMargins = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        sv.isLayoutMarginsRelativeArrangement = true
        
        return sv
    }()
    
    private let hostLabel: UILabel = {
        let lb = UILabel()
        
        var attributes = body14.attributes(alignment: .center)
        attributes[.foregroundColor] = UIColor.neutral900
        
        let attributeText = NSAttributedString(
            string: String(localized: "HostCount", table: "Settings"),
            attributes: attributes
        )
        lb.attributedText = attributeText
        
        return lb
    }()
    
    private let hostCountLabel = UILabel()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let totalDividerWidth: CGFloat = 2  // divider 2개
        let totalSpacing: CGFloat = 8 * 4   // 5개 view → 4개 spacing
        let availableWidth = bounds.width - 16 - totalDividerWidth - totalSpacing
        let eachStackWidth = availableWidth / 3
        
        [mannerStackView, participationStackView, hostStackView].forEach { stackView in
            stackView.snp.updateConstraints { make in
                make.width.equalTo(eachStackWidth)
            }
        }
        
        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: 16
        ).cgPath
    }
    
    // MARK: - 레이아웃 설정
    private func configure() {
        self.backgroundColor = .backgroundWhite
        
        // 모서리
        self.layer.cornerRadius = 16
        
        // 그림자
        self.layer.shadowOffset = .zero
        self.layer.shadowColor = UIColor.primary300.withAlphaComponent(0.16).cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 24
        self.clipsToBounds = false
        
        self.addSubview(allStackView)
        
        allStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
        
        [mannerStackView, participationStackView, hostStackView].forEach {
            allStackView.addArrangedSubview($0)
        }
        
        [firstDivider, secondDivider].forEach {
            allStackView.addSubview($0)
        }
        
        [mannerLabel, mannerCountLabel].forEach {
            mannerStackView.addArrangedSubview($0)
        }
        
        [participationLabel, participationCountLabel].forEach {
            participationStackView.addArrangedSubview($0)
        }
        
        [hostLabel, hostCountLabel].forEach {
            hostStackView.addArrangedSubview($0)
        }
        
        firstDivider.snp.makeConstraints { make in
            make.width.equalTo(1)
            make.height.equalTo(20)
            make.centerY.equalTo(allStackView)
            make.left.equalTo(mannerStackView.snp.right).offset(7)
        }
        
        secondDivider.snp.makeConstraints { make in
            make.width.equalTo(1)
            make.height.equalTo(20)
            make.centerY.equalTo(allStackView)
            make.left.equalTo(participationStackView.snp.right).offset(7)
        }
        
        [mannerLabel, participationLabel, hostLabel].forEach { label in
            label.snp.makeConstraints { make in
                make.height.equalTo(21)
            }
        }
        
        [mannerCountLabel, participationCountLabel, hostCountLabel].forEach { label in
            label.snp.makeConstraints { make in
                make.height.equalTo(22)
            }
        }
    }
    
    func updateUI(_ profile: MyProfileModel) {
        let mannerScore = Double(profile.data.mannerScore)
        let participationCount = profile.data.participationCount
        let hostCount = profile.data.hostCount
        
        // 라벨의 attributes
        var attributes = title16.attributes(alignment: .center)
        attributes[.foregroundColor] = UIColor.primary300
        
        // 매너점수 세팅
        setMannerScore(mannerScore, attributes)
        
        // 참여 횟수 세팅
        setParticipationCount(participationCount, attributes)
        
        // 방장 횟수 세팅
        setHostCount(hostCount, attributes)
    }
    
    private func setMannerScore(_ mannerScore: Double, _ attributes: [NSAttributedString.Key: Any]) {
        let mannerText = NSAttributedString(
            string: String(format: "%.1f", mannerScore) + "/5.0",
            attributes: attributes
        )
        
        mannerCountLabel.attributedText = mannerText
    }
    
    private func setParticipationCount(_ participationCount: Int, _ attributes: [NSAttributedString.Key: Any]) {
        let countString = String(
            format: String(localized: "CountFormat", table: "Settings"),
            participationCount
        )
        
        let participationText = NSAttributedString(
            string: countString,
            attributes: attributes
        )
        
        participationCountLabel.attributedText = participationText
    }
    
    private func setHostCount(_ hostCount: Int, _ attributes: [NSAttributedString.Key: Any]) {
        let countString = String(
            format: String(localized: "CountFormat", table: "Settings"),
            hostCount
        )
        
        let hostText = NSAttributedString(
            string: countString,
            attributes: attributes
        )
        
        hostCountLabel.attributedText = hostText
    }
}
