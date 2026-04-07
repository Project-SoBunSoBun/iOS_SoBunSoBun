//
//  AnnouncementDetailView.swift
//  SoBunHaeYo
//
//  Created by 허성필 on 2/14/26.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit
import OSLog

class AnnouncementDetailView: UIViewController {
    init(model: AnnouncementContentModel, nibName nibNameOrNil: String? = nil
         , bundle nibBundleOrNil: Bundle? = nil) {
        reactor = AnnouncementDetailReactor(id: model.id)
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        titleView.configure(item: model)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    typealias Reactor = AnnouncementDetailReactor
    private let reactor: AnnouncementDetailReactor
    
    private let disposeBag = DisposeBag()
    
    // MARK: - 디자인 요소
    private lazy var topNavigationBar: TopNavigationBar = {
        let tnb = TopNavigationBar()
        tnb.parentViewController = self
        
        return tnb
    }()
    
    private let scrollView = UIScrollView()
    
    private let contentView = UIView()
    
    private let titleView = AnnouncementCellView()
    
    private let detailLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 0
        
        return lb
    }()

    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        bind(reactor: reactor)
    }
    
    // MARK: - 레이아웃 설정
    private func configureUI() {
        view.backgroundColor = .backgroundWhite
        
        [topNavigationBar, scrollView].forEach {
            view.addSubview($0)
        }
        
        topNavigationBar.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        scrollView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(topNavigationBar.snp.bottom)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        scrollView.addSubview(contentView)
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        [titleView, detailLabel].forEach {
            contentView.addSubview($0)
        }
        
        titleView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        detailLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(titleView.snp.bottom).offset(16)
            make.bottom.equalToSuperview().inset(48)
        }
    }
    
    private func setDetailLabel(content: String) {
        var attributes: [NSAttributedString.Key: Any] = body16.attributes(alignment: .left)
        attributes[.foregroundColor] = UIColor.neutral900
        
        detailLabel.attributedText = NSAttributedString(
            string: content,
            attributes: attributes
        )
    }
}

extension AnnouncementDetailView {
    // reactor와 view 연결
    private func bind(reactor: Reactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    private func bindAction(reactor: Reactor) {
        reactor.action.onNext(.viewDidLoad)
    }
    
    private func bindState(reactor: Reactor) {
        reactor.state.map { $0.noticeDetail }
            .compactMap { $0 }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] response in
                guard let self = self else { return }
                
                self.setDetailLabel(content: response.content)
            })
            .disposed(by: disposeBag)
    }
}
