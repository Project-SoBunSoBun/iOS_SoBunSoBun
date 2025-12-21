//
//  RegisterPostView.swift
//  SoBunSoBun
//
//  Created by 김태은 on 12/9/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxGesture

class RegisterPostView: UIViewController {
    typealias Reactor = RegisterPostReactor
    private let reactor = RegisterPostReactor()
    
    private let disposeBag = DisposeBag()
    
    // MARK: - 디자인 요소
    private static func titleLabel() -> UILabel {
        let lb = UILabel()
        lb.font = title16.font
        lb.textColor = .neutral900
        
        return lb
    }
    
    private lazy var topNavigationBar: TopNavigationBar = {
        let tnb = TopNavigationBar()
        tnb.parentViewController = self
        tnb.title = String(localized: "RegisterPostTitle")
        
        return tnb
    }()
    
    private let scrollView: UIScrollView = UIScrollView()
    
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundWhite
        
        return view
    }()
    
    private let infoLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 0
        let attributedText = NSAttributedString(string: String(localized: "RegisterPostInfo"), attributes: body12.attributes())
        lb.attributedText = attributedText
        lb.textColor = .neutral300
        
        return lb
    }()
    
    private let groupTitleLabel: UILabel = {
        let lb = titleLabel()
        lb.text = String(localized: "GroupTitle")
        
        return lb
    }()
    
    private let groupTitleTextField: TextFieldUnderline = {
        let tfu = TextFieldUnderline(maxLength: 120)
        tfu.setPlaceholder(String(localized: "InsertTitle"))
        
        return tfu
    }()
    
    private let keywordTitleLabel: UILabel = {
        let lb = titleLabel()
        lb.text = String(localized: "ItemKeywords")
        
        return lb
    }()
    
    private let categoriesScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsHorizontalScrollIndicator = false
        
        return sv
    }()
    
    private let categoriesStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 8
        
        return sv
    }()
    
    private let addCategoryButton: UIView = {
        let size: CGFloat = 35
        let view = UIView()
        view.backgroundColor = .primary100
        view.layer.cornerRadius = size / 2
        view.clipsToBounds = true
        
        let iv = UIImageView()
        iv.image = .lightbluePlus
        iv.contentMode = .scaleAspectFit
        
        view.addSubview(iv)
        
        view.snp.makeConstraints { make in
            make.size.equalTo(size)
        }
        
        iv.snp.makeConstraints { make in
            make.size.equalTo(24)
            make.center.equalToSuperview()
        }
        
        return view
    }()
    
    private static func fieldsStackView() -> UIStackView {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 8
        sv.distribution = .fillEqually
        
        return sv
    }
    
    private static func fieldContainerView() -> UIStackView {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 16
        sv.alignment = .leading
        
        return sv
    }
    
    private let membersStackView: UIStackView = fieldsStackView()
    
    private let minimumContainerView: UIStackView = fieldContainerView()
    
    private let minimumTitleLabel: UILabel = {
        let lb = titleLabel()
        lb.text = String(localized: "MinimumMembers")
        
        return lb
    }()
    
    private let minimumTextField: TextFieldMember = {
        let tfm = TextFieldMember(minValue: 2, maxValue: 10)
        tfm.setPlaceholder(String(tfm.minValue))
        
        return tfm
    }()
    
    private let maximumContainerView: UIStackView = fieldContainerView()
    
    private let maximumTitleLabel: UILabel = {
        let lb = titleLabel()
        lb.text = String(localized: "MaximumMembers")
        
        return lb
    }()
    
    private let maximumTextField: TextFieldMember = {
        let tfm = TextFieldMember(minValue: 2, maxValue: 10)
        tfm.setPlaceholder(String(tfm.maxValue))
        
        return tfm
    }()
    
    private let marketTitleLabel: UILabel = {
        let lb = titleLabel()
        lb.text = String(localized: "MarketLocation")
        
        return lb
    }()
    
    private let marketTextField: TextFieldUnderline = {
        let tfu = TextFieldUnderline(maxLength: 120)
        tfu.setPlaceholder(String(localized: "InsertMarket"))
        
        return tfu
    }()
    
    private let dateTimeStackView: UIStackView = fieldsStackView()
    
    private let dateContainerView: UIStackView = fieldContainerView()
    
    private let dateTitleLabel: UILabel = {
        let lb = titleLabel()
        lb.text = String(localized: "Date")
        
        return lb
    }()
    
    private let dateTextField: TextFieldPicker = {
        let tfp = TextFieldPicker(icon: .blackCalendar)
        tfp.placeholder = String(localized: "DatePlaceholder")
        
        return tfp
    }()
    
    private let timeContainerView: UIStackView = fieldContainerView()
    
    private let timeTitleLabel: UILabel = {
        let lb = titleLabel()
        lb.text = String(localized: "Time")
        
        return lb
    }()
    
    private let timeTextField: TextFieldPicker = {
        let tfp = TextFieldPicker(icon: .blackClock)
        tfp.placeholder = "00 : 00"
        
        return tfp
    }()
    
    private let deadlineInfoLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 0
        
        var attributes: [NSAttributedString.Key: Any] = body12.attributes(alignment: .left)
        attributes[.foregroundColor] = UIColor.primary400
        
        lb.attributedText = NSAttributedString(string: String(localized: "RegisterPostDeadlineInfoMessage"), attributes: attributes)
        
        return lb
    }()
    
    private let plannedItemsTitleLabel: UILabel = {
        let lb = titleLabel()
        lb.text = String(localized: "PlannedItems")
        
        return lb
    }()
    
    private let plannedItemsTextView = AutoHeightTextView(minHeight: 112, maxLength: 100, placeholder: String(localized: "InsertContent"))
    
    private let notesTitleLabel: UILabel = {
        let lb = titleLabel()
        lb.text = String(localized: "Notes")
        
        return lb
    }()
    
    private let notesTextView = AutoHeightTextView(minHeight: 240, maxLength: 250, placeholder: String(localized: "InsertContent"))
    
    private let registerButton = Button(title: String(localized: "Register"))
    
    private let loadingView: LoadingView = {
        let view = LoadingView()
        view.isHidden = true
        
        return view
    }()
    
    private let successView: RegisterPostSuccessView = {
        let view = RegisterPostSuccessView()
        view.isHidden = true
        
        return view
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
        
        view.addSubview(topNavigationBar)
        
        topNavigationBar.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(4)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        view.addSubview(scrollView)
        
        scrollView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(topNavigationBar.snp.bottom)
            make.bottom.equalTo(view.keyboardLayoutGuide.snp.top) // 키보드 비활성화 시에는 safeAreaLayoutGuide bottom에 위치
        }
        
        view.addSubview(loadingView)
        
        loadingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        view.addSubview(successView)
        
        successView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        scrollView.addSubview(contentView)
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        [infoLabel, groupTitleLabel, groupTitleTextField, keywordTitleLabel, categoriesScrollView, membersStackView, marketTitleLabel, marketTextField, dateTimeStackView, deadlineInfoLabel, plannedItemsTitleLabel, plannedItemsTextView, notesTitleLabel, notesTextView, registerButton].forEach {
            contentView.addSubview($0)
        }
        
        infoLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(16)
        }
        
        groupTitleLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(infoLabel.snp.bottom).offset(32)
        }
        
        groupTitleTextField.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(groupTitleLabel.snp.bottom).offset(8)
        }
        
        keywordTitleLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(groupTitleTextField.snp.bottom).offset(32)
        }
        
        categoriesScrollView.addSubview(categoriesStackView)
        
        categoriesScrollView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(keywordTitleLabel.snp.bottom).offset(16)
            make.height.equalTo(51)
        }
        
        categoriesStackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.verticalEdges.equalToSuperview().inset(8)
        }
        
        categoriesStackView.addArrangedSubview(addCategoryButton)
        
        membersStackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(categoriesScrollView.snp.bottom).offset(32)
        }
        
        [minimumContainerView, maximumContainerView].forEach {
            membersStackView.addArrangedSubview($0)
        }
        
        [(minimumContainerView, minimumTitleLabel, minimumTextField),
         (maximumContainerView, maximumTitleLabel, maximumTextField)]
            .forEach { container, title, textField in
                [title, textField].forEach { container.addArrangedSubview($0) }
                textField.snp.makeConstraints { make in
                    make.horizontalEdges.equalToSuperview()
                }
            }
        
        marketTitleLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(membersStackView.snp.bottom).offset(32)
        }
        
        marketTextField.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(marketTitleLabel.snp.bottom).offset(8)
        }
        
        dateTimeStackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(marketTextField.snp.bottom).offset(32)
        }
        
        [dateContainerView, timeContainerView].forEach {
            dateTimeStackView.addArrangedSubview($0)
        }
        
        [(dateContainerView, dateTitleLabel, dateTextField),
         (timeContainerView, timeTitleLabel, timeTextField)]
            .forEach { container, title, textField in
                [title, textField].forEach { container.addArrangedSubview($0) }
                textField.snp.makeConstraints { make in
                    make.horizontalEdges.equalToSuperview()
                }
            }
        
        deadlineInfoLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(dateTimeStackView.snp.bottom).offset(8)
        }
        
        plannedItemsTitleLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(deadlineInfoLabel.snp.bottom).offset(32)
        }
        
        plannedItemsTextView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(plannedItemsTitleLabel.snp.bottom).offset(16)
        }
        
        notesTitleLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(plannedItemsTextView.snp.bottom).offset(32)
        }
        
        notesTextView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(notesTitleLabel.snp.bottom).offset(16)
        }
        
        registerButton.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(notesTextView.snp.bottom).offset(16)
            make.bottom.equalToSuperview()
        }
    }
}
 
