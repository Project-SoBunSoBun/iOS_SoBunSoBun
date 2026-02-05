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
    
    private let view = CommentView()
    
    let replyTap = PublishRelay<Void>()
    let reportTap = PublishRelay<Void>()
    let editTap = PublishRelay<Void>()
    let deleteTap = PublishRelay<Void>()
    
    private var disposeBag = DisposeBag()
    
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
            make.horizontalEdges.top.equalToSuperview()
            make.bottom.equalToSuperview().priority(.high)
        }
    }

    func configureUI(model: CommentModel, commentedUsers: [String: String]) {
        view.configureUI(model: model, commentedUsers: commentedUsers)
    }
}

extension CommentTableViewCell {
    private func bind() {
        view.replyTap
            .bind(to: replyTap)
            .disposed(by: disposeBag)
        
        view.reportTap
            .bind(to: reportTap)
            .disposed(by: disposeBag)
        
        view.editTap
            .bind(to: editTap)
            .disposed(by: disposeBag)
        
        view.deleteTap
            .bind(to: deleteTap)
            .disposed(by: disposeBag)
    }
}
