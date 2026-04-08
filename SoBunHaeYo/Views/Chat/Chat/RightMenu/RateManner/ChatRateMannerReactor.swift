//
//  ChatRateMannerReactor.swift
//  SoBunHaeYo
//
//  Created by 김태은 on 2/16/26.
//

import Foundation
import ReactorKit
import OSLog

class ChatRateMannerReactor: Reactor {
    private let groupPostId: Int
    
    init(groupPostId: Int) {
        self.groupPostId = groupPostId
    }
    
    private let logger = Logger(
        subsystem: "SoBunHaeYo",
        category: "Chat.RateManner.Reactor"
    )
    
    var initialState: State = State()
    
    private let networkManager = ChatNetworkManager()
    private let disposeBag = DisposeBag()
    
    enum Action {
        case setMembers([ChatRoomDetailMemberModel])
        case skipTapped
        case rateMannersButtonTapped([[String]])
    }
    
    enum Mutation {
        case setMembers([ChatRoomDetailMemberModel])
        case setIsDone
        case setShouldPop
        case setErrorMessage(String)
    }
    
    struct State {
        var members: [ChatRoomDetailMemberModel] = []
        @Pulse var isDone: Void?
        @Pulse var shouldPop: Void?
        @Pulse var errorMessage: String?
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .setMembers(let members):
            return Observable.just(.setMembers(members))
            
        case .skipTapped:
            return skipRateManner()
            
        case .rateMannersButtonTapped(let manners):
            return rateManners(manners: manners)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setMembers(let members):
            let members = members.filter { $0.isOwner == false }
            logger.debug("매너 평가 멤버 목록: \(members)")
            
            newState.members = members
            
        case .setIsDone:
            newState.shouldPop = ()
            
        case .setShouldPop:
            newState.shouldPop = ()
            
        case .setErrorMessage(let message):
            newState.errorMessage = message
        }
        
        return newState
    }
    
    private func rateManners(manners: [[String]]) -> Observable<Mutation> {
        var body: [Int: [String]] = [:]
        
        manners.enumerated().forEach { index, mannerCodes in
            return body[currentState.members[index].userId] = mannerCodes
        }
        
        return networkManager.rateManners(groupPostId: groupPostId, manners: body)
            .asObservable()
            .flatMap { response -> Observable<Mutation> in
                self.logger.debug("매너 평가 성공")
                
                return Observable.just(.setIsDone)
            }
            .catch { error in
                let errorMessage = localizedErrorMessage((error as? APIErrorModel)?.errorCode)

                self.logger.critical("매너 평가 실패: \((error as? APIErrorModel)?.message ?? error.localizedDescription)")
                
                return Observable.just(.setErrorMessage(errorMessage))
            }
    }
    
    private func skipRateManner() -> Observable<Mutation> {
        let body: [Int: [String]] = [:]
        
        return networkManager.rateManners(groupPostId: groupPostId, manners: body)
            .asObservable()
            .flatMap { response -> Observable<Mutation> in
                self.logger.debug("매너 평가 스킵 성공")
                
                return Observable.just(.setShouldPop)
            }
            .catch { error in
                let errorMessage = localizedErrorMessage((error as? APIErrorModel)?.errorCode)

                self.logger.critical("매너 평가 스킵 실패: \((error as? APIErrorModel)?.message ?? error.localizedDescription)")
                
                return Observable.just(.setErrorMessage(errorMessage))
            }
    }
}
