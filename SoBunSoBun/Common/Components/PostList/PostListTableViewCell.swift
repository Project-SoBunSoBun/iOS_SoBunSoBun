//
//  PostListTableViewCell.swift
//  SoBunSoBun
//
//  Created by 김태은 on 11/30/25.
//

import UIKit
import RxSwift
import SnapKit

class PostListTableViewCell: UITableViewCell {
    static let identifier = "PostListTableViewCell"
    
    private var disposeBag = DisposeBag()
    
    private var view: PostList?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        view?.removeFromSuperview()
        view = nil
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configureUI(model: PostModel, isLast: Bool = false) {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        let view = PostList(model: model)
        
        contentView.addSubview(view)
        
        view.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview().inset(isLast
                                                 ? 8 + BottomNavigationBar.SHADOW_HEIGHT + 8 + 8
                                                 : 0).priority(.high) // 중요 우선순위
        }
        
        self.view = view
        
        // TODO: 현재 이 코드를
        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()
    }
}
