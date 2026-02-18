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
    
    private let view = AnnouncementCellView()
    
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
    
    // MARK: - 레이아웃 설정
    private func configureUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(view)
        
        view.snp.makeConstraints { make in
            make.horizontalEdges.top.equalToSuperview()
            make.bottom.equalToSuperview().priority(.high)
        }
    }
    
    func configureUI(model: AnnouncementContentModel) {
        view.configure(item: model)
        view.layoutIfNeeded()
    }
}
