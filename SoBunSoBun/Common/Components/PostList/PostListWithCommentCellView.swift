//
//  PostListWithCommentCellView.swift
//  SoBunSoBun
//
//  Created by 김태은 on 10/22/25.
//

import UIKit
import SnapKit

class PostListWithCommentCellView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
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
    private let titleLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 0
        
        return lb
    }()
    
    private let commentLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 0
        
        return lb
    }()
    
    // 설명(장소 및 시간) attributes 컴포넌트
    private func descAttributes() -> [NSAttributedString.Key: Any] {
        var attributes: [NSAttributedString.Key: Any] = body14.attributes()
        attributes[.foregroundColor] = UIColor.neutral500
        
        return attributes
    }
    
    private let dateLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 0
        
        return lb
    }()
    
    private let divider: UIView = {
        let view = UIView()
        view.backgroundColor = .primary100
        
        return view
    }()
    
    // MARK: - 레이아웃 설정
    private func configureUI() {
        [titleLabel, commentLabel, dateLabel, divider].forEach {
            addSubview($0)
        }
        
        // 제목
        titleLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(16)
        }
        
        // 댓글
        commentLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
        }
        
        // 날짜 및 시간
        dateLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(commentLabel.snp.bottom).offset(8)
        }
        
        // 구분선
        divider.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalToSuperview()
            make.top.equalTo(dateLabel.snp.bottom).offset(16)
            make.height.equalTo(1)
        }
    }
    
    func configureUI(model: PostModel) {
        // 제목
        var titleAttributes: [NSAttributedString.Key: Any] = title18.attributes(alignment: .left)
        titleAttributes[.foregroundColor] = UIColor.neutral900
        
        titleLabel.attributedText = NSAttributedString(string: model.title, attributes: titleAttributes)
        
        // 댓글
        var commentAttributes: [NSAttributedString.Key: Any] = body16.attributes(alignment: .left)
        commentAttributes[.foregroundColor] = UIColor.neutral900
        
        let pattern = "<mention:id-(\\d+)>"
        let comment = model.latestComment?.content
            .replacingOccurrences(of: pattern, with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespaces)
        commentLabel.attributedText = NSAttributedString(string: comment ?? "", attributes: commentAttributes)
        
        // 시간 및 인원 표시
        dateLabel.attributedText = NSAttributedString(string: ISO8601ToLocalizedDateTimeString(model.meetAt), attributes: descAttributes())
        
        var joinedAttributes: [NSAttributedString.Key: Any] = title12.attributes(alignment: .right)
        joinedAttributes[.foregroundColor] = model.joinedMembers + 1 >= model.maxMembers ? UIColor.primary400 : UIColor.neutral300
    }
    
    // 구분선 표시 변경 함수
    private func changeShowDivider(_ isDividerHidden: Bool) {
        divider.isHidden = isDividerHidden
    }
}
