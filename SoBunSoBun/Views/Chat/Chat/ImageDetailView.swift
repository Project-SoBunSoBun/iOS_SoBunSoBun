//
//  ImageDetailView.swift
//  SoBunSoBun
//
//  Created by 김태은 on 3/1/26.
//

import UIKit
import SnapKit
import RxSwift
import RxGesture

class ImageDetailView: UIViewController {
    private let image: UIImage
    
    private let disposeBag = DisposeBag()
    
    init(image: UIImage, nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil) {
        self.image = image
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.delegate = self
        sv.minimumZoomScale = 0.5
        sv.maximumZoomScale = 3.0
        sv.showsVerticalScrollIndicator = false
        sv.showsHorizontalScrollIndicator = false
        sv.contentInsetAdjustmentBehavior = .never // safearea 범위 무시
        
        return sv
    }()
    
    private lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.image = image
        iv.contentMode = .scaleAspectFit
        iv.isUserInteractionEnabled = true
        
        return iv
    }()
    
    private lazy var topNavigationBar: TopNavigationBar = {
        let tnb = TopNavigationBar()
        tnb.parentViewController = self
        
        return tnb
    }()
    
    private let topSafeAreaView: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundWhite
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        bind()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        DispatchQueue.main.async {
            self.centerImageView()
        }
    }
    
    private func configureUI() {
        view.backgroundColor = .backgroundWhite
        
        [scrollView, topSafeAreaView, topNavigationBar].forEach {
            view.addSubview($0)
        }
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        scrollView.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.size.equalToSuperview()
        }
        
        topSafeAreaView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        topNavigationBar.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
    }
}

extension ImageDetailView {
    private func bind() {
        imageView.rx
            .tapGesture(configuration: { gesture, _ in
                gesture.numberOfTapsRequired = 2
            })
            .when(.recognized)
            .subscribe(onNext: { [weak self] gesture in
                guard let self else { return }
                
                if scrollView.zoomScale >= scrollView.maximumZoomScale {
                    scrollView.setZoomScale(1.0, animated: true)
                } else {
                    let location = gesture.location(in: imageView)
                    let zoomRect = doubleTapZoomScrollView(scale: scrollView.maximumZoomScale, center: location)
                    scrollView.zoom(to: zoomRect, animated: true)
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func doubleTapZoomScrollView(scale: CGFloat, center: CGPoint) -> CGRect {
        let size = CGSize(
            width: scrollView.bounds.width / scale,
            height: scrollView.bounds.height / scale
        )
        
        let origin = CGPoint(
            x: center.x - size.width / 2,
            y: center.y - size.height / 2
        )
        
        return CGRect(origin: origin, size: size)
    }
}

extension ImageDetailView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImageView()
    }
    
    private func centerImageView() {
        let scrollViewSize = scrollView.bounds.size
        let imageViewSize = imageView.frame.size
        
        let offsetX = max((scrollViewSize.width - imageViewSize.width) / 2, 0)
        let offsetY = max((scrollViewSize.height - imageViewSize.height) / 2, 0)
        
        scrollView.contentInset = UIEdgeInsets(
            top: offsetY,
            left: offsetX,
            bottom: offsetY,
            right: offsetX
        )
    }
}
