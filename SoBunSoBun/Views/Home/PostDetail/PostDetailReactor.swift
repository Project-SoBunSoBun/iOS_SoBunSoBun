//
//  PostDetailReactor.swift
//  SoBunSoBun
//
//  Created by 김태은 on 1/28/26.
//

import Foundation
import ReactorKit
import RxSwift
import OSLog

class PostDetailReactor: Reactor {
    private let postId: Int
    
    init(postId: Int) {
        self.postId = postId
    }
    
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "Home.PostDetail.Reactor"
    )
    
    private let disposeBag = DisposeBag()
    private let networkManager = HomeNetworkManager()
    
    private let errorMessage: String = String(localized: "ErrorMessage", table: "Common")
    
    let initialState: State = State()
    
    enum Action {
        case viewDidLoad
        case refresh
        
        // 상단 네비게이션 바
        case shareButtonTapped
        case saveButtonTapped
        case menuButtonTapped
        case reportPostButtonTapped
        case reportPost
        case deletePostButtonTapped
        case deletePost
        
        // 댓글
        case createComment(String)
        
        case setSelectedCommentId(Int)
        
        case replyButtonTapped(String)
        
        case reportButtonTapped
        case reportComment
        
        case editButtonTapped
        case editCommentTapped(String)
        case editCancelTapped
        
        case deleteCommentButtonTapped
        case deleteComment
        
        case chatButtonTapped
    }
    
    enum Mutation {
        case setPostInfo(PostModel)
        case setPostCommentsCount(CommentCountModel)
        case setComments([CommentModel])
        case setCommentedUsersToNickname([String: String])
        case setCommentedUsersToId([String: Int])
        
        case setShouldShowShare
        case setIsSaved(Bool)
        case setIsMenuOpen(Bool)
        case setShouldShowReportPostAlert
        case setShouldShowReportPostDoneAlert
        case setShouldShowDeletePostAlert
        case setShouldShowDeletePostDoneAlert
        
        case setSelectedCommentId(Int)
        
        case setTextViewText(String)
        
        case setShouldShowReportCommentAlert
        case setShouldShowReportCommentDoneAlert
        
        case setIsEditMode(Bool)
        
        case setShouldShowDeleteCommentAlert
        case setShouldShowDeleteCommentDoneAlert
        
        case setShouldNavigateToChat
        
        case setRefreshing(Bool)
        
        case setErrorMessage(String)
    }
    
    struct State {
        var postInfo: PostModel?
        var postCommentsCount: CommentCountModel?
        var comments: [CommentModel] = []
        
        var commentedUsersToNickname: [String: String]?
        var commentedUsersToId: [String: Int]?
        
        var isSaved: Bool = false
        var isMenuOpen: Bool = false
        
        var selectedCommentId: Int?
        var isEditMode: Bool = false
        
        @Pulse var textViewText: String = ""
        
        @Pulse var shouldShowShare: Void?
        
        @Pulse var shouldShowReportPostAlert: Void?
        @Pulse var shouldShowReportPostDoneAlert: Void?
        
        @Pulse var shouldShowDeletePostAlert: Void?
        @Pulse var shouldShowDeletePostDoneAlert: Void?
        
        @Pulse var shouldShowReportCommentAlert: Void?
        @Pulse var shouldShowReportCommentDoneAlert: Void?
        
        @Pulse var shouldShowDeleteCommentAlert: Void?
        @Pulse var shouldShowDeleteCommentDoneAlert: Void?
        
        @Pulse var shouldNavigateToChat: Void?
        
        var isRefreshing: Bool = false
        
        @Pulse var errorMessage: String?
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return Observable.concat([
                getPost(),
                checkPostSaved(),
                getPostCommentsCount(),
                getComments()
            ])
            
        case .refresh:
            return Observable.concat([
                Observable.just(.setRefreshing(true)),
                Observable.just(.setIsEditMode(false)),
                getPost(),
                getPostCommentsCount(),
                getComments(),
                Observable.just(.setRefreshing(false))
            ])
            
        case .shareButtonTapped:
            return Observable.just(.setShouldShowShare)
            
        case .saveButtonTapped:
            let isSaved: Bool = currentState.isSaved
            
            return isSaved ? cancelSavePost() : savePost()
            
        case .menuButtonTapped:
            var isMenuOpen: Bool = currentState.isMenuOpen
            isMenuOpen.toggle()
            
            return Observable.just(.setIsMenuOpen(isMenuOpen))
            
        case .reportPostButtonTapped:
            return Observable.just(.setShouldShowReportPostAlert)
            
        case .reportPost:
            return reportPost()
            
        case .deletePostButtonTapped:
            return Observable.just(.setShouldShowDeletePostAlert)
            
        case .deletePost:
            return deletePost()
            
        case .createComment(let content):
            return createComment(content: content)
            
        case .setSelectedCommentId(let id):
            return Observable.just(.setSelectedCommentId(id))
            
        case .replyButtonTapped(let string):
            return Observable.concat([
                Observable.just(.setIsEditMode(false)),
                Observable.just(.setTextViewText(string))
            ])
            
        case .reportButtonTapped:
            return Observable.concat([
                Observable.just(.setIsEditMode(false)),
                Observable.just(.setShouldShowReportCommentAlert)
            ])
            
        case .reportComment:
            if let commentId = currentState.selectedCommentId {
                return reportComment(commentId: commentId)
            } else {
                return Observable.empty()
            }
            
        case .editButtonTapped:
            return Observable.just(.setIsEditMode(true))
            
        case .editCommentTapped(let content):
            return patchComment(content: content)
            
        case .editCancelTapped:
            return Observable.just(.setIsEditMode(false))
            
        case .deleteCommentButtonTapped:
            return Observable.concat([
                Observable.just(.setIsEditMode(false)),
                Observable.just(.setShouldShowDeleteCommentAlert)
            ])
            
        case .deleteComment:
            return deleteComment()
            
        case .chatButtonTapped:
            return Observable.concat([
                Observable.just(.setIsEditMode(false)),
                Observable.just(.setShouldNavigateToChat)
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setPostInfo(let model):
            newState.postInfo = model
            
        case .setPostCommentsCount(let model):
            newState.postCommentsCount = model
            
        case .setComments(let models):
            newState.comments = models
            
        case .setCommentedUsersToNickname(let dict):
            newState.commentedUsersToNickname = dict
            
        case .setCommentedUsersToId(let dict):
            newState.commentedUsersToId = dict
            
        case .setShouldShowShare:
            newState.shouldShowShare = ()
            
        case .setIsSaved(let isSaved):
            newState.isSaved = isSaved
            
        case .setIsMenuOpen(let isMenuOpen):
            newState.isMenuOpen = isMenuOpen
            
        case .setShouldShowReportPostAlert:
            newState.shouldShowReportPostAlert = ()
            
        case .setShouldShowReportPostDoneAlert:
            newState.shouldShowReportPostDoneAlert = ()
            
        case .setShouldShowDeletePostAlert:
            newState.shouldShowDeletePostAlert = ()
            
        case . setShouldShowDeletePostDoneAlert:
            newState.shouldShowDeletePostDoneAlert = ()
            
        case .setSelectedCommentId(let id):
            newState.selectedCommentId = id
            
        case .setIsEditMode(let isEnabled):
            newState.isEditMode = isEnabled
            
        case .setTextViewText(let string):
            newState.textViewText = string
            
        case .setShouldShowReportCommentAlert:
            newState.shouldShowReportCommentAlert = ()
            
        case .setShouldShowReportCommentDoneAlert:
            newState.shouldShowReportCommentDoneAlert = ()
            
        case .setShouldShowDeleteCommentAlert:
            newState.shouldShowDeleteCommentAlert = ()
            
        case .setShouldShowDeleteCommentDoneAlert:
            newState.shouldShowDeleteCommentDoneAlert = ()
            
        case .setShouldNavigateToChat:
            newState.shouldNavigateToChat = ()
            
        case .setRefreshing(let isRefreshing):
            newState.isRefreshing = isRefreshing
            
        case .setErrorMessage(let message):
            newState.errorMessage = message
        }
        
        return newState
    }
    
    // 게시글 정보 불러오기
    private func getPost() -> Observable<Mutation> {
        return networkManager.getPost(id: postId)
            .asObservable()
            .flatMap { model -> Observable<Mutation> in
                return Observable.just(.setPostInfo(model))
            }
            .catch { [weak self] error in
                guard let self = self else {
                    return Observable.just(.setErrorMessage("Error!"))
                }
                
                logger.critical("게시글 정보 호출 실패: \(error.localizedDescription)")
                return Observable.just(.setErrorMessage(errorMessage))
            }
    }
    
    // 게시글 저장 유무 확인
    private func checkPostSaved() -> Observable<Mutation> {
        return networkManager.checkPostSaved(id: postId)
            .asObservable()
            .flatMap { bool -> Observable<Mutation> in
                return Observable.just(.setIsSaved(bool))
            }
            .catch { [weak self] error in
                guard let self = self else {
                    return Observable.just(.setErrorMessage("Error!"))
                }
                
                logger.critical("게시글 저장 목록 불러오기 실패: \(error.localizedDescription)")
                return Observable.just(.setErrorMessage(errorMessage))
            }
    }
    
    // 댓글 개수 불러오기
    private func getPostCommentsCount() -> Observable<Mutation> {
        return networkManager.getPostCommentsCount(id: postId)
            .asObservable()
            .flatMap { model -> Observable<Mutation> in
                return Observable.just(.setPostCommentsCount(model))
            }
            .catch { [weak self] error in
                guard let self = self else {
                    return Observable.just(.setErrorMessage("Error!"))
                }
                
                logger.critical("게시글 댓글 갯수 호출 실패: \(error.localizedDescription)")
                return Observable.just(.setErrorMessage(errorMessage))
            }
    }
    
    // 댓글 불러오기
    private func getComments() -> Observable<Mutation> {
        return networkManager.getPostComments(id: postId)
            .asObservable()
            .flatMap { models -> Observable<Mutation> in
                let commentedUsersToNickname: [String: String] = Dictionary(
                    models.compactMap {
                        (String($0.userId), $0.userNickname ?? String(localized: "Unknown", table: "Common"))
                    },
                    uniquingKeysWith: { (first, second) in second }
                )
                
                let commentedUsersToId: [String: Int] = Dictionary(
                    models.compactMap {
                        guard let nickname = $0.userNickname else { return nil }
                        return (nickname, $0.userId)
                    },
                    uniquingKeysWith: { (first, second) in second }
                )
                
                return Observable.concat([
                    Observable.just(.setComments(models)),
                    Observable.just(.setCommentedUsersToNickname(commentedUsersToNickname)),
                    Observable.just(.setCommentedUsersToId(commentedUsersToId))
                ])
            }
            .catch { [weak self] error in
                guard let self = self else {
                    return Observable.just(.setErrorMessage("Error!"))
                }
                
                logger.critical("게시글 댓글 호출 실패: \(error.localizedDescription)")
                return Observable.just(.setErrorMessage(errorMessage))
            }
    }
    
    // 게시글 저장
    private func savePost() -> Observable<Mutation> {
        return networkManager.savePost(id: postId)
            .asObservable()
            .flatMap { _ -> Observable<Mutation> in
                return Observable.just(.setIsSaved(true))
            }
            .catch { [weak self] error in
                guard let self = self else {
                    return Observable.just(.setErrorMessage("Error!"))
                }
                
                logger.critical("게시글 저장 실패: \(error.localizedDescription)")
                return Observable.just(.setErrorMessage(errorMessage))
            }
    }
    
    // 게시글 저장 취소
    private func cancelSavePost() -> Observable<Mutation> {
        return networkManager.cancelSavePost(id: postId)
            .asObservable()
            .flatMap { _ -> Observable<Mutation> in
                return Observable.just(.setIsSaved(false))
            }
            .catch { [weak self] error in
                guard let self = self else {
                    return Observable.just(.setErrorMessage("Error!"))
                }
                
                logger.critical("게시글 저장 취소 실패: \(error.localizedDescription)")
                return Observable.just(.setErrorMessage(errorMessage))
            }
    }
    
    // 게시글 신고
    private func reportPost() -> Observable<Mutation> {
        return networkManager.reportPost(id: postId)
            .asObservable()
            .flatMap { _ -> Observable<Mutation> in
                return Observable.just(.setShouldShowReportPostDoneAlert)
            }
            .catch { [weak self] error in
                guard let self = self else {
                    return Observable.just(.setErrorMessage("Error!"))
                }
                
                logger.critical("게시글 신고 실패: \(error.localizedDescription)")
                return Observable.just(.setErrorMessage(String(localized: "ErrorAlreadyReportedOrNot", table: "Home")))
            }
    }
    
    // 게시글 삭제
    private func deletePost() -> Observable<Mutation> {
        return networkManager.deletePost(id: postId)
            .asObservable()
            .flatMap { _ -> Observable<Mutation> in
                return Observable.just(.setShouldShowDeletePostDoneAlert)
            }
            .catch { [weak self] error in
                guard let self = self else {
                    return Observable.just(.setErrorMessage("Error!"))
                }
                
                logger.critical("게시글 삭제 실패: \(error.localizedDescription)")
                return Observable.just(.setErrorMessage(errorMessage))
            }
    }
    
    // 댓글 생성
    private func createComment(content: String) -> Observable<Mutation> {
        let cleanedContent = content.limitNewLines(limit: 2).trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !cleanedContent.isEmpty else {
            return Observable.just(.setErrorMessage(String(localized: "CheckYourInputs", table: "Common")))
        }
        
        let convertedComment = convertComment(comment: cleanedContent)
        
        return networkManager.createPostComment(postId: postId, content: convertedComment)
            .asObservable()
            .flatMap { [weak self] _ -> Observable<Mutation> in
                guard let self = self else { return Observable.empty() }
                
                return getComments()
            }
            .catch { [weak self] error in
                guard let self = self else {
                    return Observable.just(.setErrorMessage("Error!"))
                }
                
                logger.critical("댓글 생성 실패: \(error.localizedDescription)")
                return Observable.just(.setErrorMessage(errorMessage))
            }
    }
    
    // 댓글 수정
    private func patchComment(content: String) -> Observable<Mutation> {
        guard let commentId = currentState.selectedCommentId else {
            return Observable.just(.setErrorMessage(errorMessage))
        }
        
        let cleanedContent = content.limitNewLines(limit: 2).trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !cleanedContent.isEmpty else {
            return Observable.just(.setErrorMessage(String(localized: "CheckYourInputs", table: "Common")))
        }
        
        let convertedComment = convertComment(comment: cleanedContent)
        
        return networkManager.patchPostComment(id: commentId, content: convertedComment)
            .asObservable()
            .flatMap { [weak self] _ -> Observable<Mutation> in
                guard let self = self else { return Observable.empty() }
                
                return Observable.concat([
                    getComments(),
                    Observable.just(.setIsEditMode(false))
                ])
            }
            .catch { [weak self] error in
                guard let self = self else {
                    return Observable.just(.setErrorMessage("Error!"))
                }
                
                logger.critical("댓글 수정 실패: \(error.localizedDescription)")
                return Observable.just(.setErrorMessage(errorMessage))
            }
    }
    
    // 댓글 삭제
    private func deleteComment() -> Observable<Mutation> {
        guard let commentId = currentState.selectedCommentId else {
            return Observable.empty()
        }
        
        return networkManager.deletePostComment(id: commentId)
            .asObservable()
            .flatMap { [weak self] _ -> Observable<Mutation> in
                guard let self = self else { return Observable.empty() }
                
                return Observable.concat([
                    getPostCommentsCount(),
                    getComments(),
                    Observable.just(.setShouldShowDeleteCommentDoneAlert)
                ])
            }
            .catch { [weak self] error in
                guard let self = self else {
                    return Observable.just(.setErrorMessage("Error!"))
                }
                
                logger.critical("댓글 삭제 실패: \(error.localizedDescription)")
                return Observable.just(.setErrorMessage(errorMessage))
            }
    }
    
    // 댓글 신고
    private func reportComment(commentId: Int) -> Observable<Mutation> {
        guard let commentId = currentState.selectedCommentId else {
            return Observable.empty()
        }
        
        return networkManager.reportPostComment(id: commentId)
            .asObservable()
            .flatMap { _ -> Observable<Mutation> in
                return Observable.just(.setShouldShowReportCommentDoneAlert)
            }
            .catch { [weak self] error in
                guard let self = self else {
                    return Observable.just(.setErrorMessage("Error!"))
                }
                
                logger.critical("댓글 신고 실패: \(error.localizedDescription)")
                return Observable.just(.setErrorMessage(String(localized: "ErrorAlreadyReportedOrNot", table: "Home")))
            }
    }
    
    // 댓글 멘션 변환
    private func convertComment(comment: String) -> String {
        var convertedText = comment
        
        let pattern = "@([가-힣a-zA-Z0-9_]+)"
        
        guard let commentedUsersToId = currentState.commentedUsersToId,
              let regex = try? NSRegularExpression(pattern: pattern) else {
            return comment
        }
        
        let matches = regex.matches(in: comment, range: NSRange(comment.startIndex..., in: comment))
        
        for match in matches.reversed() {
            guard let nicknameRange = Range(match.range(at: 1), in: comment),
                  let matchRange = Range(match.range, in: convertedText) else {
                continue
            }
            
            let nickname = String(comment[nicknameRange])
            
            if let userId = commentedUsersToId[nickname] {
                convertedText.replaceSubrange(matchRange, with: "<mention:id-\(userId)>")
            }
        }
                
        return convertedText
    }
}

