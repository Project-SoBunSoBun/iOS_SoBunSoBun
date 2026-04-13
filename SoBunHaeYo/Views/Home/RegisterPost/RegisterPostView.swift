//
//  RegisterPostView.swift
//  SoBunHaeYo
//
//  Created by 김태은 on 12/9/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxGesture

class RegisterPostView: BaseViewController {
    typealias Reactor = RegisterPostReactor
    private let reactor = RegisterPostReactor()
    
    private let disposeBag = DisposeBag()
    
    private let memberMinValue: Int = 2
    private let memberMaxValue: Int = 10
    
    // MARK: - 디자인 요소
    private func titleAttributes() -> [NSAttributedString.Key: Any] {
        var attributes: [NSAttributedString.Key: Any] = title16.attributes()
        attributes[.foregroundColor] = UIColor.neutral900
        
        return attributes
    }
    
    private lazy var topNavigationBar: TopNavigationBar = {
        let tnb = TopNavigationBar()
        tnb.parentViewController = self
        tnb.title = String(localized: "RegisterPostTitle", table: "Home")
        
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
        let attributedText = NSAttributedString(string: String(localized: "RegisterPostInfo", table: "Home"), attributes: body12.attributes())
        lb.attributedText = attributedText
        lb.textColor = .neutral300
        
        return lb
    }()
    
    private lazy var groupTitleLabel: UILabel = {
        let lb = UILabel()
        lb.attributedText = NSAttributedString(string: String(localized: "GroupTitle", table: "Home"), attributes: titleAttributes())
        
        return lb
    }()
    
    private let groupTitleTextField: TextFieldUnderline = {
        let tfu = TextFieldUnderline(maxLength: 40)
        tfu.placeholder = String(localized: "InsertTitle", table: "Home")
        
        return tfu
    }()
    
