//
//  UserInfo.swift
//  SoBunSoBun
//
//  Created by 허성필 on 1/26/26.
//

import UIKit
import SnapKit

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
        sv.distribution = .fillEqually
        
        return sv
    }()
    
    private func makeStackView() -> UIStackView {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 12
        sv.alignment = .center
        sv.layoutMargins = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        sv.isLayoutMarginsRelativeArrangement = true
        
        return sv
    }
    
    private func makeLabel(string: String) -> UILabel {
        let lb = UILabel()
        
        var attributes = body14.attributes(alignment: .center)
        attributes[.foregroundColor] = UIColor.neutral900
        
        let attributeText = NSAttributedString(
            string: string,
            attributes: attributes
        )
        lb.attributedText = attributeText
        
        return lb
    }
    
    private func makeDivider() -> UIView {
        let v = UIView()
        v.backgroundColor = .primary100
        
        return v
    }
    
    private lazy var mannerStackView = makeStackView()
    
    private lazy var activityLabel = makeLabel(string: String(localized: "ActivityScore", table: "Settings"))
    
    private let activityScoreLabel = UILabel()
    
    private lazy var firstDivider = makeDivider()
    
    private lazy var participationStackView = makeStackView()
    
    private lazy var participationLabel = makeLabel(string: String(localized: "ParticipationCount", table: "Settings"))
    
    private let participationCountLabel = UILabel()
    
    private lazy var secondDivider = makeDivider()
    
    private lazy var hostStackView = makeStackView()
    
    private lazy var hostLabel = makeLabel(string: String(localized: "HostCount", table: "Settings"))
    
    private let hostCountLabel = UILabel()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        [firstDivider, secondDivider].forEach {
            allStackView.addSubview($0)
        }
        
        firstDivider.snp.updateConstraints { make in
            make.leading.equalToSuperview().offset(((bounds.width / 3) * 1) - 8)
            make.width.equalTo(1)
            make.height.equalTo(20)
            make.centerY.equalTo(allStackView)
        }
        
        secondDivider.snp.updateConstraints { make in
            make.leading.equalToSuperview().offset(((bounds.width / 3) * 2) - 8)
            make.width.equalTo(1)
            make.height.equalTo(20)
            make.centerY.equalTo(allStackView)
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
        
        [activityLabel, activityScoreLabel].forEach {
            mannerStackView.addArrangedSubview($0)
        }
        
        [participationLabel, participationCountLabel].forEach {
            participationStackView.addArrangedSubview($0)
        }
        
        [hostLabel, hostCountLabel].forEach {
            hostStackView.addArrangedSubview($0)
        }
    }
    
    func updateUI(activityScore: Int, participationCount: Int, hostCount: Int) {
        // 라벨의 attributes
        var attributes = title16.attributes(alignment: .center)
        attributes[.foregroundColor] = UIColor.primary300
        
        // 매너점수 세팅
        setActivityScore(activityScore, attributes)
        
        // 참여 횟수 세팅
        setParticipationCount(participationCount, attributes)
        
        // 방장 횟수 세팅
        setHostCount(hostCount, attributes)
    }
    
    private func setActivityScore(_ activityScore: Int, _ attributes: [NSAttributedString.Key: Any]) {
        let scoreString = String(
            format: String(localized: "ScoreFormat", table: "Settings"),
            activityScore
        )
        
        let scoreText = NSAttributedString(
            string: String(scoreString),
            attributes: attributes
        )
        
        activityScoreLabel.attributedText = scoreText
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
