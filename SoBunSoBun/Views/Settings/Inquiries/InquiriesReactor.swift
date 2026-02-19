//
//  InquiriesReactor.swift
//  SoBunSoBun
//
//  Created by 허성필 on 2/20/26.
//

import ReactorKit
import OSLog

class InquiriesReactor: Reactor {
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "Settings.Inquiries.Reactor"
    )
    
    let initialState = State()
    
    enum Action {
        // 문의 내용 메뉴 선택시
        case menuBoxTapped(Bool)
        // 드랍 다운 메뉴 선택시
        case dropDownCellTapped(Int)
    }
    
    enum Mutation {
        // 문의 내용 메뉴 선택시
        case setIsMenuOpen(Bool)
        // 드롭 다운 메뉴 선택시
        case setMenuNumber(Int)
    }
    
    struct State {
        var isMenuOpen: Bool = false
        var menuNumber: Int?
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .menuBoxTapped(let isMenuOpen):
            return Observable.just(.setIsMenuOpen(isMenuOpen))
            
        case .dropDownCellTapped(let menuNumber):
            return Observable.just(.setMenuNumber(menuNumber))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setIsMenuOpen(let isMenuOpen):
            newState.isMenuOpen = isMenuOpen
            
        case .setMenuNumber(let menuNumber):
            newState.menuNumber = menuNumber
        }
        
        return newState
    }
}