    private lazy var keywordTitleLabel: UILabel = {
        let lb = UILabel()
        lb.attributedText = NSAttributedString(string: String(localized: "ItemKeywords", table: "Home"), attributes: titleAttributes())
        
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
    
    private lazy var minimumTitleLabel: UILabel = {
        let lb = UILabel()
        
        var suffixAttributes = titleAttributes()
        suffixAttributes[.foregroundColor] = UIColor.neutral400
        
        let mainText = String(localized: "MinimumMembers", table: "Home")
        let suffix = " " + String(format: String(localized: "MinimumMembersSuffix", table: "Home"), memberMinValue)
        
        let fullText = NSMutableAttributedString(string: mainText, attributes: titleAttributes())
        fullText.append(NSAttributedString(string: suffix, attributes: suffixAttributes))
        
        lb.attributedText = fullText
        
        return lb
    }()
    
    private lazy var minimumTextField: TextFieldMember = {
        let tfm = TextFieldMember(
            minValue: memberMinValue,
            maxValue: memberMaxValue,
            maxLength: 2
        )
        
        return tfm
    }()
    
    private let maximumContainerView: UIStackView = fieldContainerView()
    
    private lazy var maximumTitleLabel: UILabel = {
        let lb = UILabel()
        
        var suffixAttributes = titleAttributes()
        suffixAttributes[.foregroundColor] = UIColor.neutral400
        
        let mainText = String(localized: "MaximumMembers", table: "Home")
        let suffix = " " + String(format: String(localized: "MaximumMembersSuffix", table: "Home"), memberMaxValue)
        
        let fullText = NSMutableAttributedString(string: mainText, attributes: titleAttributes())
        fullText.append(NSAttributedString(string: suffix, attributes: suffixAttributes))
        
        lb.attributedText = fullText
        
        return lb
    }()
    
    private lazy var maximumTextField: TextFieldMember = {
        let tfm = TextFieldMember(
            minValue: memberMinValue,
            maxValue: memberMaxValue,
            maxLength: 2
        )
        
        return tfm
    }()
    
    private lazy var locationTitleLabel: UILabel = {
        let lb = UILabel()
        lb.attributedText = NSAttributedString(string: String(localized: "MeetingLocation", table: "Home"), attributes: titleAttributes())
        
        return lb
    }()
    
    private let locationTextField: TextFieldUnderline = {
        let tfu = TextFieldUnderline(maxLength: 40)
        tfu.placeholder = String(localized: "InsertLocation", table: "Home")
        
        return tfu
    }()
    
    private let dateTimeStackView: UIStackView = fieldsStackView()
    
    private let dateContainerView: UIStackView = fieldContainerView()
    
    private lazy var dateTitleLabel: UILabel = {
        let lb = UILabel()
        lb.attributedText = NSAttributedString(string: String(localized: "Date", table: "Home"), attributes: titleAttributes())
        
        return lb
    }()
    
    private let dateTextField: TextFieldPicker = {
        let tfp = TextFieldPicker(icon: .blackCalendar)
        tfp.placeholder = String(localized: "DatePlaceholder", table: "Home")
        
        return tfp
    }()
    
    private let timeContainerView: UIStackView = fieldContainerView()
    
    private lazy var timeTitleLabel: UILabel = {
        let lb = UILabel()
        lb.attributedText = NSAttributedString(string: String(localized: "Time", table: "Home"), attributes: titleAttributes())
        
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
        
        lb.attributedText = NSAttributedString(string: String(localized: "RegisterPostDeadlineInfoMessage", table: "Home"), attributes: attributes)
        
        return lb
    }()
    
    private lazy var plannedItemsTitleLabel: UILabel = {
        let lb = UILabel()
        lb.attributedText = NSAttributedString(string: String(localized: "PlannedItems", table: "Home"), attributes: titleAttributes())
        
        return lb
    }()
    
    private let plannedItemsTextView: AutoHeightTextView = {
        let ahtv = AutoHeightTextView(minHeight: 112, maxLength: 120, fontStyle: body16)
        ahtv.placeholder = String(localized: "InsertContent", table: "Common")
        ahtv.textContainerInset = .init(top: 16, left: 16, bottom: 16, right: 16)
        ahtv.showCharactersCount = true
        ahtv.layer.cornerRadius = 16
        ahtv.layer.borderWidth = 1
        ahtv.layer.borderColor = UIColor.primary100.cgColor
        ahtv.frame = CGRectInset(ahtv.frame, -ahtv.layer.borderWidth, -ahtv.layer.borderWidth)
        ahtv.isScrollEnabled = false
        
        return ahtv
    }()
    
    private lazy var notesTitleLabel: UILabel = {
        let lb = UILabel()
        lb.attributedText = NSAttributedString(string: String(localized: "Notes", table: "Home"), attributes: titleAttributes())
        
        return lb
    }()
    
    private let notesTextView: AutoHeightTextView = {
        let ahtv = AutoHeightTextView(minHeight: 240, maxLength: 250, fontStyle: body16)
        ahtv.placeholder = String(localized: "InsertContent", table: "Common")
        ahtv.textContainerInset = .init(top: 16, left: 16, bottom: 16, right: 16)
        ahtv.showCharactersCount = true
        ahtv.layer.cornerRadius = 16
        ahtv.layer.borderWidth = 1
        ahtv.layer.borderColor = UIColor.primary100.cgColor
        ahtv.frame = CGRectInset(ahtv.frame, -ahtv.layer.borderWidth, -ahtv.layer.borderWidth)
        ahtv.isScrollEnabled = false
        
        return ahtv
    }()
    
    private let registerButton = Button(title: String(localized: "Register", table: "Common"))
    
    private lazy var loadingView: LoadingView = {
        let view = LoadingView()
        view.isHidden = true
        
        return view
    }()
    
    // MARK: - 생명주기
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        bind(reactor: reactor)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    // MARK: - 레이아웃 설정
    private func configureUI() {
        [topNavigationBar, scrollView, loadingView].forEach {
            view.addSubview($0)
        }
        
        topNavigationBar.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(4)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        scrollView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(topNavigationBar.snp.bottom)
            make.bottom.equalTo(view.keyboardLayoutGuide.snp.top) // 키보드 비활성화 시에는 safeAreaLayoutGuide bottom에 위치
        }
        
        loadingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        scrollView.addSubview(contentView)
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        [infoLabel, groupTitleLabel, groupTitleTextField, keywordTitleLabel, categoriesScrollView, membersStackView, locationTitleLabel, locationTextField, dateTimeStackView, deadlineInfoLabel, plannedItemsTitleLabel, plannedItemsTextView, notesTitleLabel, notesTextView, registerButton].forEach {
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
        
        locationTitleLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(membersStackView.snp.bottom).offset(32)
        }
        
        locationTextField.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(locationTitleLabel.snp.bottom).offset(8)
        }
        
        dateTimeStackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(locationTextField.snp.bottom).offset(32)
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
    private func bind(reactor: Reactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    private func bindAction(reactor: Reactor) {
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
        
        locationTextField.rx.text.orEmpty
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
    
    private func bindState(reactor: Reactor) {
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
            .map { [weak self] time24 -> String in
                guard let self = self,
                      let components = self.time24ToDisplayComponents(time24) else {
                    return time24
                }
                
                return "\(components.period) \(components.hour):\(components.minute)"
            }
            .bind(to: timeTextField.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isRegisterButtonEnable }
            .distinctUntilChanged()
            .bind(to: registerButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        reactor.state.map { !$0.isLoading }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(to: loadingView.rx.isHidden)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$errorMessage)
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] message in
                guard let self = self else { return }
                
                self.showErrorAlert(message: message)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isSuccess)
            .compactMap { $0 }
            .withLatestFrom(reactor.state.map {$0.postId})
            .subscribe(onNext: { [weak self] postId in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    if let postId {
                        self.navigationController?.pushViewController(PostDetailView(postId: postId, isNew: true), animated: true)
                    } else {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    // 카테고리 설정
    private func updateCategoriesStackView(_ selectedCategories: [String]) {
        categoriesStackView.subviews.forEach {
            categoriesStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        
        categoriesStackView.addArrangedSubview(addCategoryButton)
        
        if !selectedCategories.isEmpty {
            selectedCategories.forEach {
                let view = CategorySelected()
                view.text = NSLocalizedString("Category\($0)", tableName: "Category", comment: "")
                
                categoriesStackView.addArrangedSubview(view)
            }
        }
    }
    
    private func showSelectCategoriesBottomSheet() {
        let sheetView = SelectCategoriesView(selectedCategories: reactor.currentState.selectedCategories, safeAreaBottom: view.safeAreaInsets.bottom, allowsEmpty: false)
        
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
        let sheetView = CalendarPickerView(
            selectedDate: reactor.currentState.selectedDate,
            safeAreaBottom: view.safeAreaInsets.bottom
        )
        
        sheetView.view.layoutIfNeeded()
        
        let contentViewHeight = sheetView.contentView.frame.height
        
        // iOS 26이상 sheet detents 이슈로 인해 customize할 방법이 없어 직접 제작한 BottomSheetView를 사용하였습니다.
        let bottomSheet = BottomSheetView(
            contentViewController: sheetView,
            height: contentViewHeight,
            cornerRadius: 24
        )
        
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
    
    // 24시간 형식 문자열("HH:mm")을 기기 언어 기준 12시간 표시 컴포넌트로 변환
    private func time24ToDisplayComponents(_ time24: String) -> (hour: String, minute: String, period: String)? {
        let parts = time24.components(separatedBy: ":")
        
        guard parts.count == 2,
              let hour24 = Int(parts[0]),
              let minute = Int(parts[1]) else {
            return nil
        }
        
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        let amSymbol = formatter.amSymbol ?? "AM"
        let pmSymbol = formatter.pmSymbol ?? "PM"
        
        let isAM = hour24 < 12
        let hour12 = hour24 == 0 ? 12 : (hour24 > 12 ? hour24 - 12 : hour24)
        
        return (String(hour12), String(format: "%02d", minute), isAM ? amSymbol : pmSymbol)
    }
    
    // 시간 설정
    private func showTimePickerBottomSheet() {
        let components = reactor.currentState.selectedTime.flatMap { time24ToDisplayComponents($0) }
        
        let sheetView = TimePickerView(
            title: String(localized: "RegisterPostTimePickerTitle", table: "Home"),
            selectedHour: components?.hour,
            selectedMinute: components?.minute,
            selectedPeriod: components?.period,
            safeAreaBottom: view.safeAreaInsets.bottom
        )
        
        sheetView.view.layoutIfNeeded()
        
        let contentViewHeight = sheetView.contentView.frame.height
        
        // iOS 26이상 sheet detents 이슈로 인해 customize할 방법이 없어 직접 제작한 BottomSheetView를 사용하였습니다.
        let bottomSheet = BottomSheetView(
            contentViewController: sheetView,
            height: contentViewHeight,
            cornerRadius: 24
        )
        
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
