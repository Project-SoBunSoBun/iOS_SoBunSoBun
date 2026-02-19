//
//  SelectedImageView.swift
//  SoBunSoBun
//
//  Created by 허성필 on 2/20/26.
//

import UIKit
import SnapKit

class SelectedImageView: UIView {
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 디자인 요소
    // 이미지 뷰
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        
        return iv
    }()
    
    // x 버튼
    private let deleteButton: UIImageView = {
        let iv = UIImageView()
        iv.image = .xCircle.resize(.init(width: 28, height: 28)) // 피그마상 26.67
        iv.contentMode = .scaleAspectFit
        
        return iv
    }()
    
    // MARK: - 레이아웃 구성
    private func configureUI() {
        self.backgroundColor = .clear
        
        // 모서리
        self.layer.cornerRadius = 4
        self.clipsToBounds = true
        
        // 테두리
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.neutral200.cgColor
        self.frame = CGRectInset(self.frame, -self.layer.borderWidth, -self.layer.borderWidth)
        
        [imageView, deleteButton].forEach {
            self.addSubview($0)
        }
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        deleteButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
        }
    }
    
    func updateImage(image: UIImage) {
        imageView.image = image
    }
}
