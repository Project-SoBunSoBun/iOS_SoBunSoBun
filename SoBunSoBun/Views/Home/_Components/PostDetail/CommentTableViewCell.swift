//
//  CommentTableViewCell.swift
//  SoBunSoBun
//
//  Created by 김태은 on 2/5/26.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class CommentTableViewCell: UITableViewCell {
    static let identifier = "PostListTableViewCell"
    
    let view = CommentView()
    
    let menuTap = PublishRelay<UIButton>()
    
    var disposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureUI()
        bind()
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
        bind()
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

    func configureUI(model: CommentModel, commentedUsers: [String: String]) {
        view.configureUI(model: model, commentedUsers: commentedUsers)
    }
    
    func toggleEditMode(_ isEdit: Bool) {
        view.backgroundColor = isEdit ? .primary50 : .clear
    }
}

extension CommentTableViewCell {
    private func bind() {
        view.menuTap
            .bind(to: menuTap)
            .disposed(by: disposeBag)
    }
}
