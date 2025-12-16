//
//  CalendarPickerView.swift
//  SoBunSoBun
//
//  Created by 김태은 on 12/11/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class CalendarPickerView: UIViewController {
    typealias Reactor = CalendarPickerReactor
    private let reactor: CalendarPickerReactor
    
    let selectedDateRelay = PublishRelay<String?>()
    
    init(selectedDate: Date? = nil) {
        self.reactor = CalendarPickerReactor(selectedDate: selectedDate)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let calendar = Calendar.current
    
    private let disposeBag = DisposeBag()
    
    // MARK: - 디자인 요소
    private func weekDayLabel() -> UILabel {
        let lb = UILabel()
        lb.font = body12.font
        lb.textAlignment = .center
        
        return lb
    }
    
    let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundWhite
        
        return view
    }()
    
    private let yearLabel: UILabel = {
        let lb = UILabel()
        lb.textColor = .neutral500
        
        return lb
    }()
    
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
    }()
    
    private let monthLabel: UILabel = {
        let lb = UILabel()
        lb.font = title14.font
        lb.textColor = .neutral900
        
        return lb
    }()
    
    private let prevButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.preferredSymbolConfigurationForImage = .init(pointSize: 24)
        config.image = .blackChevronLeft
        config.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        let btn = UIButton(configuration: config)
        
        return btn
    }()
    
    private let nextButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.preferredSymbolConfigurationForImage = .init(pointSize: 24)
        config.image = .blackChevronRight
        config.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        let btn = UIButton(configuration: config)
        
        return btn
    }()
    
    private let weekdayStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.spacing = 0
        
        return sv
    }()
    
    private let calendarCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(CalendarCell.self, forCellWithReuseIdentifier: "CalendarCell")
        cv.backgroundColor = .clear
        cv.isScrollEnabled = false
        
        return cv
    }()
    
    private var currentDate = Date()
    
    private var calendarDates: [Date?] = []
    
    private let button = {
        let btn = Button(title: String(localized: "Specify"))
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
        
        contentView.snp.makeConstraints { make in
            make.horizontalEdges.top.equalToSuperview()
        }
        
        [yearLabel, headerView, weekdayStackView, calendarCollectionView, button].forEach {
            contentView.addSubview($0)
        }
        
        yearLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(24)
        }
        
        headerView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(24)
            make.top.equalTo(yearLabel.snp.bottom).offset(16)
        }
        
        [prevButton, monthLabel, nextButton].forEach {
            headerView.addSubview($0)
        }
        
        prevButton.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.verticalEdges.equalToSuperview()
        }
        
        monthLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        nextButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.verticalEdges.equalToSuperview()
        }
        
        weekdayStackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(headerView.snp.bottom).offset(16)
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.current
        
        
        guard let weekdays = dateFormatter.veryShortWeekdaySymbols else {
            return
        }
        
        for (index, day) in weekdays.enumerated() {
            let view = UIView()
            view.backgroundColor = .clear
            
            let label = weekDayLabel()
            label.text = day.uppercased()
            
            if index == 0 || index == 6 { // 토, 일
                label.textColor = .primary300
            } else {
                label.textColor = .neutral700
            }
            
            view.addSubview(label)
            
            view.snp.makeConstraints { make in
                make.width.equalTo(30)
                make.height.equalTo(40)
            }
            
            label.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
            
            weekdayStackView.addArrangedSubview(view)
        }
        
        calendarCollectionView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(weekdayStackView.snp.bottom)
            make.height.equalTo(40 * 5)
        }
        
        button.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.top.equalTo(calendarCollectionView.snp.bottom).offset(16)
            make.bottom.equalToSuperview().inset(safeareaBottom)
        }
    }
}

extension CalendarPickerView {
    private func bind(reactor: CalendarPickerReactor) {
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
        
        calendarCollectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    private func bindAction(reactor: CalendarPickerReactor) {
        prevButton.rx.tap
            .map { Reactor.Action.previousMonth }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        nextButton.rx.tap
            .map { Reactor.Action.nextMonth }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        button.rx.tap
            .map { Reactor.Action.confirm }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        calendarCollectionView.rx.itemSelected
            .compactMap { [weak self] indexPath in self?.reactor.currentState.calendarData[indexPath.item].date
            }
            .map { Reactor.Action.selectDate($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func bindState(reactor: CalendarPickerReactor) {
        reactor.state.map { $0.currentMonth }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] date in
                guard let self = self else { return }
                
                let formatter = DateFormatter()
                formatter.locale = Locale.current
                
                // 년
                formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyy", options: 0, locale: Locale.current)
                let yearString = formatter.string(from: date)
                let yearAttributedText = NSAttributedString(string: yearString, attributes: title14.attributes(alignment: .center))
                yearLabel.attributedText = yearAttributedText
                
                // 월
                formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "MMMM", options: 0, locale: Locale.current)
                let monthString = formatter.string(from: date)
                monthLabel.text = monthString
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.calendarData }
            .distinctUntilChanged()
            .bind(to: calendarCollectionView.rx.items(
                cellIdentifier: "CalendarCell",
                cellType: CalendarCell.self
            )) { index, model, cell in
                cell.configure(model)
            }
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isPrevMonthEnabled }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] isEnabled in
                guard let self = self else { return }
                
                prevButton.isEnabled = isEnabled
                var config = prevButton.configuration
                config?.image = isEnabled ? .blackChevronLeft : .greyChevronLeft
                prevButton.configuration = config
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isNextMonthEnabled }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] isEnabled in
                guard let self = self else { return }
                
                nextButton.isEnabled = isEnabled
                var config = nextButton.configuration
                config?.image = isEnabled ? .blackChevronRight : .greyChevronRight
                nextButton.configuration = config
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.selectedDate }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] date in
                guard let self = self else { return }
                
                button.isEnabled = date != nil
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.confirmedDate }
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] date in
                guard let self = self else { return }
                
                if let selectedDate = reactor.currentState.confirmedDate {
                    let dateString = dateToString(date: selectedDate, format: "yyyy - MM - dd")
                    selectedDateRelay.accept(dateString)
                }
            })
            .disposed(by: disposeBag)
    }
}

extension CalendarPickerView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width / 7
        return CGSize(width: width, height: 40)
    }
}

#if DEBUG
// 미리보기
import SwiftUI

struct CalendarPickerViewController_Preview: PreviewProvider {
    static var previews: some SwiftUI.View {
        UIViewControllerPreview {
            CalendarPickerView()
        }
    }
}
#endif
