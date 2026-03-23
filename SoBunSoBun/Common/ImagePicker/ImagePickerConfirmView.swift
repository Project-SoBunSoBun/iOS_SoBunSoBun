//
//  ImagePickerConfirmView.swift
//  SoBunSoBun
//
//  Created by 김태은 on 3/23/26.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class ImagePickerConfirmView: UIViewController {
    let onConfirm = PublishSubject<Void>()
    
    private let image: UIImage
    
    init(image: UIImage) {
        self.image = image
        
        super.init(nibName: nil, bundle: nil)
        
        modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let disposeBag = DisposeBag()
    
    // MARK: - 디자인 요소
    // 상단 네비게이션 바
    private lazy var topNavigationBar: TopNavigationBar = {
        let tnb = TopNavigationBar()
        tnb.onBackButtonTapped = { [weak self] in
            guard let self = self else { return }
            
            dismiss(animated: true)
        }
        tnb.buttons = [confirmButton]
        
        return tnb
    }()
    
    private lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.image = image
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        
        return iv
    }()
    
    private let confirmButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.contentInsets = .init(top: 13.5, leading: 12, bottom: 13.5, trailing: 12)
        
        var attributes = body14.attributes(alignment: .center)
        attributes[.foregroundColor] = UIColor.neutral900
        config.attributedTitle = AttributedString(NSAttributedString(string: String(localized: "Confirm", table: "Common"), attributes: attributes))
        
        return UIButton(configuration: config)
    }()
    
    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        bind()
    }
    
    // MARK: - 레이아웃 설정
    private func configureUI() {
        view.backgroundColor = .neutral900
        
        [topNavigationBar, imageView].forEach {
            view.addSubview($0)
        }
        
        topNavigationBar.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        imageView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(topNavigationBar.snp.bottom)
            make.bottom.equalToSuperview()
        }
    }
}

extension ImagePickerConfirmView {
    private func bind() {
        confirmButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                
                dismiss(animated: true) {
                    self.onConfirm.onNext(())
                }
            })
            .disposed(by: disposeBag)
    }
}
