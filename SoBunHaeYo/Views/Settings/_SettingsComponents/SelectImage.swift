//
//  SelectedImage.swift
//  SoBunHaeYo
//
//  Created by 허성필 on 2/19/26.
//

import UIKit
import SnapKit

class SelectImage: UIView {
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        configureUI()
        updateImageCountLabel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 디자인 요소
    // 카메라 아이콘
    private let cameraIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = .blackCamera
        iv.contentMode = .scaleAspectFit
        
        return iv
    }()
    
    // 사진 갯수 라벨
    private let seletedImageCountLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 1
        
        return lb
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
        
        [cameraIcon, seletedImageCountLabel].forEach {
            self.addSubview($0)
        }
        
        cameraIcon.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(12)
            make.size.equalTo(36)
        }
        
        seletedImageCountLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(cameraIcon.snp.bottom).offset(2)
            make.bottom.equalToSuperview().inset(12)
        }
    }
    
    // 선택된 사진 갯수를 업데이트하는 함수
    func updateImageCountLabel(current: Int = 0, total: Int = 2) {
        let rawString = String(localized: "SelectedImageCount", table: "Settings")
        let formattedString = String.localizedStringWithFormat(rawString, current, total)
        
        var attributes = body12.attributes(alignment: .center)
        attributes[.foregroundColor] = UIColor.neutral900
        
        seletedImageCountLabel.attributedText = NSAttributedString(
            string: formattedString,
            attributes: attributes
        )
    }
}
