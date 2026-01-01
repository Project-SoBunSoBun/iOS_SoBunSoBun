//
//  InformationCard.swift
//  SoBunSoBun
//
//  Created by 김태은 on 11/3/25.
//

import UIKit
import SnapKit

class InformationCard: UIView {
    /// dateTimeString은 ISO 8601(DateTime) 형식의 문자열입니다.
    init(frame: CGRect = .zero,
         minCount: Int,
         maxCount: Int,
         location: String,
         dateTimeString: String) {
        super.init(frame: frame)
        
        configure(minCount: minCount,
                  maxCount: maxCount,
                  location: location,
                  dateTimeString: dateTimeString)
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
    
    // 제목 label 컴포넌트
    private func titleLabel() -> UILabel {
        let lb = UILabel()
        lb.font = title16.font
        lb.textColor = .neutral900
        lb.numberOfLines = 1
        lb.textAlignment = .left
        
        return lb
    }
    
    // 설명 label 컴포넌트
    private func descLabel() -> UILabel {
        let lb = UILabel()
        lb.font = body16.font
        lb.textColor = .neutral700
        lb.numberOfLines = 1
        lb.textAlignment = .right
        
        return lb
    }
    
    // 모집 인원
    private lazy var participantsStackView: UIStackView = horizontalStackView()
    private lazy var participantsTitleLabel: UILabel = {
        let lb = titleLabel()
        lb.text = String(localized: "NumberOfParticipants")
        
        return lb
    }()
    private lazy var participantsDescLabel: UILabel = descLabel()
    
    // 지점 위치
    private lazy var meetingLocationStackView: UIStackView = horizontalStackView()
    private lazy var meetingLocationTitleLabel: UILabel = {
        let lb = titleLabel()
        lb.text = String(localized: "MeetingLocation")
        
        return lb
    }()
    private lazy var meetingLocationDescLabel: UILabel = descLabel()
    
    // 날짜 및 시간
    private lazy var dateTimeStackView: UIStackView = horizontalStackView()
    private lazy var dateTimeTitleLabel: UILabel = {
        let lb = titleLabel()
        lb.text = String(localized: "DateTime")
        
        return lb
    }()
    private lazy var dateTimeDescLabel: UILabel = descLabel()
    
    // 마감일
    private lazy var deadlineStackView: UIStackView = horizontalStackView()
    private lazy var deadlineTitleLabel: UILabel = {
        let lb = titleLabel()
        lb.text = String(localized: "Deadline")
        
        return lb
    }()
    private lazy var deadlineDescLabel: UILabel = descLabel()
    
    // MARK: - 레이아웃 설정
    private func configure(
        minCount: Int,
        maxCount: Int,
        location: String,
        dateTimeString: String) {
            self.backgroundColor = .primary50
            self.layer.cornerRadius = 16
            self.clipsToBounds = true
            
            // 모집 인원
            participantsStackView.addArrangedSubview(participantsTitleLabel)
            participantsStackView.addArrangedSubview(participantsDescLabel)
            participantsDescLabel.text = String(format: NSLocalizedString("ParticipantCount", comment: "participants minimum and maximum counts"), minCount, maxCount)
            
            addSubview(participantsStackView)
            
            participantsStackView.snp.makeConstraints { make in
                make.horizontalEdges.top.equalToSuperview().inset(16)
            }
            
            // 지점 위치
            meetingLocationStackView.addArrangedSubview(meetingLocationTitleLabel)
            meetingLocationStackView.addArrangedSubview(meetingLocationDescLabel)
            meetingLocationDescLabel.text = location
            
            addSubview(meetingLocationStackView)
            
            meetingLocationStackView.snp.makeConstraints { make in
                make.horizontalEdges.equalToSuperview().inset(16)
                make.top.equalTo(participantsStackView.snp.bottom).offset(8)
            }
            
            // 날짜 및 시간
            dateTimeStackView.addArrangedSubview(dateTimeTitleLabel)
            dateTimeStackView.addArrangedSubview(dateTimeDescLabel)
            dateTimeDescLabel.text = ISO8601ToLocalizedDateTimeString(dateTimeString)
            
            addSubview(dateTimeStackView)
            
            dateTimeStackView.snp.makeConstraints { make in
                make.horizontalEdges.equalToSuperview().inset(16)
                make.top.equalTo(meetingLocationStackView.snp.bottom).offset(8)
            }
            
            // 마감일
            deadlineStackView.addArrangedSubview(deadlineTitleLabel)
            deadlineStackView.addArrangedSubview(deadlineDescLabel)
            deadlineDescLabel.text = ISO8601ToDDay(dateTimeString)
            
            addSubview(deadlineStackView)
            
            deadlineStackView.snp.makeConstraints { make in
                make.horizontalEdges.bottom.equalToSuperview().inset(16)
                make.top.equalTo(dateTimeStackView.snp.bottom).offset(8)
            }
        }
}
