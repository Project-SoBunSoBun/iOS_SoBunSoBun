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
                guard let isAvailable = state.nickNameAvailable else {
                    return false
                }
                return isAvailable
            }
            .distinctUntilChanged()
    }
    
    // TODO: 색상 변경 예정
    let redColor = UIColor(red: 0.942, green: 0, blue: 0, alpha: 1)
    
    // MARK: - 디자인 요소
    private let title: UILabel = {
        let title = UILabel()
        let attributedText = NSAttributedString(
            string: String(localized: "Nickname"),
            attributes: title16.attributes
        )
        title.attributedText = attributedText
        title.textColor = .neutral900
        
        return title
    }()
    
    let textField: UITextField = {
        let textField = UITextField()
        textField.layer.cornerRadius = 16
        textField.layer.borderWidth = 2
        textField.backgroundColor = .backgroundWhite
        textField.textColor = .neutral900
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = paddingView
        textField.rightView = paddingView
        textField.leftViewMode = .always
        textField.rightViewMode = .always
        textField.font = body16.font
        textField.attributedPlaceholder = NSAttributedString(
            string: String(localized: "InsertNickname"),
            attributes: [
                .foregroundColor: UIColor.neutral300
            ]
        )
        
        return textField
    }()
    
    private let button: UIButton = {
        let button = UIButton()
        button.contentVerticalAlignment = .center
        button.contentHorizontalAlignment = .center
        
        var config = UIButton.Configuration.filled()
        config.background.cornerRadius = 16
        config.background.backgroundColor = .primary400
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        button.configuration = config
        
        button.configurationUpdateHandler = { button in
            var updatedConfig = button.configuration
            
            // 상태별 텍스트 색상
            var titleAttributes = AttributeContainer()
            titleAttributes.font = title14.font
            titleAttributes.foregroundColor = UIColor.backgroundWhite.withAlphaComponent(1.0)
            
            // 상태별 배경색
            if button.isEnabled {
                updatedConfig?.background.backgroundColor = .primary400
            } else {
                updatedConfig?.background.backgroundColor = .neutral200
            }
            
            updatedConfig?.attributedTitle = AttributedString(
                String(localized: "DuplicationCheck"),
                attributes: titleAttributes
            )
            
            button.configuration = updatedConfig
        }
        
        return button
    }()
    
    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 0
        sv.alignment = .center
        
        return sv
    }()
    
    // 안내 메세지를 설정하는 함수
    private func makeInfoMessage(isAvailable: Bool?, infoMessage: String) {
        let iv = UIImageView()
        let lb = UILabel()
        
        [iv, lb].forEach {
            stackView.addArrangedSubview($0)
        }
        
        iv.snp.makeConstraints { make in
            make.size.equalTo(24)
        }
        
        let attributedText = NSAttributedString(
            string: infoMessage,
            attributes: body14.attributes
        )
        
        lb.attributedText = attributedText
        
        if let isAvailable = isAvailable {
            // isAvailable이 true일 때
            if isAvailable {
                iv.image = .check
                iv.tintColor = .primary400
                lb.textColor = .primary400
            } else { // isAvailable이 false일 때
                iv.image = .X
                // TODO: 색상 변경 필요 레드
                iv.tintColor = redColor
                lb.textColor = redColor
            }
        } else { // nil일 때
            iv.image = .check
            iv.tintColor = .neutral500
            lb.textColor = .neutral500
        }
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
        
        textField.layer.borderColor = UIColor.primary100.cgColor
        
        title.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
        }
        
        button.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.top.equalTo(title.snp.bottom).offset(8)
            make.width.equalTo(80)
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
        
        // textField 영역 외 부분을 누르면 키보드 내리기
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        // 다른 터치 이벤트를 방해하지 않도록 설정
        tapGesture.cancelsTouchesInView = false
        self.addGestureRecognizer(tapGesture)
    }
    
    // 키보드를 내리는 함수
    @objc private func dismissKeyboard() {
        self.endEditing(true)
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
        // textField의 text 변화를 감지
        textField.rx.text
            .map { Reactor.Action.textFieldChanged($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // textField를 클릭했을 때
        textField.rx.controlEvent(.editingDidBegin)
            .map { Reactor.Action.textFieldBeginEditing }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // 중복확인 버튼을 클릭했을 때
        button.rx.tap
            .map { _ in Reactor.Action.isDuplicationCheckButtonTapped(input: self.textField.text)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    func bindState(reactor: NicknameReactor) {
        // 버튼 비활성화
        reactor.state.map { $0.isButtonEnabled }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)
            .drive(with: self, onNext: { owner, isEnabled in
                owner.button.isEnabled = isEnabled
            })
            .disposed(by: disposeBag)
        
        // 중복확인 후 textField를 클릭하면 textField의 text 전체 지우기
        reactor.pulse(\.$shouldClearText)
            .filter { $0 == true }
            .asDriver(onErrorJustReturn: false)
            .drive(with: self, onNext: { owner, _ in
                owner.textField.text = ""
            })
            .disposed(by: disposeBag)
        
        // 안내 메세지
        reactor.state
            .asDriver(onErrorDriveWith: .empty())
            .drive(with: self, onNext: { [weak self] _, state in
                guard let self = self else { return }
                
                stackView.arrangedSubviews.forEach { view in
                    self.stackView.removeArrangedSubview(view)
                    view.removeFromSuperview()
                }
                
                guard let isAvailable = state.nickNameAvailable,
                      let infoMessage = state.infoMessage else { makeInfoMessage(isAvailable: nil, infoMessage: String(localized: "DenyNicknameInput"))
                    textField.layer.borderColor = UIColor.primary100.cgColor
                    textField.layer.borderWidth = 1
                    return
                }
                
                makeInfoMessage(isAvailable: isAvailable, infoMessage: infoMessage)
                
                textField.layer.borderColor = isAvailable ? UIColor.primary400.cgColor : UIColor.primary100.cgColor
                
                textField.layer.borderWidth = isAvailable ? 2 : 1
            })
            .disposed(by: disposeBag)
    }
}
