//
//  AnnouncementTableViewCell.swift
//  SoBunSoBun
//
//  Created by 허성필 on 2/13/26.
//

import UIKit
import SnapKit

class AnnouncementTableViewCell: UITableViewCell {
    static let identifier = "AnnouncementTableViewCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
    
    private let dateLable = UILabel()
    
    // MARK: - 레이아웃 설정
    private func configureUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        [titleLabel, dateLable].forEach {
            stackView.addArrangedSubview($0)
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