extension RegisterPostView {
    // reactor와 view 연결
    private func bind(reactor: RegisterPostReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    private func bindAction(reactor: RegisterPostReactor) {
        groupTitleTextField.rx.text.orEmpty
            .map { Reactor.Action.titleTextChanged($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        addCategoryButton.rx
            .tapGesture()
            .when(.recognized)
            .map { _ in Reactor.Action.addCategoryTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        minimumTextField.rx.text.orEmpty
            .compactMap { Int($0) }
            .distinctUntilChanged()
            .map { Reactor.Action.minimumMembersTextChanged($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        maximumTextField.rx.text.orEmpty
            .compactMap { Int($0) }
            .distinctUntilChanged()
            .map { Reactor.Action.maximumMembersTextChanged($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        marketTextField.rx.text.orEmpty
            .map { Reactor.Action.locationTextChanged($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        dateTextField.rx
            .tapGesture()
            .when(.recognized)
            .map { _ in Reactor.Action.setDateTextFieldTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        timeTextField.rx
            .tapGesture()
            .when(.recognized)
            .map { _ in Reactor.Action.setTimeTextFieldTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        plannedItemsTextView.rx.text.orEmpty
            .map { Reactor.Action.plannedItemsTextChanged($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        notesTextView.rx.text.orEmpty
            .map { Reactor.Action.notesTextChanged($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        registerButton.rx.tap
            .map { Reactor.Action.registerButtonTapped }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(reactor: RegisterPostReactor) {
        reactor.pulse(\.$shouldShowBottomCategorySheet)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                showSelectCategoriesBottomSheet()
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.selectedCategories }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] selectedCategories in
                guard let self = self else { return }
                
                updateCategoriesStackView(selectedCategories)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$shouldShowBottomDateSheet)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                showCalenderPickerBottomSheet()
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.selectedDate }
            .distinctUntilChanged()
            .compactMap { $0 }
            .bind(to: dateTextField.rx.text)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$shouldShowBottomTimeSheet)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                showTimePickerBottomSheet()
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.selectedTime }
            .distinctUntilChanged()
            .compactMap { $0 }
            .bind(to: timeTextField.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isRegisterButtonEnable }
            .distinctUntilChanged()
            .bind(to: registerButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        reactor.state.map { !$0.isLoading }
            .distinctUntilChanged()
            .bind(to: loadingView.rx.isHidden)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.errorMessage }
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] message in
                guard let self = self else { return }
                
                showAlert(
                    title: String(localized: "Error"),
                    message: message,
                    confirmTitle: String(localized: "Confirm"),
                    confirmAction: {},
                    vc: self
                )
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isSuccess)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                successView.isHidden = false
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.navigationController?.popViewController(animated: true)
                }
            })
            .disposed(by: disposeBag)
    }
    
    // 카테고리 설정
    private func updateCategoriesStackView(_ selectedCategories: [String]) {
        categoriesStackView.subviews.forEach {
            $0.removeFromSuperview()
        }
        
        categoriesStackView.addArrangedSubview(addCategoryButton)
        
        if !selectedCategories.isEmpty {
            selectedCategories.forEach {
                let categoryString = NSLocalizedString("Category\($0)", comment: "Category \($0)")
                let category = CategorySelected()
                category.text = categoryString
                
                categoriesStackView.addArrangedSubview(category)
            }
        }
    }
    
    private func showSelectCategoriesBottomSheet() {
        let sheetView = SelectCategoriesView(selectedCategories: reactor.currentState.selectedCategories)
        
        sheetView.selectedCategoriesRelay
            .map { Reactor.Action.setSelectedCategories($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // iOS 26이상 sheet detents 이슈로 인해 customize할 방법이 없어 직접 제작한 BottomSheetView를 사용하였습니다.
        let bottomSheet = BottomSheetView(
            contentViewController: sheetView,
            height: 0.88,
            cornerRadius: 24)
        
        present(bottomSheet, animated: true)
    }
    
    // 날짜 설정
    private func showCalenderPickerBottomSheet() {
        let sheetView = CalendarPickerView(selectedDate: reactor.currentState.selectedDate)
        
        sheetView.view.layoutIfNeeded()
        
        let contentViewHeight = sheetView.contentView.frame.height
        
        // iOS 26이상 sheet detents 이슈로 인해 customize할 방법이 없어 직접 제작한 BottomSheetView를 사용하였습니다.
        let bottomSheet = BottomSheetView(
            contentViewController: sheetView,
            height: contentViewHeight,
            cornerRadius: 24)

        present(bottomSheet, animated: true)
        
        sheetView.selectedDateRelay
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] date in
                guard let self = self else { return }
                
                reactor.action.onNext(Reactor.Action.setDate(date))
                bottomSheet.handleDismiss()
            })
            .disposed(by: disposeBag)
    }
    
    // 시간 설정
    private func showTimePickerBottomSheet() {
        let timeString = reactor.currentState.selectedTime
        let separatedString = timeString?.components(separatedBy: " ")
        let periodString = separatedString?[0]
        let separatedTimeString = separatedString?[1].components(separatedBy: ":")
        let hourString = separatedTimeString?[0]
        let minuteString = separatedTimeString?[1]
        
        let sheetView = TimePickerView(
            title: String(localized: "RegisterPostTimePickerTitle"),
            selectedHour: hourString,
            selectedMinute: minuteString,
            selectedPeriod: periodString
        )
        
        sheetView.view.layoutIfNeeded()
        
        let contentViewHeight = sheetView.contentView.frame.height
        
        // iOS 26이상 sheet detents 이슈로 인해 customize할 방법이 없어 직접 제작한 BottomSheetView를 사용하였습니다.
        let bottomSheet = BottomSheetView(
            contentViewController: sheetView,
            height: contentViewHeight,
            cornerRadius: 24)

        present(bottomSheet, animated: true)
        
        sheetView.selectedTimeRelay
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] time in
                guard let self = self else { return }
                
                reactor.action.onNext(Reactor.Action.setTime(time))
                bottomSheet.handleDismiss()
            })
            .disposed(by: disposeBag)
    }
}

#if DEBUG
// 미리보기
import SwiftUI

struct RegisterPostViewController_Preview: PreviewProvider {
    static var previews: some SwiftUI.View {
        UIViewControllerPreview {
            RegisterPostView()
        }
    }
}
#endif
