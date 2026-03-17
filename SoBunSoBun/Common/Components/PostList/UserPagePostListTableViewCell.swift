//
//  UserPagePostListTableViewCell.swift
//  SoBunSoBun
//
//  Created by 김태은 on 11/2/26.
//

import UIKit
import SnapKit
import RxSwift

class UserPagePostListTableViewCell: UITableViewCell {
    static let identifier = "UserPagePostListTableViewCell"
    
    private let view = UserPagePostListCellView()
    private var disposeBag = DisposeBag()
    
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
        disposeBag = DisposeBag()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    private func configureUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(view)
        
        view.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().inset(24).priority(.high)
        }
    }
    
    func configureUI(model: PostModel) {
        view.configureUI(model: model)
        view.layoutIfNeeded()
    }
}
