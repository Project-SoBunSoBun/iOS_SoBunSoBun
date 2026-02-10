//
//  MentionTextView.swift
//  SoBunSoBun
//
//  Created by 김태은 on 2/8/26.
//

import UIKit
import RxSwift
import RxCocoa

class MentionTextView: AutoHeightTextView {
    var disposeBag = DisposeBag()
    
    let commentedUsersToId = BehaviorRelay<[String: Int]>(value: [:])
    
    override init(minHeight: CGFloat, maxHeight: CGFloat, maxLength: Int, fontStyle: FontStyle) {
        super.init(minHeight: minHeight, maxHeight: maxHeight, maxLength: maxLength, fontStyle: fontStyle)
        
        // 멘션 스타일 재설정
        self.linkTextAttributes = [:]
        
        bind()
        
        // rx.setDelegate는 불안정하여 delegate 패턴으로 진행
        self.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func convertMentionAttributes(text: String) {
        // 텍스트가 비어있을 때
        guard !text.isEmpty else { return }
        
        // 긴 닉네임 우선
        let nicknames = commentedUsersToId.value.keys.sorted { $0.count > $1.count }
        
        // 전체 텍스트 범위
        let textRange = NSRange(location: 0, length: text.count)
        
        var matches: [NSTextCheckingResult] = []
        
        if !nicknames.isEmpty {
            // 닉네임들을 or 연산자로 join
            let nicknamePattern = nicknames.map { NSRegularExpression.escapedPattern(for: $0) }.joined(separator: "|")
            let pattern = "@(\(nicknamePattern))"
            
            // 정규식으로 매치함
            if let regex = try? NSRegularExpression(pattern: pattern) {
                matches = regex.matches(in: text, range: textRange)
            }
        }
        
        // 기본 폰트 스타일
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttributes([
            .font: body16.font,
            .foregroundColor: UIColor.neutral900
        ], range: textRange)
        
        // 멘션 부분 하이라이트
        for match in matches.reversed() {
            let nickname = (text as NSString).substring(with: match.range(at: 1))
            
            if let userId = commentedUsersToId.value[nickname] {
                attributedString.addAttributes([
                    .font: title16.font,
                    .foregroundColor: UIColor.primary400,
                    .link: "sobunsobun://profile/\(userId)"
                ], range: match.range)
            }
        }
        
        // 커서 위치 저장
        let tempRange = self.selectedRange
        
        // attributedText로 변환
        self.attributedText = attributedString
        
        // 커서 위치 재조정
        self.selectedRange = tempRange
    }
    
    // 스타일 충돌 문제로 인한 applyLineHeight 덮어쓰기
    override func applyLineHeight() {
        convertMentionAttributes(text: self.text)
    }
}

// Atomic Deletion을 위한 Delegate
extension MentionTextView: UITextViewDelegate {
    private func bind() {
        commentedUsersToId
            .skip(1)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                convertMentionAttributes(text: self.text)
            })
            .disposed(by: disposeBag)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text.isEmpty, let attributedText = textView.attributedText {
            var mentionRange = NSRange()
            
            if range.location < attributedText.length,
               // .link 속성 확인 후 전체 범위를 mentionRange 변수에 메모리 주소를 넣음
               let _ = attributedText.attribute(.link, at: range.location, effectiveRange: &mentionRange) {
                
                // attributedText 복사
                let mutableAttr = NSMutableAttributedString(attributedString: attributedText)
                
                // 멘션 범위 삭제
                mutableAttr.replaceCharacters(in: mentionRange, with: "")
                
                // 문자열 삭제
                textView.attributedText = mutableAttr
                
                // 커서 위치 조정
                textView.selectedRange = NSRange(location: mentionRange.location, length: 0)
                
                return false
            }
        }
        
        return true
    }
}
