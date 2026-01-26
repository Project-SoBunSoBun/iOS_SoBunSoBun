//
//  InformationCard.swift
//  SoBunSoBun
//
//  Created by 김태은 on 11/3/25.
//

import UIKit
import SnapKit

class InformationCard: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 디자인 요소
    // 행 stackview 컴포넌트
    private func horizontalStackView() -> UIStackView {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 8
        sv.distribution = .fill
        
        return sv
    }
    
    private func titleAttributes() -> [NSAttributedString.Key: Any] {
        var attributes: [NSAttributedString.Key: Any] = title16.attributes()
        attributes[.foregroundColor] = UIColor.neutral900
        
        return attributes
    }
    
    private func descAttributes() -> [NSAttributedString.Key: Any] {
        var attributes: [NSAttributedString.Key: Any] = body16.attributes(alignment: .right)
        attributes[.foregroundColor] = UIColor.neutral700
        
        return attributes
    }
    
    // 모집 인원
    var minMembers: Int = 0 {
        didSet {
            setParticipants()
        }
    }
    
    var maxMembers: Int = 0 {
        didSet {
            setParticipants()
        }
    }
    
    private lazy var participantsStackView: UIStackView = horizontalStackView()
    private lazy var participantsTitleLabel: UILabel = {
        let lb = UILabel()
        lb.attributedText = NSAttributedString(string: String(localized: "NumberOfParticipants", table: "Home"), attributes: titleAttributes())
        
        return lb
    }()
    private lazy var participantsDescLabel: UILabel = UILabel()
    
    private func setParticipants() {
        guard minMembers > 0, maxMembers > 0 else { return }
        
        let string: String = String(format: NSLocalizedString("ParticipantCount", tableName: "Home", comment: "participants minimum and maximum counts"), minMembers, maxMembers)
        
        participantsDescLabel.attributedText = NSAttributedString(string: string, attributes: descAttributes())
    }
    
    // 지점 위치
    var locationName: String? {
        didSet {
            setLocationName()
        }
    }
    
    private lazy var locationStackView: UIStackView = horizontalStackView()
    private lazy var locationTitleLabel: UILabel = {
        let lb = UILabel()
        lb.attributedText = NSAttributedString(string: String(localized: "MeetingLocation", table: "Home"), attributes: titleAttributes())
        
        return lb
    }()
    private lazy var locationDescLabel: UILabel = UILabel()
    
    private func setLocationName() {
        let string: String = locationName ?? String(localized: "Unknown", table: "Common")
        
        locationDescLabel.attributedText = NSAttributedString(string: string, attributes: descAttributes())
    }
    
    // 날짜 및 시간
    var meetAt: String? {
        didSet {
            setMeetAt()
        }
    }
    
    private lazy var dateTimeStackView: UIStackView = horizontalStackView()
    private lazy var dateTimeTitleLabel: UILabel = {
        let lb = UILabel()
        lb.attributedText = NSAttributedString(string: String(localized: "DateTime", table: "Home"), attributes: titleAttributes())
        
        return lb
    }()
    private lazy var dateTimeDescLabel: UILabel = UILabel()
    
    private func setMeetAt() {
        guard let meetAt else { return }
        
        let string: String = ISO8601ToLocalizedDateTimeString(meetAt)
        
        dateTimeDescLabel.attributedText = NSAttributedString(string: string, attributes: descAttributes())
    }
    
    // 마감일
    var deadlineAt: String? {
        didSet {
            setDeadLine()
        }
    }
    
    private lazy var deadlineStackView: UIStackView = horizontalStackView()
    private lazy var deadlineTitleLabel: UILabel = {
        let lb = UILabel()
        lb.attributedText = NSAttributedString(string: String(localized: "Deadline", table: "Home"), attributes: titleAttributes())
        
        return lb
    }()
    private lazy var deadlineDescLabel: UILabel = UILabel()
    
    private func setDeadLine() {
        guard let deadlineAt else { return }
        
        let string: String = ISO8601ToDDay(deadlineAt)
        
        deadlineDescLabel.attributedText = NSAttributedString(string: string, attributes: descAttributes())
    }
    
    // MARK: - UI 설정
    private func configure() {
        self.backgroundColor = .primary50
        self.layer.cornerRadius = 16
        self.clipsToBounds = true
        
        // 모집 인원
        participantsStackView.addArrangedSubview(participantsTitleLabel)
        participantsStackView.addArrangedSubview(participantsDescLabel)
        
        addSubview(participantsStackView)
        
        participantsStackView.snp.makeConstraints { make in
            make.horizontalEdges.top.equalToSuperview().inset(16)
        }
        
        // 지점 위치
        locationStackView.addArrangedSubview(locationTitleLabel)
        locationStackView.addArrangedSubview(locationDescLabel)
        
        addSubview(locationStackView)
        
        locationStackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(participantsStackView.snp.bottom).offset(8)
        }
        
        // 날짜 및 시간
        dateTimeStackView.addArrangedSubview(dateTimeTitleLabel)
        dateTimeStackView.addArrangedSubview(dateTimeDescLabel)
        
        addSubview(dateTimeStackView)
        
        dateTimeStackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(locationStackView.snp.bottom).offset(8)
        }
        
        // 마감일
        deadlineStackView.addArrangedSubview(deadlineTitleLabel)
        deadlineStackView.addArrangedSubview(deadlineDescLabel)
        
        addSubview(deadlineStackView)
        
        deadlineStackView.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalToSuperview().inset(16)
            make.top.equalTo(dateTimeStackView.snp.bottom).offset(8)
        }
    }
}
