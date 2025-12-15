//
//  TimePickerReactor.swift
//  SoBunSoBun
//
//  Created by 김태은 on 12/16/25.
//

import ReactorKit

class TimePickerReactor: Reactor {
    let initialState: State
    
    init(
        selectedHour: String?,
        selectedMinute: String?,
        selectedPeriod: String?
    ) {
        let state = State(
            hourString: selectedHour,
            minuteString: selectedMinute,
            periodString: selectedPeriod
        )
        
        initialState = state
    }
    
    enum Action {
        case setHourString(String?)
        case setMinuteString(String?)
        case setPeriodString(String?)
        case confirm
    }
    
    enum Mutation {
        case setHourString(String?)
        case setMinuteString(String?)
        case setPeriodString(String?)
        case setConfirmedTime(String)
    }
    
    struct State {
        var hourString: String?
        var minuteString: String?
        var periodString: String?
        var confirmedTime: String?
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .setHourString(let hour):
            return .just(.setHourString(hour))
            
        case .setMinuteString(let minute):
            return .just(.setMinuteString(minute))
            
        case .setPeriodString(let period):
            return .just(.setPeriodString(period))
            
        case .confirm:
            if let hour = currentState.hourString,
               let minute = currentState.minuteString,
               let period = currentState.periodString {
                return .just(.setConfirmedTime("\(period) \(hour):\(minute)"))
            } else {
                return .empty()
            }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setHourString(let hour):
            newState.hourString = hour
            
        case .setMinuteString(let minute):
            newState.minuteString = minute
            
        case .setPeriodString(let period):
            newState.periodString = period
            
        case .setConfirmedTime(let timeString):
            newState.confirmedTime = timeString
        }
        
        return newState
    }
}
