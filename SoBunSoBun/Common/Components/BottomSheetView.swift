//
//  BottomSheetView.swift
//  SoBunSoBun
//
//  Created by 김태은 on 11/18/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxGesture

class BottomSheetView: UIViewController {
    private let disposeBag = DisposeBag()
    
    let didDismiss = PublishRelay<Void>()
    let willDismiss = PublishRelay<Void>()
    
    private let contentViewController: UIViewController
    private let sheetHeight: CGFloat
    private let cornerRadius: CGFloat
    private let dismissible: Bool
    
    private var containerViewHeightConstraint: Constraint?
    private var containerViewBottomConstraint: Constraint?
    
    /// height는 1 미만은 비율, 이상은 고정값으로 간주됩니다.
    init(
        contentViewController: UIViewController,
        height: CGFloat,
        cornerRadius: CGFloat,
        dismissible: Bool = true
    ) {
        self.contentViewController = contentViewController
        self.cornerRadius = cornerRadius
        self.dismissible = dismissible
        
        if height < 1.0 {
            // 비율
            let ratio = min(max(height, 0.0), 1.0)
            self.sheetHeight = UIScreen.main.bounds.height * ratio
        } else {
            // 고정 높이
            let maxHeight = UIScreen.main.bounds.height * 0.95
            self.sheetHeight = min(height, maxHeight)
        }
        
        super.init(nibName: nil, bundle: nil)
        
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 디자인 요소
    private let dimmedView: UIView = {
        let view = UIView()
        view.backgroundColor = .alertBackgroundBlack
        view.alpha = 0
        
        return view
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundWhite
        
        return view
    }()
    
    private let handleBar: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        
        return view
    }()
    
    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        bind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        animatePresent()
    }
    
    // MARK: - 레이아웃 설정
    private func configureUI() {
        view.backgroundColor = .clear
        
        view.addSubview(dimmedView)
        dimmedView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        view.addSubview(containerView)
        containerView.layer.cornerRadius = cornerRadius
        containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        containerView.clipsToBounds = true
        
        containerView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            containerViewHeightConstraint = make.height.equalTo(sheetHeight).constraint
            containerViewBottomConstraint = make.top.equalTo(view.snp.bottom).constraint
        }
        
        addChild(contentViewController)
        containerView.addSubview(contentViewController.view)
        
        contentViewController.view.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.bottom.equalToSuperview()
        }
        
        containerView.addSubview(handleBar)
        handleBar.snp.makeConstraints { make in
            make.horizontalEdges.top.equalToSuperview()
            make.height.equalTo(44) // Apple 터치 권장 높이
        }
    }
}

extension BottomSheetView{
    private func bind() {
        guard dismissible else { return }
        
        dimmedView.rx
            .tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                handleDismiss()
            })
            .disposed(by: disposeBag)
        
        // Pan Gesture
        handleBar.rx
            .panGesture()
            .skip(1) // 첫 번째 이벤트 스킵
            .subscribe(onNext: { [weak self] gesture in
                guard let self = self else { return }
                
                handlePanGesture(gesture)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - 제스쳐
    private func findScrollView(in view: UIView) -> UIScrollView? {
        for subview in view.subviews {
            if let scrollView = subview as? UIScrollView {
                return scrollView
            }
        }
        
        return nil
    }
    
    private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)
        
        switch gesture.state {
        case .changed:
            if translation.y > 0 {
                // 뷰 내에 ScrollView 구성 체크
                if let scrollView = findScrollView(in: contentViewController.view) {
                    // ScrollView가 최상단이 아니면 바텀시트 제스처 무시
                    guard scrollView.contentOffset.y <= 0 else { return }
                }
                
                containerViewBottomConstraint?.update(offset: -containerView.frame.height + translation.y)
            }
            
        case .ended:
            let shouldDismiss = velocity.y > 1500 || translation.y > containerView.frame.height * 0.3
            
            if shouldDismiss {
                handleDismiss()
            } else {
                // 원래 위치로 복귀
                containerViewBottomConstraint?.update(offset: -containerView.frame.height)
                UIView.animate(
                    withDuration: 0.3,
                    delay: 0,
                    usingSpringWithDamping: 0.85,
                    initialSpringVelocity: 0.5,
                    options: .curveEaseOut
                ) {
                    self.view.layoutIfNeeded()
                }
            }
            
        default:
            break
        }
    }
    
    // MARK: - 애니메이션
    private func animatePresent() {
        containerViewBottomConstraint?.update(offset: -containerView.frame.height)
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 0.85,
            initialSpringVelocity: 0.5,
            options: .curveEaseOut
        ) {
            self.dimmedView.alpha = 1
            self.view.layoutIfNeeded()
        }
    }
    
    func handleDismiss() {
        willDismiss.accept(())
        animateDismiss()
    }
    
    func animateDismiss(completion: (() -> Void)? = nil) {
        containerViewBottomConstraint?.update(offset: 0)
        
        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            options: .curveEaseIn
        ) {
            self.dimmedView.alpha = 0
            self.view.layoutIfNeeded()
        } completion: { [weak self] _ in
            guard let self = self else { return }
            
            self.didDismiss.accept(())
            self.dismiss(animated: false, completion: completion)
        }
    }
    
}
