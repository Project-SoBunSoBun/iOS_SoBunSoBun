//
//  TimePickerView.swift
//  SoBunHaeYo
//
//  Created by 김태은 on 12/13/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class TimePickerView: UIViewController {
    typealias Reactor = TimePickerReactor
    private let reactor: TimePickerReactor
    
    let selectedTimeRelay = PublishRelay<String?>()
    
    private let disposeBag = DisposeBag()
    
    private let visibleItemCount: Int = 3
    private let itemHeight: CGFloat = 72
    
    private let hourPicker: CustomWheelPicker
    private let minutePicker: CustomWheelPicker
    private let periodPicker: CustomWheelPicker
    
    private let safeAreaBottom: CGFloat
    
    init(
        title: String,
        selectedHour: String?,
        selectedMinute: String?,
        selectedPeriod: String?,
        safeAreaBottom: CGFloat
    ) {
        reactor = TimePickerReactor(
            selectedHour: selectedHour,
            selectedMinute: selectedMinute,
            selectedPeriod: selectedPeriod
        )
        
        // 제목 설정
        var titleAttributes: [NSAttributedString.Key: Any] = title20.attributes(alignment: .left)
        titleAttributes[.foregroundColor] = UIColor.neutral900
        
        titleLabel.attributedText = NSAttributedString(string: title, attributes: titleAttributes)
        
        // 시 설정
        let hours: [String] = (1...12).map { String($0) }
        
        hourPicker = CustomWheelPicker(
            visibleItemCount: visibleItemCount,
            items: hours,
            itemHeight: itemHeight,
            selectedValue: selectedHour,
            isInfiniteScroll: true,
            initialIndex: hours.count - 1
        )
        
        // 분 설정
        let minutes: [String] = ["00", "30"]
        
        minutePicker = CustomWheelPicker(
            visibleItemCount: visibleItemCount,
            items: minutes,
            itemHeight: itemHeight,
            selectedValue: selectedMinute,
            isInfiniteScroll: false,
            initialIndex: 0
        )
        
        // 오전, 오후 심볼 가져오기
        let formatter = DateFormatter()
        formatter.locale = Locale.current

        let amSymbol = formatter.amSymbol ?? "AM"
        let pmSymbol = formatter.pmSymbol ?? "PM"
        
        // 오전, 오후 설정
        let periods: [String] = [amSymbol, pmSymbol]
        
        periodPicker = CustomWheelPicker(
            visibleItemCount: visibleItemCount,
            items: periods,
            itemHeight: itemHeight,
            selectedValue: selectedPeriod,
            isInfiniteScroll: false,
            initialIndex: 0
        )
        
        self.safeAreaBottom = safeAreaBottom
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 디자인 요소
    let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundWhite
        
        return view
    }()
    
    private let titleLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 0
        
        return lb
    }()
    
    private let pickerStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.alignment = .center
        sv.spacing = 20
        
        return sv
    }()
    
    private let button = {
        let btn = Button(title: String(localized: "Specify", table: "Home"))
        btn.isEnabled = false
        
        return btn
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
        
        view.addSubview(contentView)
        
        [titleLabel, pickerStackView, button].forEach {
            contentView.addSubview($0)
        }
        
        contentView.snp.makeConstraints { make in
            make.horizontalEdges.top.equalToSuperview()
            make.bottom.equalTo(button.snp.bottom).offset(safeAreaBottom)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalToSuperview().offset(32)
        }
        
        pickerStackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(titleLabel.snp.bottom).offset(40)
            make.height.equalTo(itemHeight * CGFloat(visibleItemCount))
        }
        
        [hourPicker, minutePicker, periodPicker].forEach {
            pickerStackView.addArrangedSubview($0)
            
            $0.snp.makeConstraints { make in
                make.verticalEdges.equalToSuperview()
            }
        }
        
        button.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(pickerStackView.snp.bottom).offset(40)
        }
    }
}

extension TimePickerView {
    // reactor와 view 연결
    private func bind(reactor: TimePickerReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    private func bindAction(reactor: TimePickerReactor) {
        hourPicker.selectedValueRelay
            .map { TimePickerReactor.Action.setHourString($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        minutePicker.selectedValueRelay
            .map { TimePickerReactor.Action.setMinuteString($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        periodPicker.selectedValueRelay
            .map { TimePickerReactor.Action.setPeriodString($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        button.rx.tap
            .map { Reactor.Action.confirm }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(reactor: TimePickerReactor) {
        reactor.state
            .map { ($0.hourString, $0.minuteString, $0.periodString) }
            .distinctUntilChanged { $0 == $1 }
            .subscribe(onNext: { [weak self] hour, minute, period in
                guard let self = self else { return }
                
                button.isEnabled = hour != nil && minute != nil && period != nil
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.confirmedTime }
            .compactMap { $0 }
            .bind(to: selectedTimeRelay)
            .disposed(by: disposeBag)
    }
}
