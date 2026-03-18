//
//  PostListTableViewCell.swift
//  SoBunSoBun
//
//  Created by 김태은 on 11/30/25.
//

import UIKit
import SnapKit
import RxSwift

class PostListTableViewCell: UITableViewCell {
    static let identifier = "PostListTableViewCell"
    
    private let view = PostListCellView()
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
            make.horizontalEdges.top.equalToSuperview()
            make.bottom.equalToSuperview().priority(.high)
        }
    }
    
    func configureUI(model: PostModel, horizontalEdgesInset: CGFloat = 0) {
        view.configureUI(model: model)
        
        if horizontalEdgesInset != 0 {
            view.snp.remakeConstraints { make in
                make.horizontalEdges.equalToSuperview().inset(horizontalEdgesInset)
                make.top.equalToSuperview()
                make.bottom.equalToSuperview().priority(.high)
            }
        }
        
        view.layoutIfNeeded()
    }
}
