//
//  RegisterPostReactor.swift
//  SoBunSoBun
//
//  Created by 김태은 on 12/11/25.
//

import Foundation
import ReactorKit
import RxSwift
import OSLog

class RegisterPostReactor: Reactor {
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "Home.RegisterPost.Reactor"
    )
    
    private let disposeBag = DisposeBag()
    
    let initialState: State = State()
    
    enum Action {
        case titleTextChanged(String)
        case addCategoryTapped
        case setSelectedCategories([String])
        case minimumMembersTextChanged(Int)
        case maximumMembersTextChanged(Int)
        case locationTextChanged(String)
        case setDateTextFieldTapped
        case setDate(String)
        case setTimeTextFieldTapped
        case setTime(String)
        case plannedItemsTextChanged(String)
        case notesTextChanged(String)
        case registerButtonTapped
    }
    
    enum Mutation {
        case setTitle(String)
        case setAddCategoryTapped
        case setSelectedCategories([String])
        case setMinimumMembers(Int)
        case setMaximumMembers(Int)
        case setLocation(String)
        case setDateTextFieldTapped
        case setDate(String)
        case setTimeTextFieldTapped
        case setTime(String)
        case setPlannedItems(String)
        case setNotes(String)
        
        case setLoading(Bool)
        case success
        case setErrorMessage(String)
    }
    
    struct State {
        var title: String?
        @Pulse var shouldShowBottomCategorySheet: Void?
        var selectedCategories: [String] = []
        var minimumMembers: Int?
        var maximumMembers: Int?
        var location: String?
        @Pulse var shouldShowBottomDateSheet: Void?
        var selectedDate: String?
        @Pulse var shouldShowBottomTimeSheet: Void?
        var selectedTime: String?
        var plannedItems: String?
        var notes: String?
        var isRegisterButtonEnable: Bool {
            return (
                title != nil && !title!.isEmpty &&
                !selectedCategories.isEmpty &&
                minimumMembers != nil &&
                maximumMembers != nil &&
                location != nil && !location!.isEmpty &&
                selectedDate != nil &&
                selectedTime != nil &&
                plannedItems != nil && !plannedItems!.isEmpty &&
                notes != nil && !notes!.isEmpty
            )
        }
        
        var isLoading: Bool = false
        @Pulse var isSuccess: Void?
        var errorMessage: String?
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .titleTextChanged(let title):
            return Observable.just(.setTitle(title))
            
        case .addCategoryTapped:
            return Observable.just(.setAddCategoryTapped)
            
        case .setSelectedCategories(let selectedCategories):
            return Observable.just(.setSelectedCategories(selectedCategories))
            
        case .minimumMembersTextChanged(let members):
            return Observable.just(.setMinimumMembers(members))
            
        case .maximumMembersTextChanged(let members):
            return Observable.just(.setMaximumMembers(members))
            
        case .locationTextChanged(let location):
            return Observable.just(.setLocation(location))
            
        case .setDateTextFieldTapped:
            return Observable.just(.setDateTextFieldTapped)
            
        case .setDate(let date):
            return Observable.just(.setDate(date))
            
        case .setTimeTextFieldTapped:
            return Observable.just(.setTimeTextFieldTapped)
            
        case .setTime(let time):
            return Observable.just(.setTime(time))
            
        case .plannedItemsTextChanged(let items):
            return Observable.just(.setPlannedItems(items))
            
        case .notesTextChanged(let notes):
            return Observable.just(.setNotes(notes))
            
        case .registerButtonTapped:
            return registerPost()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setTitle(let title):
            newState.title = title
            
        case .setAddCategoryTapped:
            newState.shouldShowBottomCategorySheet = ()
            
        case .setSelectedCategories(let selectedCategories):
            newState.selectedCategories = selectedCategories
            
        case .setDateTextFieldTapped:
            newState.shouldShowBottomDateSheet = ()
            
        case .setMinimumMembers(let members):
            newState.minimumMembers = members
            
        case .setMaximumMembers(let members):
            newState.maximumMembers = members
            
        case .setLocation(let location):
            newState.location = location
            
        case .setDate(let date):
            newState.selectedDate = date
            
        case .setTimeTextFieldTapped:
            newState.shouldShowBottomTimeSheet = ()
            
        case .setTime(let time):
            newState.selectedTime = time
            
        case .setPlannedItems(let items):
            newState.plannedItems = items
            
        case .setNotes(let notes):
            newState.notes = notes
            
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
            
        case .success:
            newState.isSuccess = ()
            
        case .setErrorMessage(let message):
            newState.errorMessage = message
        }
        
        return newState
    }
    
    private func registerPost() -> Observable<Mutation> {
        guard let title = currentState.title, !title.isEmpty,
              !currentState.selectedCategories.isEmpty,
              let minimumMembers = currentState.minimumMembers,
              let maximumMembers = currentState.maximumMembers,
              let location = currentState.location, !location.isEmpty,
              let selectedDate = currentState.selectedDate,
              let selectedTime = currentState.selectedTime,
              let plannedItems = currentState.plannedItems, !plannedItems.isEmpty,
              let notes = currentState.notes, !notes.isEmpty,
              let convertedDate: Date = stringToDate(
                string: [selectedDate, selectedTime].joined(separator: " "),
                format: "yyyy - MM - dd a hh:mm"
              ),
              let meetAtDateString: String = dateToISO8601String(date: convertedDate),
              let deadlineAtDate: Date = Calendar.current.date(byAdding: .day, value: -1, to: convertedDate),
              let deadlineAtDateString: String = dateToISO8601String(date: deadlineAtDate) else {
            self.logger.fault("RegisterPostBodyModel 생성 실패")
            return Observable.concat([
                Observable.just(.setLoading(false)).delay(.seconds(1), scheduler: MainScheduler.instance),
                Observable.just(.setErrorMessage(String(localized: "CheckYourInputs")))
            ])
        }
        
        guard maximumMembers >= minimumMembers else {
            return Observable.concat([
                Observable.just(.setLoading(false)).delay(.seconds(1), scheduler: MainScheduler.instance),
                Observable.just(.setErrorMessage(String(localized: "CheckYourMinimumMembers")))
            ])
        }
        
        let model: RegisterPostBodyModel = .init(
            title: title,
            categories: currentState.selectedCategories.joined(separator: ","),
            locationName: location,
            meetAt: meetAtDateString,
            deadlineAt: deadlineAtDateString,
            itemsText: plannedItems,
            notesText: notes,
            minMembers: minimumMembers,
            maxMembers: maximumMembers
        )
        
        return Observable.concat([
            Observable.just(.setLoading(true)),
            NetworkManager.shared.registerPost(model: model)
                .asObservable()
                .flatMap { _ -> Observable<Mutation> in
                    self.logger.debug("\(title) 게시글 등록 성공")
                    
                    return Observable.concat([
                        Observable.just(.setLoading(false)),
                        Observable.just(.success)
                    ])
                }
                .catch { error in
                    self.logger.fault("게시글 등록 실패: \(error.localizedDescription)")
                    
                    return Observable.concat([
                        Observable.just(.setLoading(false)).delay(.seconds(1), scheduler: MainScheduler.instance),
                        Observable.just(.setErrorMessage(String(localized: "ErrorMessage")))
                    ])
                }
        ])
    }
}

