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
    
    private var isMenuOpen: Bool = false
    
    let replyTap = PublishRelay<Void>()
    let reportTap = PublishRelay<Void>()
    let editTap = PublishRelay<Void>()
    let deleteTap = PublishRelay<Void>()
    
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
    
    private let dropDownView: DropDownView = DropDownView(selectionMode: .plain, tableName: "Home")
    
    private let commentLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 0
        
        return lb
    }()
    
    // MARK: - 댓글 AttributedText 변환
    private func convertComment(comment: String, commentedUsers: [String: String], isEdited: Bool) -> NSAttributedString {
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
        
        let attributedString = NSMutableAttributedString(string: convertedText)
        
        // 기본 텍스트 색상
        var defaultAttributes: [NSAttributedString.Key: Any] = body16.attributes()
        defaultAttributes[.foregroundColor] = UIColor.neutral900
        
        attributedString.addAttributes(defaultAttributes, range: NSRange(location: 0, length: convertedText.count))
        
        // 멘션 하이라이트 처리
        for model in mentionModels {
            var mentionAttributes: [NSAttributedString.Key: Any] = title16.attributes()
            mentionAttributes[.foregroundColor] = UIColor.primary400
            mentionAttributes[.link] = "profile://\(model.userId)" // TODO: 프로필 뷰로 이동하는 하이퍼링크 수정
            attributedString.addAttributes(mentionAttributes, range: model.range)
        }
        
        // 수정됨 처리
        if isEdited {
            var editedAttributes: [NSAttributedString.Key: Any] = body16.attributes()
            editedAttributes[.foregroundColor] = UIColor.neutral500
            
            let localizableString: String = String(localized: "Edited", table: "Home")
            let editedText: NSAttributedString = NSAttributedString(string: " (\(localizableString))", attributes: editedAttributes)
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
            make.horizontalEdges.equalToSuperview().offset(16)
            make.top.equalToSuperview()
        }
        
        // 메뉴 버튼
        addSubview(menuButton)
        
        menuButton.snp.makeConstraints { make in
            make.trailing.top.equalTo(authorInfoView)
        }
        
        addSubview(dropDownView)
        
        dropDownView.snp.makeConstraints { make in
            make.trailing.equalTo(menuButton)
            make.top.equalTo(menuButton.snp.bottom)
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
        
        // 메뉴
        let myId = KeyChain.shared.get(key: "USER_ID")
        let menu: [String]
        
        if let myId, let myUserId = Int(myId) {
            menu = model.userId == myUserId ?
            ["Reply", "Edit", "Delete"] :
            ["Reply", "Report"]
        } else {
            menu = []
        }
        
        dropDownView.items = menu
        
        // 댓글
        commentLabel.attributedText = convertComment(
            comment: model.content ?? "",
            commentedUsers: commentedUsers,
            isEdited: model.edited
        )
    }
}

extension CommentView {
    private func bind() {
        menuButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                isMenuOpen.toggle()
                dropDownView.setOpen(isOpen: isMenuOpen)
            })
            .disposed(by: disposeBag)
        
        dropDownView.didCellTap
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                isMenuOpen = false
                dropDownView.setOpen(isOpen: isMenuOpen)
            })
            .subscribe(onNext: { [weak self] tap in
                guard let self = self else { return }
                
                switch tap {
                case "Reply":
                    replyTap.accept(())
                    
                case "Report":
                    reportTap.accept(())
                    
                case "Edit":
                    editTap.accept(())
                    
                case "Delete":
                    deleteTap.accept(())
                    
                default:
                    logger.error("DropDownCell에서 didCellTap을 구독 받는 중 무언가 잘못 됨")
                }
            })
            .disposed(by: disposeBag)
    }
}
