//
//  CalendarPickerReactor.swift
//  SoBunHaeYo
//
//  Created by 김태은 on 12/13/25.
//

import Foundation
import ReactorKit

class CalendarPickerReactor: Reactor {
    let initialState: State
    private let calendar = Calendar.current
    
    init(selectedDate: Date?) {
        let now = Date()
        let today = calendar.startOfDay(for: now)
        
        // 현재 월의 첫날
        let minimumMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        
        // 다음 달의 마지막 날
        let nextMonth = calendar.date(byAdding: .month, value: 1, to: minimumMonth)!
        let maximumMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: nextMonth)!
        
        var state = State(today: today, minimumMonth: minimumMonth, maximumMonth: maximumMonth)
        
        if let selectedDate = selectedDate {
            state.selectedDate = selectedDate
            state.currentMonth = selectedDate
        }
        
        initialState = state
    }
    
    enum Action {
        case selectDate(Date)
        case previousMonth
        case nextMonth
        case confirm
    }
    
    enum Mutation {
        case setSelectedDate(Date)
        case setCurrentMonth(Date)
        case setConfirmedDate(Date)
    }
    
    struct State {
        let today: Date
        let minimumMonth: Date
        let maximumMonth: Date
        var selectedDate: Date? = nil
        var currentMonth: Date = Date()
        
        // currentMonth의 state가 바뀔 때마다 자동으로 계산
        var isPrevMonthEnabled: Bool {
            let calendar = Calendar.current
            let prevMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth)!
            return calendar.compare(prevMonth, to: minimumMonth, toGranularity: .month) != .orderedAscending
        }
        var isNextMonthEnabled: Bool {
            let calendar = Calendar.current
            let nextMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth)!
            return calendar.compare(nextMonth, to: maximumMonth, toGranularity: .month) != .orderedDescending
        }
        
        var calendarData: [CalendarCellDataModel] = []
        var confirmedDate: Date? = nil
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .selectDate(let date):
            // 최소 날짜, 다른 달, 최대 날짜 체크
            if calendar.startOfDay(for: date) < calendar.startOfDay(for: currentState.today) ||
                !calendar.isDate(date, equalTo: currentState.currentMonth, toGranularity: .month) ||
                calendar.startOfDay(for: date) > calendar.startOfDay(for: currentState.maximumMonth){
                return .empty()
            }
            
            return .just(.setSelectedDate(date))
            
        case .previousMonth:
            let newMonth = calendar.date(byAdding: .month, value: -1, to: currentState.currentMonth)!
            guard calendar.compare(newMonth, to: currentState.minimumMonth, toGranularity: .month) != .orderedAscending else {
                return .empty()
            }
            
            return .just(.setCurrentMonth(newMonth))
            
        case .nextMonth:
            let newMonth = calendar.date(byAdding: .month, value: 1, to: currentState.currentMonth)!
            guard calendar.compare(newMonth, to: currentState.maximumMonth, toGranularity: .month) != .orderedDescending else {
                return .empty()
            }
            
            return .just(.setCurrentMonth(newMonth))
            
        case .confirm:
            if let selectedDate = currentState.selectedDate{
                return .just(.setConfirmedDate(selectedDate))
            } else {
                return .empty()
            }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setSelectedDate(let date):
            newState.selectedDate = date
            newState.calendarData = generateCalendarData(currentMonth: newState.currentMonth, selectedDate: date, today: newState.today)
            
        case .setCurrentMonth(let month):
            newState.currentMonth = month
            newState.calendarData = generateCalendarData(currentMonth: month, selectedDate: newState.selectedDate, today: newState.today)
            
        case .setConfirmedDate(let date):
            newState.confirmedDate = date
        }
        
        return newState
    }
    
    // State 스트림에 따라 한 번 적용되는 오퍼레이터
    // 초기 데이터 로딩이나 외부 이벤트 구독(side Effect)을 위한 것임
    func transform(state: Observable<State>) -> Observable<State> {
        return state.map { [weak self] state in
            guard let self = self else { return state }
            
            var newState = state
            if newState.calendarData.isEmpty {
                newState.calendarData = self.generateCalendarData(
                    currentMonth: state.currentMonth,
                    selectedDate: state.selectedDate,
                    today: state.today
                )
            }
            
            return newState
        }
    }
    
    private func generateCalendarData(currentMonth: Date, selectedDate: Date?, today: Date) -> [CalendarCellDataModel] {
        let components = calendar.dateComponents([.year, .month], from: currentMonth)
        guard let firstDayOfMonth = calendar.date(from: components) else { return [] }
        
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        let range = calendar.range(of: .day, in: .month, for: firstDayOfMonth)!
        let numDays = range.count
        
        let previousMonth = calendar.date(byAdding: .month, value: -1, to: firstDayOfMonth)!
        let previousMonthRange = calendar.range(of: .day, in: .month, for: previousMonth)!
        let previousMonthDays = previousMonthRange.count
        
        var dates: [Date] = []
        
        // 이전 달
        let previousDaysCount = firstWeekday - 1
        if previousDaysCount > 0 {
            for day in (previousMonthDays - firstWeekday + 2)...previousMonthDays {
                if let date = calendar.date(byAdding: .day, value: day - previousMonthDays - 1, to: firstDayOfMonth) {
                    dates.append(date)
                }
            }
        }
        
        // 현재 달
        for day in 1...numDays {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                dates.append(date)
            }
        }
        
        // 다음 달 (항상 42칸 = 6행으로 채움)
        let remainingCells = 42 - dates.count
        if remainingCells > 0 {
            for day in 1...remainingCells {
                if let date = calendar.date(byAdding: .day, value: numDays + day - 1, to: firstDayOfMonth) {
                    dates.append(date)
                }
            }
        }
        
        return dates.map { date in
            let day = calendar.component(.day, from: date)
            let isCurrentMonth = calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
            let isSelected: Bool = {
                if let selectedDate = selectedDate {
                    return calendar.isDate(date, inSameDayAs: selectedDate)
                } else {
                    return false
                }
            }()
            let isToday = calendar.isDateInToday(date)
            let weekday = calendar.component(.weekday, from: date)
            let isDisabled = calendar.startOfDay(for: date) < calendar.startOfDay(for: today)
            
            return CalendarCellDataModel(
                date: date,
                day: day,
                isSelected: isSelected,
                isCurrentMonth: isCurrentMonth,
                isToday: isToday,
                isWeekend: weekday == 1 || weekday == 7,
                isDisabled: isDisabled
            )
        }
    }
}
