//
//  Comment.swift
//  SoBunSoBun
//
//  Created by 김태은 on 11/4/25.
//

import UIKit
import SnapKit
import Kingfisher
import RxSwift
import RxRelay
import RxGesture

// TODO: 수정이 많이 필요할 것 같은 컴포넌트입니다.
class Comment: UIView {
    // TODO: 임시 Model 추후 변경 필요
    struct CommentedUsers {
        let uuid: String
        let nickname: String
    }
    
    private let disposeBag = DisposeBag()
    
    let profileTapTrigger = PublishRelay<String>()
    let replyTrigger = PublishRelay<(commentUUID: String, authorUUID: String)>()
    let reportTrigger = PublishRelay<(commentUUID: String, authorUUID: String)>()
    let editTrigger = PublishRelay<String>()
    let deleteTrigger = PublishRelay<String>()
    
    init(frame: CGRect = .zero,
         commentUUID: String,
         authorUUID: String,
         profileImageUrl: String?,
         nickname: String,
         createdAt: String,
         region: String,
         comment: String,
         commentedUsers: [CommentedUsers]
    ) {
        super.init(frame: frame)
        
        configure(commentUUID: commentUUID,
                  authorUUID: authorUUID,
                  profileImageUrl: profileImageUrl,
                  nickname: nickname,
                  createdAt: createdAt,
                  region: region,
                  comment: comment,
                  commentedUsers: commentedUsers)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 디자인 요소
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.layer.cornerRadius = 24
        iv.clipsToBounds = true
        
        iv.snp.makeConstraints { make in
            make.size.equalTo(48)
        }
        
        return iv
    }()
    
    private let nicknameLabel: UILabel = {
        let lb = UILabel()
        lb.font = title14.font
        lb.textColor = .neutral900
        lb.numberOfLines = 1
        
        return lb
    }()
    
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
    
    private let descLabel: UILabel = {
        let lb = UILabel()
        lb.font = body14.font
        lb.textColor = .neutral500
        lb.numberOfLines = 0
        
        return lb
    }()
    
    private let commentLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 0
        
