//
//  PostDetailReactor.swift
//  SoBunHaeYo
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
        subsystem: "SoBunHaeYo",
        category: "Home.PostDetail.Reactor"
    )
    
    private let disposeBag = DisposeBag()
    private let homeNetworkManager = HomeNetworkManager()
    private let notificationNetworkManager = NotificationNetworkManager()
    
    private let errorMessage: String = String(localized: "ErrorMessage", table: "Error")
    
    let initialState: State = State()
    
    enum Action {
        // 알림 읽음
        case readNotification(Int)
        
        case viewDidLoad
        case refresh
        
        // 게시글 작성 후 성공화면
        case showRegisterSuccessView
        
        // 상단 네비게이션 바
        case shareButtonTapped
        case saveButtonTapped
        case menuButtonTapped(Bool)
        case deletePostButtonTapped
        case deletePost
        
        // 댓글
        case commentMenuButtonTapped(Bool)
        
        case createComment(String)
        
        case setSelectedCommentModel(CommentModel)
        
        case replyButtonTapped(String)
        
        case editButtonTapped
        case editCommentTapped(String)
        case editCancelTapped
        
        case deleteCommentButtonTapped
        case deleteComment
        
        // 채팅
        case chatButtonTapped
        
        // 신고
        case reportPostButtonTapped
        case reportCommentButtonTapped
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
        case setShouldShowDeletePostAlert
        case setShouldShowDeletePostDoneAlert
        
        case setIsCommentMenuOpen(Bool)
        
        case setSelectedCommentModel(CommentModel)
        
        case setTextViewText(String)
        
        case setIsEditMode(Bool)
        
        case setShouldShowDeleteCommentAlert
        case setShouldShowDeleteCommentDoneAlert
        
        case setShouldNavigateToChat(Int)
        
        case setRefreshing(Bool)
        
        case setShowRegisterSuccessView
        
        case setShouldPushReportPostView
        case setShouldPushReportPostCommentView
        
        case setErrorMessage(String)
    }
    
    struct State {
        var postInfo: PostModel?
        var postCommentsCount: CommentCountModel?
        var comments: [CommentModel] = []
        
        var commentedUsersToNickname: [String: String] = [:]
        var commentedUsersToId: [String: Int] = [:]
        
        var isSaved: Bool = false
        var isMenuOpen: Bool = false
        
        var selectedCommentModel: CommentModel?
        var isEditMode: Bool = false
        
        @Pulse var textViewText: String = ""
        
        @Pulse var shouldShowShare: Void?
        
        @Pulse var shouldShowDeletePostAlert: Void?
        @Pulse var shouldShowDeletePostDoneAlert: Void?
        
        var isCommentMenuOpen: Bool = false
        
        @Pulse var shouldShowDeleteCommentAlert: Void?
        @Pulse var shouldShowDeleteCommentDoneAlert: Void?
        
        @Pulse var shouldNavigateToChat: Int?
        
        var isRefreshing: Bool = false
        
        @Pulse var shouldShowRegisterSuccessView: Void?
        
        @Pulse var shouldPushReportPostView: Void?
        @Pulse var shouldPushReportPostCommentView: Void?
        
        @Pulse var errorMessage: String?
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .readNotification(let id):
            return readNotification(id: id)
            
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
            
        case .showRegisterSuccessView:
            return Observable.just(.setShowRegisterSuccessView)
            
        case .shareButtonTapped:
            return Observable.just(.setShouldShowShare)
            
        case .saveButtonTapped:
            let isSaved: Bool = currentState.isSaved
            
            return isSaved ? cancelSavePost() : savePost()
            
        case .menuButtonTapped(let isMenuOpen):
            return Observable.just(.setIsMenuOpen(isMenuOpen))
            
        case .commentMenuButtonTapped(let isMenuOpen):
            return Observable.just(.setIsCommentMenuOpen(isMenuOpen))
            
        case .deletePostButtonTapped:
            return Observable.just(.setShouldShowDeletePostAlert)
            
        case .deletePost:
            return deletePost()
            
        case .createComment(let content):
            return Observable.concat([
                createComment(content: content),
                getPostCommentsCount()
            ])
            
        case .setSelectedCommentModel(let model):
            return Observable.just(.setSelectedCommentModel(model))
            
        case .replyButtonTapped(let string):
            return Observable.concat([
                Observable.just(.setIsEditMode(false)),
                Observable.just(.setTextViewText(string))
            ])
            
        case .editButtonTapped:
            return Observable.just(.setIsEditMode(true))
            
        case .editCommentTapped(let content):
            return Observable.concat([
                getPostCommentsCount(),
                patchComment(content: content)
            ])
            
        case .editCancelTapped:
            return Observable.just(.setIsEditMode(false))
            
        case .deleteCommentButtonTapped:
            return Observable.concat([
                Observable.just(.setIsEditMode(false)),
                Observable.just(.setShouldShowDeleteCommentAlert)
            ])
            
        case .deleteComment:
            return Observable.concat([
                getPostCommentsCount(),
                deleteComment()
            ])
            
        case .chatButtonTapped:
            return Observable.concat([
                Observable.just(.setIsEditMode(false)),
                createChatRoom()
            ])
            
        case .reportPostButtonTapped:
            return Observable.just(.setShouldPushReportPostView)
            
        case .reportCommentButtonTapped:
            return Observable.just(.setShouldPushReportPostCommentView)
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
            
        case .setShouldShowDeletePostAlert:
            newState.shouldShowDeletePostAlert = ()
            
        case .setShouldShowDeletePostDoneAlert:
            newState.shouldShowDeletePostDoneAlert = ()
            
        case .setIsCommentMenuOpen(let isMenuOpen):
            newState.isCommentMenuOpen = isMenuOpen
            
        case .setSelectedCommentModel(let model):
            newState.selectedCommentModel = model
            
        case .setIsEditMode(let isEnabled):
            newState.isEditMode = isEnabled
            
        case .setTextViewText(let string):
            newState.textViewText = string
            
        case .setShouldShowDeleteCommentAlert:
            newState.shouldShowDeleteCommentAlert = ()
            
        case .setShouldShowDeleteCommentDoneAlert:
            newState.shouldShowDeleteCommentDoneAlert = ()
            
        case .setShouldNavigateToChat(let chatRoomId):
            newState.shouldNavigateToChat = chatRoomId
            
        case .setRefreshing(let isRefreshing):
            newState.isRefreshing = isRefreshing
            
        case .setShowRegisterSuccessView:
            newState.shouldShowRegisterSuccessView = ()
            
        case .setShouldPushReportPostView:
            newState.shouldPushReportPostView = ()
            
        case .setShouldPushReportPostCommentView:
            newState.shouldPushReportPostCommentView = ()
            
        case .setErrorMessage(let message):
            newState.errorMessage = message
        }
        
        return newState
    }
    
    private func readNotification(id: Int) -> Observable<Mutation> {
        return notificationNetworkManager.readNotification(id: id)
            .asObservable()
            .flatMap{ [weak self] response -> Observable<Mutation> in
                guard let self else { return Observable.empty() }
                
                if response.success {
                    self.logger.debug("알림 읽음 완료")
                } else {
                    if let errorCode = response.errorCode {
                        self.logger.critical("알림 읽음 실패(\(errorCode)) - \(response.message ?? "")")
                    } else {
                        self.logger.critical("알림 읽음 실패: \(response.message ?? "")")
                    }
                }
                
                return Observable.empty()
            }
            .catch { [weak self] error in
                guard let self else { return Observable.empty() }
                
                self.logger.critical("알림 읽음 실패: \(error.localizedDescription)")
                
                return Observable.empty()
            }
    }
    
    // 게시글 정보 불러오기
    private func getPost() -> Observable<Mutation> {
        return homeNetworkManager.getPost(id: postId)
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
        return homeNetworkManager.checkPostSaved(id: postId)
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
        return homeNetworkManager.getPostCommentsCount(id: postId)
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
        return homeNetworkManager.getPostComments(id: postId)
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
                
                return Observable.deferred {
                    Observable.concat([
                        Observable.just(.setComments(models)),
                        Observable.just(.setCommentedUsersToNickname(commentedUsersToNickname)),
                        Observable.just(.setCommentedUsersToId(commentedUsersToId))
                    ])
                }
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
        return homeNetworkManager.savePost(id: postId)
            .asObservable()
            .flatMap { [weak self] response -> Observable<Mutation> in
                guard let self else { return Observable.empty() }
                
                if response.success {
                    self.logger.debug("게시글 저장 성공")
                    
                    return Observable.just(.setIsSaved(true))
                } else {
                    if let errorCode = response.errorCode {
                        self.logger.critical("게시글 저장 실패(\(errorCode)) - \(response.message ?? "")")
                        
                        return Observable.just(.setErrorMessage(localizedErrorMessage(errorCode)))
                    } else {
                        self.logger.critical("게시글 저장 실패: \(response.message ?? "")")
                        
                        return Observable.just(.setErrorMessage(localizedErrorMessage(nil)))
                    }
                }
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
        return homeNetworkManager.cancelSavePost(id: postId)
            .asObservable()
            .flatMap { [weak self] response -> Observable<Mutation> in
                guard let self else { return Observable.empty() }
                
                if response.success {
                    self.logger.debug("게시글 저장 취소 성공")
                    
                    return Observable.just(.setIsSaved(false))
                } else {
                    if let errorCode = response.errorCode {
                        self.logger.critical("게시글 저장 취소 실패(\(errorCode)) - \(response.message ?? "")")
                        
                        return Observable.just(.setErrorMessage(localizedErrorMessage(errorCode)))
                    } else {
                        self.logger.critical("게시글 저장 취소 실패: \(response.message ?? "")")
                        
                        return Observable.just(.setErrorMessage(localizedErrorMessage(nil)))
                    }
                }
            }
            .catch { [weak self] error in
                guard let self = self else {
                    return Observable.just(.setErrorMessage("Error!"))
                }
                
                logger.critical("게시글 저장 취소 실패: \(error.localizedDescription)")
                return Observable.just(.setErrorMessage(errorMessage))
            }
    }
    
    // 게시글 삭제
    private func deletePost() -> Observable<Mutation> {
        return homeNetworkManager.deletePost(id: postId)
            .asObservable()
            .flatMap { [weak self] response -> Observable<Mutation> in
                guard let self else { return Observable.empty() }
                
                if response.success {
                    self.logger.debug("게시글 삭제 성공")
                    
                    return Observable.just(.setShouldShowDeletePostDoneAlert)
                } else {
                    if let errorCode = response.errorCode {
                        self.logger.critical("게시글 삭제 실패(\(errorCode)) - \(response.message ?? "")")
                        
                        return Observable.just(.setErrorMessage(localizedErrorMessage(errorCode)))
                    } else {
                        self.logger.critical("게시글 삭제 실패: \(response.message ?? "")")
                        
                        return Observable.just(.setErrorMessage(localizedErrorMessage(nil)))
                    }
                }
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
        
        return homeNetworkManager.createPostComment(postId: postId, content: convertedComment)
            .asObservable()
            .flatMap { [weak self] response -> Observable<Mutation> in
                guard let self = self else { return Observable.empty() }
                
                if response.success {
                    self.logger.debug("댓글 생성 성공")
                    
                    return getComments()
                } else {
                    if let errorCode = response.errorCode {
                        self.logger.critical("댓글 생성 실패(\(errorCode)) - \(response.message ?? "")")
                        
                        return Observable.just(.setErrorMessage(localizedErrorMessage(errorCode)))
                    } else {
                        self.logger.critical("댓글 생성 실패: \(response.message ?? "")")
                        
                        return Observable.just(.setErrorMessage(localizedErrorMessage(nil)))
                    }
                }
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
        guard let commentModel = currentState.selectedCommentModel else {
            return Observable.just(.setErrorMessage(errorMessage))
        }
        
        let cleanedContent = content.limitNewLines(limit: 2).trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !cleanedContent.isEmpty else {
            return Observable.just(.setErrorMessage(String(localized: "CheckYourInputs", table: "Common")))
        }
        
        let convertedComment = convertComment(comment: cleanedContent)
        
        return homeNetworkManager.patchPostComment(id: commentModel.id, content: convertedComment)
            .asObservable()
            .flatMap { [weak self] response -> Observable<Mutation> in
                guard let self = self else { return Observable.empty() }
                
                if response.success {
                    self.logger.debug("댓글 수정 성공")
                    
                    return Observable.concat([
                        getComments(),
                        Observable.just(.setIsEditMode(false))
                    ])
                } else {
                    if let errorCode = response.errorCode {
                        self.logger.critical("댓글 수정 실패(\(errorCode)) - \(response.message ?? "")")
                        
                        return Observable.just(.setErrorMessage(localizedErrorMessage(errorCode)))
                    } else {
                        self.logger.critical("댓글 수정 실패: \(response.message ?? "")")
                        
                        return Observable.just(.setErrorMessage(localizedErrorMessage(nil)))
                    }
                }
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
        guard let commentModel = currentState.selectedCommentModel else {
            return Observable.empty()
        }
        
        return homeNetworkManager.deletePostComment(id: commentModel.id)
            .asObservable()
            .flatMap { [weak self] response -> Observable<Mutation> in
                guard let self = self else { return Observable.empty() }
                
                if response.success {
                    self.logger.debug("댓글 삭제 성공")
                    
                    return Observable.concat([
                        getPostCommentsCount(),
                        getComments(),
                        Observable.just(.setShouldShowDeleteCommentDoneAlert)
                    ])
                } else {
                    if let errorCode = response.errorCode {
                        self.logger.critical("댓글 삭제 실패(\(errorCode)) - \(response.message ?? "")")
                        
                        return Observable.just(.setErrorMessage(localizedErrorMessage(errorCode)))
                    } else {
                        self.logger.critical("댓글 삭제 실패: \(response.message ?? "")")
                        
                        return Observable.just(.setErrorMessage(localizedErrorMessage(nil)))
                    }
                }
            }
            .catch { [weak self] error in
                guard let self = self else {
                    return Observable.just(.setErrorMessage("Error!"))
                }
                
                logger.critical("댓글 삭제 실패: \(error.localizedDescription)")
                return Observable.just(.setErrorMessage(errorMessage))
            }
    }
    
    // 댓글 멘션 변환
    private func convertComment(comment: String) -> String {
        var convertedText = comment
        
        let commentedUsersToId = currentState.commentedUsersToId
        
        guard !commentedUsersToId.isEmpty else {
            return comment
        }
        
        // 긴 닉네임 우선
        let sortedNicknames = commentedUsersToId.keys.sorted { $0.count > $1.count }
        // 텍스트 중 닉네임들을 or 연산자 |로 join하여 찾음
        let nicknamePattern = sortedNicknames.map { NSRegularExpression.escapedPattern(for: $0) }.joined(separator: "|")
        let pattern = "@(\(nicknamePattern))"
        
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
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
    
    // 채팅방 조회
    private func createChatRoom() -> Observable<Mutation> {
        guard let ownerId = currentState.postInfo?.owner.id else {
            return Observable.just(.setErrorMessage(errorMessage))
        }
        
        return homeNetworkManager.createChatRoomId(userId: ownerId, groupPostId: postId)
            .asObservable()
            .flatMap { [weak self] response -> Observable<Mutation> in
                guard let self else { return Observable.empty() }
                
                if response.success, let data = response.data {
                    self.logger.debug("채팅방 생성 및 조회 성공")
                    
                    return Observable.just(.setShouldNavigateToChat(data.roomId))
                } else {
                    if let errorCode = response.errorCode {
                        self.logger.critical("채팅방 생성 및 조회 실패(\(errorCode)) - \(response.message ?? "")")
                        
                        return Observable.just(.setErrorMessage(localizedErrorMessage(errorCode)))
                    } else {
                        self.logger.critical("채팅방 생성 및 조회 실패: \(response.message ?? "")")
                        
                        return Observable.just(.setErrorMessage(localizedErrorMessage(nil)))
                    }
                }
            }
            .catch { [weak self] error in
                guard let self = self else { return Observable.empty() }
                
                self.logger.critical("채팅방 생성 및 조회 실패: \(error.localizedDescription)")
                let errorMessage = String(format: String(localized: "ErrorMessageWithReason", table: "Error"), error.localizedDescription)
                
                return Observable.just(.setErrorMessage(errorMessage))
            }
    }
}

