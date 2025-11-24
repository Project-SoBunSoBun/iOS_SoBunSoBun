//
//  Incomplete.swift
//  SoBunSoBun
//
//  Created by 허성필 on 11/12/25.
//

import UIKit
import SnapKit

class Incomplete: UIView {
    init(frame: CGRect = .zero,
         SettleUpStatus: Bool,
         title: String,
         location: String,
         meetingDate: String // ISO 8601 문자열
    ) {
        super.init(frame: frame)
        
        configureUI(SettleUpStatus: SettleUpStatus,
                    title: title,
                    location: location,
                    meetingDate: meetingDate)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 디자인 요소
    // 정산 여부 상태 label
    private let statusLabel: PaddingLabel = {
        let lb = PaddingLabel()
        lb.padding = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        lb.backgroundColor = .neutral50
        lb.font = title12.font
        lb.textAlignment = .center
        lb.layer.cornerRadius = 8
        lb.clipsToBounds = true
        
        return lb
    }()
    
    // 제목 label
    private let titleLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = .neutral900
        lb.font = title18.font
        
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
    
    // 정산하기 버튼
    private let settleUpButton: UIButton = {
        let bt = UIButton()
        var config = UIButton.Configuration.filled()
        
        var attributedString = AttributedString(String(localized: "SettleUpStart"))
        attributedString.font = title14.font
        
        config.attributedTitle = attributedString
        config.baseBackgroundColor = .primary400
        config.baseForegroundColor = .backgroundWhite
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 10)
        
        bt.configuration = config
        bt.layer.cornerRadius = 12
        bt.clipsToBounds = true
        
        return bt
    }()
    
    // 정산서 확인 버튼
    private let statementCheckButton: UIButton = {
        let bt = UIButton()
        var config = UIButton.Configuration.filled()
        
        var attributedString = AttributedString(String(localized: "SettleUpCheck"))
        attributedString.font = title14.font
        
        config.attributedTitle = attributedString
        config.baseBackgroundColor = .primary50
        config.baseForegroundColor = .primary400
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 10)
        
        bt.configuration = config
        bt.layer.cornerRadius = 12
        bt.clipsToBounds = true
        
        return bt
    }()
    
    // 공유 버튼
    private let shareButton: UIButton = {
        let bt = UIButton()
        var config = UIButton.Configuration.filled()
        
        var attributedString = AttributedString(String(localized: "Share"))
        attributedString.font = title14.font
        
        config.attributedTitle = attributedString
        config.baseBackgroundColor = .primary50
        config.baseForegroundColor = .primary400
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 10)
        
        bt.configuration = config
        bt.layer.cornerRadius = 12
        bt.clipsToBounds = true
        
        return bt
    }()
    
    // 점 세개 버튼
    private let menuButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = .greyHorizontalDot
        config.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        let btn = UIButton(configuration: config)
        btn.showsMenuAsPrimaryAction = true
        
        btn.snp.makeConstraints { make in
            make.size.equalTo(24)
        }
        
        return btn
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: 12).cgPath
    }
    
    // MARK: - 레이아웃 설정
    private func configureUI(
        SettleUpStatus: Bool,
        title: String,
        location: String,
        meetingDate: String) {
            self.backgroundColor = .backgroundWhite
            
            // border 설정
            self.layer.cornerRadius = 12
            self.layer.borderWidth = 2
            self.layer.borderColor = UIColor.primary50.cgColor
            
            // 그림자 설정
            self.layer.shadowColor = UIColor.primary300.withAlphaComponent(0.16).cgColor
            self.layer.shadowOpacity = 1
            self.layer.shadowRadius = 24
            self.layer.shadowOffset = CGSize(width: 0, height: 0)
            
            self.clipsToBounds = false
            
            [statusLabel, titleLabel, locationStackView, dateStackView, settleUpButton, statementCheckButton, shareButton, menuButton].forEach {
                self.addSubview($0)
            }
            
            // 정산 여부 분기 처리
            if SettleUpStatus {
                statusLabel.attributedText = NSAttributedString(string: String(localized: "SettleUpComplete"), attributes: title12.attributes())
                statusLabel.textColor = .review2
                settleUpButton.isHidden = true
            } else {
                statusLabel.attributedText = NSAttributedString(string: String(localized: "SettleUpIncomplete"), attributes: title12.attributes())
                statusLabel.textColor = .errorRed
                statementCheckButton.isHidden = true
                shareButton.isHidden = true
                menuButton.isHidden = true
            }
            
            // 정산 여부 Label
            statusLabel.snp.makeConstraints { make in
                make.leading.equalToSuperview().inset(16)
                make.top.equalToSuperview().offset(16)
            }
            
            // 제목
            titleLabel.attributedText = NSAttributedString(string: title, attributes: title18.attributes())
            
            titleLabel.snp.makeConstraints { make in
                make.horizontalEdges.equalToSuperview().inset(16)
                make.top.equalTo(statusLabel.snp.bottom).offset(8)
            }
            
            // 장소
            [locationIcon, locationLabel].forEach {
                locationStackView.addArrangedSubview($0)
            }
            
            locationLabel.text = location
            
            locationStackView.snp.makeConstraints { make in
                make.horizontalEdges.equalToSuperview().inset(16)
                make.top.equalTo(titleLabel.snp.bottom).offset(8)
            }
            
            // 시간
            [dateIcon, dateLabel].forEach {
                dateStackView.addArrangedSubview($0)
            }
            
            dateLabel.text = ISO8601ToLocalizedDateTimeString(meetingDate, isFormatColon: false)
            
            dateStackView.snp.makeConstraints { make in
                make.horizontalEdges.equalToSuperview().inset(16)
                make.top.equalTo(locationStackView.snp.bottom).offset(4)
            }
            
            // 정산하기 버튼
            settleUpButton.snp.makeConstraints { make in
                make.trailing.equalToSuperview().inset(16)
                make.top.equalTo(dateStackView.snp.bottom).offset(8)
                make.bottom.equalToSuperview().inset(16)
            }
            
            //TODO: 공유하기 버튼은 방장만 가능하므로, 백엔드와 상의 후 if문으로 레이아웃 처리하기
            // 공유하기 버튼
            shareButton.snp.makeConstraints { make in
                make.trailing.equalToSuperview().inset(16)
                make.top.equalTo(dateStackView.snp.bottom).offset(8)
                make.bottom.equalToSuperview().inset(16)
            }
            
            // 정산서 확인 버튼
            statementCheckButton.snp.makeConstraints { make in
                make.trailing.equalTo(shareButton.snp.leading).offset(-8)
                make.top.equalTo(dateStackView.snp.bottom).offset(8)
                make.bottom.equalToSuperview().inset(16)
            }
            
            // 메뉴 버튼
            menuButton.snp.makeConstraints { make in
                make.trailing.equalToSuperview().inset(16)
                make.top.equalTo(statusLabel.snp.top)
            }
        }
}
