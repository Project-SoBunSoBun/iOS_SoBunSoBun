//
//  CalendarCellDataModel.swift
//  SoBunSoBun
//
//  Created by 김태은 on 12/13/25.
//

import Foundation

struct CalendarCellDataModel: Equatable {
    let date: Date
    let day: Int
    let isSelected: Bool
    let isCurrentMonth: Bool
    let isToday: Bool
    let isWeekend: Bool
    let isDisabled: Bool
    
    static func == (lhs: CalendarCellDataModel, rhs: CalendarCellDataModel) -> Bool {
            return lhs.date == rhs.date &&
                   lhs.isSelected == rhs.isSelected &&
                   lhs.isCurrentMonth == rhs.isCurrentMonth &&
                   lhs.isToday == rhs.isToday
        }
}
