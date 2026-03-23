//
//  HomeNetworkManager.swift
//  SoBunSoBun
//
//  Created by 김태은 on 2/6/26.
//

import Foundation
import Moya
import RxMoya
import RxSwift

class HomeNetworkManager {
    private let provider = MoyaProvider<MultiTarget>(plugins: [MoyaLoggingPlugin()])
    private let authProvider = MoyaProvider<MultiTarget>(session: Session(interceptor: AuthInterceptor.shared), plugins: [MoyaLoggingPlugin()])
    
    // MARK: - 피드
    // 현재 사용자 위치 인증 상태 조회
    func getLocationVefirication() -> Single<LocationVerificationModel> {
        return authProvider.rx.request(
            MultiTarget(HomeAPIs.getLocationVerification)
        )
        .tryMap(LocationVerificationModel.self)
    }
    
    // 좌표를 통해 주소 변환
    func getAddressFromGeocoder(longitude: Double, latitude: Double) -> Single<GeocoderResponseModel> {
        let point: String = "\(longitude),\(latitude)"
        
        return provider.rx.request(
            MultiTarget(HomeAPIs.getAddress(point: point))
        )
        .tryMap(GeocoderResponseModel.self)
    }
    
    // 사용자 위치 인증
    func patchLocationVerification(address: String) -> Single<LocationVerificationModel> {
        return authProvider.rx.request(
            MultiTarget(HomeAPIs.patchLocationVerification(address: address))
        )
        .tryMap(LocationVerificationModel.self)
    }
    
    // 홈 게시글 목록 불러오기
    func getHomeList(sortBy: String, page: Int, size: Int) -> Single<PostListResponseModel> {
        return authProvider.rx.request(
            MultiTarget(HomeAPIs.getHomeList(sortBy: sortBy, page: page, size: size))
        )
        .tryMap(PostListResponseModel.self)
    }
    
    // 카테고리 선택 후 홈 게시글 목록 불러오기
    func getHomeListByCategories(categories: [String], sortBy: String, page: Int, size: Int) -> Single<PostListResponseModel> {
        return authProvider.rx.request(
            MultiTarget(HomeAPIs.getHomeListByCategories(category: categories, sortBy: sortBy, page: page, size: size))
        )
        .tryMap(PostListResponseModel.self)
    }
    
    // 글 등록
    func registerPost(model: RegisterPostBodyModel) -> Single<PostModel> {
        return authProvider.rx.request(
            MultiTarget(HomeAPIs.registerPost(model: model))
        )
        .tryMap(PostModel.self)
    }
    
    // MARK: - 검색
    // 추천 검색어
    /*
    func getSuggestions() -> Single<SuggestionSearchKeywordsModel> {
        return authProvider.rx.request(
            MultiTarget(AuthorizedAPI.getSuggestions)
        )
        .map(SuggestionSearchKeywordsModel.self)
    }
    */
    
    // 검색 결과 불러오기
    func getSearchList(keyword: String, sortBy: String, page: Int, size: Int) -> Single<PostListResponseModel> {
        return authProvider.rx.request(
            MultiTarget(HomeAPIs.getSearchList(keyword: keyword, sortBy: sortBy, page: page, size: size))
        )
        .tryMap(PostListResponseModel.self)
    }
    
    // MARK: - 게시글 상세
    // 게시글 상세 정보 불러오기
    func getPost(id: Int) -> Single<PostModel> {
        return authProvider.rx.request(
            MultiTarget(HomeAPIs.getPost(id: id))
        )
        .tryMap(PostModel.self)
    }
    
    // 게시글 저장 유무 불러오기
    func checkPostSaved(id: Int) -> Single<Bool> {
        return authProvider.rx.request(
            MultiTarget(HomeAPIs.checkPostSaved(id: id))
        )
        .tryMap(Bool.self)
    }
    
    // 게시글 댓글 개수 불러오기
    func getPostCommentsCount(id: Int) -> Single<CommentCountModel> {
        return authProvider.rx.request(
            MultiTarget(HomeAPIs.getPostCommentsCount(id: id))
        )
        .tryMap(CommentCountModel.self)
    }
    
    // 게시글 댓글 불러오기
    func getPostComments(id: Int) -> Single<[CommentModel]> {
        return authProvider.rx.request(
            MultiTarget(HomeAPIs.getPostComments(id: id))
        )
        .tryMap([CommentModel].self)
    }
    
    // 게시글 저장
    func savePost(id: Int) -> Single<Void> {
        return authProvider.rx.request(
            MultiTarget(HomeAPIs.savePost(id: id))
        )
        .map { _ in () }
    }
    
    // 게시글 저장 취소
    func cancelSavePost(id: Int) -> Single<Void> {
        return authProvider.rx.request(
            MultiTarget(HomeAPIs.cancelSavePost(id: id))
        )
        .map { _ in () }
    }
    
    // 게시글 삭제
    func deletePost(id: Int) -> Single<Void> {
        return authProvider.rx.request(
            MultiTarget(HomeAPIs.deletePost(id: id))
        )
        .map { _ in () }
    }
    
    // 댓글 생성
    func createPostComment(postId: Int, content: String) -> Single<Void> {
        return authProvider.rx.request(
            MultiTarget(HomeAPIs.createPostComment(postId: postId, content: content))
        )
        .map { _ in () }
    }
    
    // 댓글 수정
    func patchPostComment(id: Int, content: String) -> Single<Void> {
        return authProvider.rx.request(
            MultiTarget(HomeAPIs.patchPostComment(id: id, content: content))
        )
        .map { _ in () }
    }
    
    // 댓글 삭제
    func deletePostComment(id: Int) -> Single<Void> {
        return authProvider.rx.request(
            MultiTarget(HomeAPIs.deletePostComment(id: id))
        )
        .map { _ in () }
    }
    
    // 채팅방 id 조회
    func createChatRoomId(userId: Int, groupPostId: Int) -> Single<CreateChatRoomResponseModel> {
        return authProvider.rx.request(
            MultiTarget(HomeAPIs.createChatRoomId(userId: userId, groupPostId: groupPostId))
        )
        .tryMap(CreateChatRoomResponseModel.self)
    }
    
    
    // MARK: - 내 프로필
    func getMyProfile(tab: String, page: Int, size: Int) -> Single<MyProfileResponseModel> {
        return authProvider.rx.request(
            MultiTarget(HomeAPIs.getMyProfile(tab: tab, page: page, size: size))
        )
        .tryMap(MyProfileResponseModel.self)
    }
    
    // MARK: - 알림
    func getUnreadNotificationCount() -> Single<UnreadNotificationCountResponseModel> {
        return authProvider.rx.request(
            MultiTarget(HomeAPIs.getUnreadNotificationCount)
        )
        .tryMap(UnreadNotificationCountResponseModel.self)
    }
    
    func getNotifications(page: Int, size: Int) -> Single<NotificationResponseModel> {
        return authProvider.rx.request(
            MultiTarget(HomeAPIs.getNotifications(page: page, size: size))
        )
        .tryMap(NotificationResponseModel.self)
    }
    
    func readNotification(id: Int) -> Single<PlainResponseModel> {
        return authProvider.rx.request(
            MultiTarget(HomeAPIs.readNotification(id: id))
        )
        .tryMap(PlainResponseModel.self)
    }
}
