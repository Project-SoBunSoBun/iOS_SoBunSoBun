//
//  AnnouncementCellView.swift
//  SoBunSoBun
//
//  Created by 허성필 on 2/14/26.
//

import UIKit

class AnnouncementCellView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 디자인 요소
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.spacing = 8
        sv.axis = .vertical
        sv.alignment = .leading
        sv.distribution = .fill
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = .init(top: 16, left: 16, bottom: 16, right: 16)
        sv.isUserInteractionEnabled = true
        
        return sv
    }()
    
    private let titleLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 0
        
        return lb
    }()
    
    private let divider: UIView = {
        let v = UIView()
        v.backgroundColor = .neutral100
        
        return v
    }()
    
    private let dateLable = UILabel()
    
    // MARK: - 레이아웃 설정
    private func configureUI() {
        self.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.horizontalEdges.top.equalToSuperview()
        }
        
        [titleLabel, dateLable].forEach {
            stackView.addArrangedSubview($0)
        }
        
        self.addSubview(divider)
        
        divider.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(stackView.snp.bottom)
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    func configure(item: AnnouncementContentModel) {
        let titleString = item.title
        let dateString = formatISO8601Date(item.createdAt)
        
        var titleAttributes = body16.attributes(alignment: .left)
        titleAttributes[.foregroundColor] = UIColor.neutral900
        
        let titleAttributedText = NSAttributedString(
            string: titleString,
            attributes: titleAttributes
        )
        
        titleLabel.attributedText = titleAttributedText
        
        var dateAttributes = body14.attributes(alignment: .left)
        dateAttributes[.foregroundColor] = UIColor.neutral400
        
        let dateAttributedText = NSAttributedString(
            string: dateString,
            attributes: dateAttributes
        )
        
        dateLable.attributedText = dateAttributedText
    }
}
