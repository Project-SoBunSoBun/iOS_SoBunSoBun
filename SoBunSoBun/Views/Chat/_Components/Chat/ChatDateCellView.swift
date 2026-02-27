//
//  ChatDateCellView.swift
//  SoBunSoBun
//
//  Created by 김태은 on 2/15/26.
//

import UIKit
import SnapKit

class ChatDateCellView: UIView {
    init(frame: CGRect = .zero, date: String) {
        super.init(frame: frame)
        
        configureUI(date: date)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let dateContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .neutral900.withAlphaComponent(0.2)
        view.layer.cornerRadius = 13
        view.clipsToBounds = true
        
        return view
    }()
    
    private let dateAttributes: [NSAttributedString.Key: Any] = {
        var attributes = body12.attributes(alignment: .center)
        attributes[.foregroundColor] = UIColor.backgroundWhite
        
        return attributes
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        
        return label
    }()
    
    private func configureUI(date: String) {
        addSubview(dateContainerView)
        
        dateContainerView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.verticalEdges.equalToSuperview().inset(8)
        }
        
        dateContainerView.addSubview(dateLabel)
        
        let dateString: String
        
        if let date = ISO8601ToDate(date) {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale.current
            dateFormatter.dateStyle = .full
            dateFormatter.timeStyle = .none
            
            dateString = dateFormatter.string(from: date)
        } else {
            dateString = String(localized: "Unknown", table: "Common")
        }
        
        dateLabel.attributedText = NSAttributedString(string: dateString, attributes: dateAttributes)
        
        dateLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(4)
        }
    }
}
