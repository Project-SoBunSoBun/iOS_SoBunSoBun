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
}
