//
//  CommentView.swift
//  SoBunSoBun
//
//  Created by 김태은 on 11/4/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxGesture
import OSLog

class CommentView: UIView {
    private let disposeBag = DisposeBag()
    
    var isMenuOpen: Bool = false
    
    let menuTap = PublishRelay<UIButton>()
    
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "Comment"
    )
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 디자인 요소
    private let authorInfoView = AuthorInfoView()
    
    private let menuButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = .greyHorizontalDot
        config.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        let btn = UIButton(configuration: config)
        
        btn.snp.makeConstraints { make in
            make.size.equalTo(24)
        }
        
        return btn
    }()
    
    private let commentLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 0
        
        return lb
    }()
    
    // MARK: - 댓글 AttributedText 변환
    static func convertComment(comment: String, commentedUsers: [String: String], isEdited: Bool) -> NSAttributedString {
        // 변환된 텍스트
        var convertedText = comment
        
        // 멘션 처리
        struct MentionModel {
            let range: NSRange
            let userId: String
        }
        
        let pattern = "<mention:id-(\\d+)>"
        var mentionModels: [MentionModel] = []
        
        if let regex = try? NSRegularExpression(pattern: pattern) {
            let matches = regex.matches(in: comment, range: NSRange(comment.startIndex..., in: comment))
            
            // 뒤에서부터 처리 (인덱스 꼬임 방지)
            for match in matches.reversed() {
                let userId = (comment as NSString).substring(with: match.range(at: 1))
                
                guard let nickname = commentedUsers[userId],
                      let matchRange = Range(match.range, in: convertedText) else {
                    continue
                }
                
                let mentionText = "@\(nickname)"
                let location = match.range.location
                
                convertedText.replaceSubrange(matchRange, with: mentionText)
                
                let model: MentionModel = MentionModel(
                    range: NSRange(location: location, length: mentionText.count),
                    userId: userId
                )
                
                mentionModels.append(model)
            }
        }
        
        // 멘션 존재 여부에 따라 스타일 변경
        let baseStyle = mentionModels.isEmpty ? body16 : title16
        let baseAttributes = baseStyle.attributes()
        let commonParagraphStyle = baseAttributes[.paragraphStyle] as? NSParagraphStyle
        let commonBaselineOffset = baseAttributes[.baselineOffset] as? CGFloat ?? 0
        
        let attributedString = NSMutableAttributedString(string: convertedText)
        
        // 기본 텍스트
        attributedString.addAttributes([
            .font: body16.font,
            .foregroundColor: UIColor.neutral900,
            .paragraphStyle: commonParagraphStyle as Any,
            .baselineOffset: commonBaselineOffset
        ], range: NSRange(location: 0, length: convertedText.count))
        
        // 멘션 하이라이트 처리
        for model in mentionModels {
            attributedString.addAttributes([
                .font: title16.font,
                .foregroundColor: UIColor.primary400,
                .link: "sobunsobun://profile/\(model.userId)",
                .paragraphStyle: commonParagraphStyle as Any,
                .baselineOffset: commonBaselineOffset
            ], range: model.range)
        }
        
        // 수정됨 처리
        if isEdited {
            let localizableString = String(localized: "Edited", table: "Home")
            let editedText = NSAttributedString(string: " (\(localizableString))", attributes: [
                .font: body16.font,
                .foregroundColor: UIColor.neutral500,
                .paragraphStyle: commonParagraphStyle as Any,
                .baselineOffset: commonBaselineOffset
            ])
            attributedString.append(editedText)
        }
        
        return attributedString
    }
    
    // MARK: - UI 설정
    private func configureUI() {
        self.backgroundColor = .clear
        
        // 사용자 정보
        addSubview(authorInfoView)
        
        authorInfoView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview().inset(32)
            make.top.equalToSuperview()
        }
        
        // 메뉴 버튼
        addSubview(menuButton)
        
        menuButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.top.equalTo(authorInfoView)
        }
        
        // 댓글
        addSubview(commentLabel)
        
        commentLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(AuthorInfoView.PROFILE_IMAGE_SIZE + 8)
            make.trailing.equalToSuperview().inset(16)
            make.top.equalTo(authorInfoView.snp.bottom).offset(8)
            make.bottom.equalToSuperview()
        }
    }
    
    func configureUI(model: CommentModel, commentedUsers: [String: String]) {
        // 사용자 정보
        authorInfoView.configureUI(
            profileImageUrl: model.userProfileImageUrl,
            nickname: model.userNickname,
            createdAt: model.createdAt,
            verifyLocation: model.userAddress
        )
        
        // 댓글
        commentLabel.attributedText = CommentView.convertComment(
            comment: model.content ?? "",
            commentedUsers: commentedUsers,
            isEdited: model.edited
        )
    }
}

extension CommentView {
    private func bind() {
        menuButton.rx.tap
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                menuTap.accept(self.menuButton)
            })
            .disposed(by: disposeBag)
    }
}
