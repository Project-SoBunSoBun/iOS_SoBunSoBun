//
//  UserPagePostListDeletableTableViewCell.swift
//  SoBunSoBun
//
//  Created by 허성필 on 2/27/26.
//

import UIKit
import SnapKit
import RxSwift

class UserPagePostListDeletableTableViewCell: UITableViewCell {
    static let identifier = "UserPAgePostListDeletableTableViewCell"
    
    private let view = UserPagePostListDeletableCellView()
    var disposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var didTapMenu: Observable<Void> {
        return view.didTap.asObservable()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

    private func configureUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(view)
        
        view.snp.makeConstraints { make in
            make.horizontalEdges.top.equalToSuperview()
            make.bottom.equalToSuperview().inset(24).priority(.high)
        }
    }
    
    func configureUI(model: PostModel) {
        view.configureUI(model: model)
        view.layoutIfNeeded()
    }
}
