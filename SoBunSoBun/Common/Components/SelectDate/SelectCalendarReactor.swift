//
//  SelectCalendarReactor.swift
//  SoBunSoBun
//
//  Created by 김태은 on 12/13/25.
//

import Foundation
import ReactorKit

class SelectCalendarReactor: Reactor {
    let initialState: State
    
    init(selectedDate: Date?) {
        var state = State()
        state.selectedDate = selectedDate
        if let selectedDate = selectedDate {
            state.currentMonth = selectedDate
        }
        
        initialState = state
    }
    
    private let calendar = Calendar.current
    
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
        var selectedDate: Date? = nil
        var currentMonth: Date = Date()
        var minimumDate: Date = Date()
        var calendarData: [CalendarCellDataModel] = []
        var confirmedDate: Date?
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .selectDate(let date):
            // 최소 날짜 체크
            if calendar.startOfDay(for: date) < calendar.startOfDay(for: currentState.minimumDate) {
                return .empty()
            }
            
            // 다른 달 날짜 선택 시 해당 달로 이동
            if !calendar.isDate(date, equalTo: currentState.currentMonth, toGranularity: .month) {
                return .concat([
                    .just(.setSelectedDate(date)),
                    .just(.setCurrentMonth(date))
                ])
            }
            
            return .just(.setSelectedDate(date))
            
        case .previousMonth:
            let newMonth = calendar.date(byAdding: .month, value: -1, to: currentState.currentMonth) ?? currentState.currentMonth
            return .just(.setCurrentMonth(newMonth))
            
        case .nextMonth:
            let newMonth = calendar.date(byAdding: .month, value: 1, to: currentState.currentMonth) ?? currentState.currentMonth
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
            newState.calendarData = generateCalendarData(currentMonth: newState.currentMonth, selectedDate: date, minimumDate: newState.minimumDate)
            
        case .setCurrentMonth(let month):
            newState.currentMonth = month
            newState.calendarData = generateCalendarData(currentMonth: month, selectedDate: newState.selectedDate, minimumDate: newState.minimumDate)
            
        case .setConfirmedDate(let date):
            newState.confirmedDate = date
        }
        
        return newState
    }
    
    
    func transform(state: Observable<State>) -> Observable<State> {
        return state.map { [weak self] state in
            guard let self = self else { return state }
            var newState = state
            if newState.calendarData.isEmpty {
                newState.calendarData = self.generateCalendarData(
                    currentMonth: state.currentMonth,
                    selectedDate: state.selectedDate,
                    minimumDate: state.minimumDate
                )
            }
            return newState
        }
    }
    
    private func generateCalendarData(currentMonth: Date, selectedDate: Date?, minimumDate: Date) -> [CalendarCellDataModel] {
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
        
        // 다음 달
        let remainingCells = 35 - dates.count
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
            let isDisabled = calendar.startOfDay(for: date) < calendar.startOfDay(for: minimumDate)
            
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
