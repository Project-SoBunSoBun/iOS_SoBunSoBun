//
//  ChatTableViewCell.swift
//  SoBunHaeYo
//
//  Created by 김태은 on 2/15/26.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxGesture

class ChatTableViewCell: UITableViewCell {
    static let identifier = "ChatTableViewCell"
    
    let didImageLoad = PublishRelay<Void>()
    let didTextLongPressed = PublishRelay<UIView>()
    let didImageTapped = PublishRelay<UIImage?>()
    let didInviteCardButtonTapped = PublishRelay<Int>()
    let didSettlementCardButtonTapped = PublishRelay<Int>()
    
    var disposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        contentView.subviews.forEach {
            $0.removeFromSuperview()
        }
        
        disposeBag = DisposeBag()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    var chatCellView: UIView = UIView()
    
    private func configureUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
    }
    
    func configureUI(model: ChatMessageModel, isMine: Bool, isFirstChatOfDay: Bool) {
        let dateView = ChatDateCellView(date: model.createdAt)
        
        if isFirstChatOfDay {
            contentView.addSubview(dateView)
            
            dateView.snp.makeConstraints { make in
                make.top.equalToSuperview()
                make.width.greaterThanOrEqualTo(UIScreen.main.bounds.width * 0.5867)
                make.centerX.equalToSuperview()
            }
        }
        
        if model.type == .SYSTEM || model.type == .ENTER || model.type == .LEAVE {
            let chatView = SystemChatCellView(model: model)
            
            contentView.addSubview(chatView)
            
            chatView.snp.makeConstraints { make in
                make.width.greaterThanOrEqualTo(UIScreen.main.bounds.width * 0.5867)
                make.centerX.equalToSuperview()
                
                if isFirstChatOfDay {
                    make.top.equalTo(dateView.snp.bottom).offset(16)
                } else {
                    make.top.equalToSuperview()
                }
                
                make.bottom.equalToSuperview().inset(16).priority(.high)
            }
            
            return
        }
        
        chatCellView = isMine ? MyChatCellView() : OtherUserChatCellView()
        
        contentView.addSubview(chatCellView)
        
        if let myView = chatCellView as? MyChatCellView {
            myView.configureUI(model: model)
            
            myView.didImageLoad
                .do(onNext: { [weak self] in
                    guard let self = self else { return }
                    
                    updateTableView()
                })
                .bind(to: didImageLoad)
                .disposed(by: disposeBag)
            
            myView.chatLabel.rx
                .longPressGesture()
                .when(.began)
                .map { _ in myView.chatBubbleView }
                .bind(to: didTextLongPressed)
                .disposed(by: disposeBag)
            
            myView.chatImageView.rx
                .tapGesture()
                .when(.recognized)
                .map { _ in myView.chatImageView.image }
                .bind(to: didImageTapped)
                .disposed(by: disposeBag)
        } else if let otherView = chatCellView as? OtherUserChatCellView {
            otherView.configureUI(model: model)
            otherView.bind(model: model)
            
            otherView.didImageLoad
                .do(onNext: { [weak self] in
                    guard let self = self else { return }
                    
                    updateTableView()
                })
                .bind(to: didImageLoad)
                .disposed(by: disposeBag)
            
            otherView.chatLabel.rx
                .longPressGesture()
                .when(.began)
                .map { _ in otherView.chatBubbleView }
                .bind(to: didTextLongPressed)
                .disposed(by: disposeBag)
            
            otherView.chatImageView.rx
                .tapGesture()
                .when(.recognized)
                .map { _ in otherView.chatImageView.image }
                .bind(to: didImageTapped)
                .disposed(by: disposeBag)
            
            otherView.didInviteCardButtonTapped
                .bind(to: didInviteCardButtonTapped)
                .disposed(by: disposeBag)
            
            otherView.didSettlementCardButtonTapped
                .bind(to: didSettlementCardButtonTapped)
                .disposed(by: disposeBag)
        }
        
        chatCellView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            
            if isFirstChatOfDay {
                make.top.equalTo(dateView.snp.bottom).offset(16)
            } else {
                make.top.equalToSuperview()
            }
            
            make.bottom.equalToSuperview().inset(16).priority(.high)
        }
    }
    
    private func updateTableView() {
        guard let tableView = self.superview as? UITableView else {
            return
        }
        
        UIView.performWithoutAnimation {
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
}