        return lb
    }()
    
    // MARK: - 멘션 처리 메서드
    private func processMentions(comment: String, commentedUsers: [CommentedUsers]) -> NSAttributedString {
        // TODO: 임시 멘션 <mention:uuid> 패턴 추후 수정 필요
        let pattern = "<mention:([^>]+)>"
        
        var text = comment
        var usersMap: [String: String] = [:]
        commentedUsers.forEach { usersMap[$0.uuid] = $0.nickname }
        
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            // 정규식 오류 시 기본 텍스트 return
            let defaultAttributedString = NSMutableAttributedString(string: comment)
            defaultAttributedString.setAttributes(body16.attributes(), range: NSRange(location: 0, length: comment.count))
            defaultAttributedString.addAttributes([.foregroundColor: UIColor.neutral900], range: NSRange(location: 0, length: comment.count))
            
            return defaultAttributedString
        }
        
        let matches = regex.matches(in: text, range: NSRange(text.startIndex..., in: text)).reversed()
        var mentionInfos: [(range: NSRange, uuid: String)] = []
        
        // <mention:uuid> -> @닉네임 변환
        for match in matches {
            let uuidRange = match.range(at: 1)
            let uuid = (text as NSString).substring(with: uuidRange)
            
            if let nickname = usersMap[uuid],
               let range = Range(match.range, in: text) {
                
                let replacement = "@\(nickname)"
                let location = match.range.location
                
                text.replaceSubrange(range, with: replacement)
                
                mentionInfos.insert((range: NSRange(location: location, length: replacement.count), uuid: uuid), at: 0)
            }
        }
        
        // AttributedString 생성
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.setAttributes([
            .foregroundColor: UIColor.neutral900,
            .font: body16.font,
            .paragraphStyle: title16.paragraphStyle,
            .baselineOffset: title16.attributes()[.baselineOffset]!
        ], range: NSRange(location: 0, length: text.count))
        
        // 멘션 부분 하이라이트 적용
        for info in mentionInfos {
            attributedString.setAttributes(title16.attributes(), range: info.range)
            attributedString.addAttributes([
                .foregroundColor: UIColor.primary400,
                .link: "profile://\(info.uuid)"
            ], range: info.range)
        }
        
        return attributedString
    }
    
    // MARK: - 레이아웃 설정
    private func configure(commentUUID: String,
                           authorUUID: String,
                           profileImageUrl: String?,
                           nickname: String,
                           createdAt: String,
                           region: String,
                           comment: String,
                           commentedUsers: [CommentedUsers]) {
        self.backgroundColor = .clear
        
        // 프로필 사진
        if let urlString = profileImageUrl,
           let url = URL(string: urlString) {
            profileImageView.kf.setImage(with: url)
        } else {
            // TODO: Asset의 프로필 이미지 추가
        }
        
        addSubview(profileImageView)
        
        profileImageView.isUserInteractionEnabled = true
        profileImageView.rx
            .tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.profileTapTrigger.accept(authorUUID)
            })
            .disposed(by: disposeBag)
        
        profileImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.top.equalToSuperview()
        }
        
        // 메뉴
        addSubview(menuButton)
        
        let replyAction = UIAction(title: "답장하기") { [weak self] _ in
            guard let self = self else { return }
            self.replyTrigger.accept((commentUUID, authorUUID))
        }
        
        let reportAction = UIAction(title: "신고하기", attributes: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.reportTrigger.accept((commentUUID, authorUUID))
        }
        
        /*
        let editAction = UIAction(title: "수정하기") { [weak self] _ in
            guard let self = self else { return }
            self.editTrigger.accept(commentUUID)
        }
        */
        
        let deleteAction = UIAction(title: "삭제하기", attributes: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.deleteTrigger.accept(commentUUID)
        }
        
        let myMenu = UIMenu(title: "", children: [deleteAction])
        let otherUserMenu = UIMenu(title: "", children: [replyAction, reportAction])
        
        // TODO: UUID keychain 목록에 추가됐을 경우 수정 필요
        if let myUUID = KeyChain.shared.get(key: "UUID") {
            menuButton.menu = myUUID == authorUUID ? myMenu : otherUserMenu
        }
        
        menuButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.top.equalToSuperview()
        }
        
        // 닉네임 label
        nicknameLabel.text = nickname
        
        addSubview(nicknameLabel)
        
        nicknameLabel.isUserInteractionEnabled = true
        nicknameLabel.rx
            .tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.profileTapTrigger.accept(authorUUID)
            })
            .disposed(by: disposeBag)
        
        nicknameLabel.snp.makeConstraints { make in
            make.leading.equalTo(profileImageView.snp.trailing).offset(8)
            make.trailing.equalTo(menuButton.snp.leading).inset(8)
            make.top.equalToSuperview()
        }
        
        // 작성일 | 지역 인증
        let RelativeDateString = ISO8601ToRelativeString(createdAt)
        let regionVerifiedString = String(format: NSLocalizedString("RegionVerified", comment: "region verified string"), region)
        
        descLabel.text = "\(RelativeDateString) | \(regionVerifiedString)"
        
        addSubview(descLabel)
        
        descLabel.snp.makeConstraints { make in
            make.leading.equalTo(profileImageView.snp.trailing).offset(8)
            make.trailing.equalTo(menuButton.snp.leading).inset(8)
            make.top.equalTo(nicknameLabel.snp.bottom).offset(4)
        }
        
        // 댓글
        commentLabel.attributedText = processMentions(comment: comment, commentedUsers: commentedUsers)
        
        addSubview(commentLabel)
        
        commentLabel.snp.makeConstraints { make in
            make.leading.equalTo(profileImageView.snp.trailing).offset(8)
            make.trailing.equalToSuperview().inset(16)
            make.top.equalTo(descLabel.snp.bottom).offset(8)
            make.bottom.equalToSuperview()
        }
    }
}
