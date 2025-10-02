//
//  Nickname.swift
//  SoBunSoBun
//
//  Created by 허성필 on 9/26/25.
//

import UIKit
import ReactorKit
import RxSwift

class Nickname: UIView {
    typealias Reactor = NicknameReactor
    private let reactor = NicknameReactor()
    private let disposeBag = DisposeBag()
    
    // 외부 View에서 사용 할 닉네임 중복
    var isNicknameValid: Observable<Bool> {
        return reactor.state
            .map { state -> Bool in
                guard let inputStatus = state.inputStatus,
                      let isAvailable = state.nickNameAvailable else {
                    return false
                }
                return inputStatus && isAvailable
            }
            .distinctUntilChanged()
    }
    
    // TODO: 색상 변경 예정
    let blueColor = UIColor(red: 0.251, green: 0.325, blue: 1, alpha: 1)
    let redColor = UIColor(red: 0.942, green: 0, blue: 0, alpha: 1)
    let grayColor = UIColor(red: 0.692, green: 0.692, blue: 0.692, alpha: 1)
    
    private let title: UILabel = {
        let title = UILabel()
        let attributedText = NSAttributedString(
            string: String(localized: "Nickname"), // 다국어 지원 구문
            attributes: body14.attributes
        )
        title.attributedText = attributedText
        title.textColor = .black0
        
        return title
    }()
    
    let textField: UITextField = {
        let textField = UITextField()
        textField.layer.cornerRadius = 14
        textField.layer.borderWidth = 1
        textField.backgroundColor = .backgroundWhite
        textField.textColor = .black0
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.font = body16.font
        textField.attributedPlaceholder = NSAttributedString(
            string: "닉네임을 입력해주세요",
            attributes: [
                // TODO: 색상 변경 예정
                .foregroundColor: UIColor(red: 0.692, green: 0.692, blue: 0.692, alpha: 1)
            ]
        )
        
        return textField
    }()
    
    private let button: UIButton = {
        let button = UIButton()
        button.setTitle(String(localized: "DuplicationCheck"), for: .normal)
        button.titleLabel?.font = title14.font
        button.titleLabel?.textColor = .backgroundWhite
        // TODO: 색상 코드 변경 필요
        button.layer.backgroundColor = UIColor(red: 0.543, green: 0.543, blue: 0.543, alpha: 1).cgColor
        button.layer.cornerRadius = 14
        
        return button
    }()
    
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 8
        sv.alignment = .leading
        
        return sv
    }()
    
    private func infoMessageSV(isAvailable: Bool?, infoMessage: String) -> UIStackView {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 0
        sv.alignment = .center
        
        let iv = UIImageView()
        let lb = UILabel()
        
        [iv, lb].forEach {
            sv.addArrangedSubview($0)
        }
        
        iv.snp.makeConstraints { make in
            make.size.equalTo(24)
        }
        
        let attributedText = NSAttributedString(
            string: infoMessage, // 다국어 지원 구문
            attributes: body14.attributes
        )
        lb.attributedText = attributedText
        
        if let isAvailable = isAvailable {
            // isAvailable이 true일 때
            if isAvailable {
                iv.image = .check
                iv.tintColor = blueColor
                lb.textColor = blueColor
            } else { // isAvailable이 false일 때
                iv.image = .X
                iv.tintColor = redColor
                lb.textColor = redColor
            }
        } else { // Nil일 때
            iv.image = .check
            iv.tintColor = grayColor
            lb.textColor = grayColor
        }
        
        return sv
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        configure()
        bind(reactor: reactor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 레이아웃 설정
    private func configure() {
        [title, textField, button, stackView].forEach {
            self.addSubview($0)
        }
        
        textField.layer.borderColor = grayColor.cgColor
        
        title.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
        }
        
        button.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.top.equalTo(title.snp.bottom).offset(8)
            make.width.equalTo(74)
            make.height.equalTo(52)
        }
        
        textField.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalTo(button.snp.leading).offset(-8)
            make.top.equalTo(button)
            make.height.equalTo(button)
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom).offset(8)
            make.horizontalEdges.bottom.equalToSuperview()
        }
    }
}

// Reactor 연결
extension Nickname {
    // reactor와 view 연결
    func bind(reactor: NicknameReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    func bindAction(reactor: NicknameReactor) {
        button.rx.tap
            .map { _ in Reactor.Action.isDuplicationCheckButtonTapped(input: self.textField.text)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    func bindState(reactor: NicknameReactor) {
        reactor.state
            .asDriver(onErrorDriveWith: .empty())
            .drive(with: self, onNext: { [weak self] _, state in
                guard let self = self else { return }
                
                self.stackView.arrangedSubviews.forEach { view in
                    self.stackView.removeArrangedSubview(view)
                    view.removeFromSuperview()
                }
                
                let inputStatus = state.inputStatus
                stackView.addArrangedSubview(infoMessageSV(isAvailable: inputStatus, infoMessage: String(localized: "DenyNicknameInput")))
                
                if let inputStatus = inputStatus {
                    textField.layer.borderColor = inputStatus ? blueColor.cgColor : redColor.cgColor
                }
                
                guard let isAvailable = state.nickNameAvailable, let infoMessage = state.infoMessage else { return }
                
                self.stackView.addArrangedSubview(self.infoMessageSV(isAvailable: isAvailable, infoMessage: infoMessage))
                textField.layer.borderColor = isAvailable ? blueColor.cgColor : redColor.cgColor
            })
            .disposed(by: disposeBag)
    }
}
