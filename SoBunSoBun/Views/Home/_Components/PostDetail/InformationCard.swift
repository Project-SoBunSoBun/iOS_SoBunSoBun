//
//  InformationCard.swift
//  SoBunSoBun
//
//  Created by 김태은 on 11/3/25.
//

import UIKit
import SnapKit

class InformationCard: UIView {
    private let UNKNOWN_STRING = String(localized: "Unknown", table: "Common")
    
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
    private lazy var participantsStackView: UIStackView = horizontalStackView()
    private lazy var participantsTitleLabel: UILabel = {
        let lb = UILabel()
        lb.attributedText = NSAttributedString(string: String(localized: "NumberOfParticipants", table: "Home"), attributes: titleAttributes())
        
        return lb
    }()
    private lazy var participantsDescLabel: UILabel = UILabel()
    
    // 지점 위치
    private lazy var locationStackView: UIStackView = horizontalStackView()
    private lazy var locationTitleLabel: UILabel = {
        let lb = UILabel()
        lb.attributedText = NSAttributedString(string: String(localized: "MeetingLocation", table: "Home"), attributes: titleAttributes())
        
        return lb
    }()
    private lazy var locationDescLabel: UILabel = UILabel()
    
    // 날짜 및 시간
    private lazy var dateTimeStackView: UIStackView = horizontalStackView()
    private lazy var dateTimeTitleLabel: UILabel = {
        let lb = UILabel()
        lb.attributedText = NSAttributedString(string: String(localized: "DateTime", table: "Home"), attributes: titleAttributes())
        
        return lb
    }()
    private lazy var dateTimeDescLabel: UILabel = UILabel()
    
    // 마감일
    private lazy var deadlineStackView: UIStackView = horizontalStackView()
    private lazy var deadlineTitleLabel: UILabel = {
        let lb = UILabel()
        lb.attributedText = NSAttributedString(string: String(localized: "Deadline", table: "Home"), attributes: titleAttributes())
        
        return lb
    }()
    private lazy var deadlineDescLabel: UILabel = UILabel()
    
    // MARK: - UI 설정
    private func configureUI(
        minMembers: Int?,
        maxMembers: Int?,
        locationName: String?,
        meetAt: String?,
        deadline: String?
    ) {
        self.backgroundColor = .primary50
        self.layer.cornerRadius = 16
        self.clipsToBounds = true
        
        // 모집 인원
        setParticipants(minMembers, maxMembers)
        
        // 지점 위치
        setLocationName(locationName)
        
        // 날짜 및 시간
        setMeetAt(meetAt)
        
        // 마감일
        setDeadLine(deadline)
    }
    
    private func setParticipants(_ minMembers: Int?, _ maxMembers: Int?) {
        participantsStackView.addArrangedSubview(participantsTitleLabel)
        participantsStackView.addArrangedSubview(participantsDescLabel)
        
        addSubview(participantsStackView)
        
        participantsTitleLabel.setContentHuggingPriority(.required, for: .horizontal)
        participantsDescLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        participantsStackView.snp.makeConstraints { make in
            make.horizontalEdges.top.equalToSuperview().inset(16)
        }
        
        let string: String = String(format: NSLocalizedString("ParticipantCount", tableName: "Home", comment: "participants minimum and maximum counts"), minMembers ?? 0, maxMembers ?? 0)
        
        participantsDescLabel.attributedText = NSAttributedString(string: string, attributes: descAttributes())
    }
    
    private func setLocationName(_ locationName: String?) {
        locationStackView.addArrangedSubview(locationTitleLabel)
        locationStackView.addArrangedSubview(locationDescLabel)
        
        addSubview(locationStackView)
        
        locationTitleLabel.setContentHuggingPriority(.required, for: .horizontal)
        locationDescLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        locationStackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(participantsStackView.snp.bottom).offset(8)
        }
        
        let string: String = locationName ?? UNKNOWN_STRING
        
        locationDescLabel.attributedText = NSAttributedString(string: string, attributes: descAttributes())
    }
    
    private func setMeetAt(_ meetAt: String?) {
        dateTimeStackView.addArrangedSubview(dateTimeTitleLabel)
        dateTimeStackView.addArrangedSubview(dateTimeDescLabel)
        
        addSubview(dateTimeStackView)
        
        dateTimeTitleLabel.setContentHuggingPriority(.required, for: .horizontal)
        dateTimeDescLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        dateTimeStackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(locationStackView.snp.bottom).offset(8)
        }
        
        let string: String
        
        if let meetAt {
            string = ISO8601ToLocalizedDateTimeString(meetAt)
        } else {
            string = UNKNOWN_STRING
        }
        
        dateTimeDescLabel.attributedText = NSAttributedString(string: string, attributes: descAttributes())
    }
    
    private func setDeadLine(_ deadlineAt: String?) {
        deadlineStackView.addArrangedSubview(deadlineTitleLabel)
        deadlineStackView.addArrangedSubview(deadlineDescLabel)
        
        addSubview(deadlineStackView)
        
        deadlineTitleLabel.setContentHuggingPriority(.required, for: .horizontal)
        deadlineDescLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        deadlineStackView.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalToSuperview().inset(16)
            make.top.equalTo(dateTimeStackView.snp.bottom).offset(8)
        }
        
        let string: String
        
        if let deadlineAt {
            string = ISO8601ToDDay(deadlineAt)
        } else {
            string = UNKNOWN_STRING
        }
        
        deadlineDescLabel.attributedText = NSAttributedString(string: string, attributes: descAttributes())
    }
}
