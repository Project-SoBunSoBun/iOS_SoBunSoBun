//
//  HomeNetworkManager.swift
//  SoBunHaeYo
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
        let request: Single<Response> = authProvider.rx.request(MultiTarget(HomeAPIs.getLocationVerification))
        
        return request.tryMap(LocationVerificationModel.self)
    }
    
    // 좌표를 통해 주소 변환
    func getAddressFromGeocoder(longitude: Double, latitude: Double) -> Single<GeocoderResponseModel> {
        let point: String = "\(longitude),\(latitude)"
        let request: Single<Response> = provider.rx.request(MultiTarget(HomeAPIs.getAddress(point: point)))
        
        return request.tryMap(GeocoderResponseModel.self)
    }
    
    // 사용자 위치 인증
    func patchLocationVerification(address: String) -> Single<LocationVerificationModel> {
        let request: Single<Response> = authProvider.rx.request(MultiTarget(HomeAPIs.patchLocationVerification(address: address)))
        
        return request.tryMap(LocationVerificationModel.self)
    }
    
    // 홈 게시글 목록 불러오기
    func getHomeList(sortBy: String, page: Int, size: Int) -> Single<PostListResponseModel> {
        let request: Single<Response> = authProvider.rx.request(MultiTarget(HomeAPIs.getHomeList(sortBy: sortBy, page: page, size: size)))
        
        return request.tryMap(PostListResponseModel.self)
    }
    
    // 카테고리 선택 후 홈 게시글 목록 불러오기
    func getHomeListByCategories(categories: [String], sortBy: String, page: Int, size: Int) -> Single<PostListResponseModel> {
        let request: Single<Response> = authProvider.rx.request(MultiTarget(HomeAPIs.getHomeListByCategories(category: categories, sortBy: sortBy, page: page, size: size)))
        
        return request.tryMap(PostListResponseModel.self)
    }
    
    // 글 등록
    func registerPost(model: RegisterPostBodyModel) -> Single<PostModel> {
        let request: Single<Response> = authProvider.rx.request(MultiTarget(HomeAPIs.registerPost(model: model)))
        
        return request.tryMap(PostModel.self)
    }
    
    // MARK: - 검색
    // 검색 결과 불러오기
    func getSearchList(keyword: String, sortBy: String, page: Int, size: Int) -> Single<PostListResponseModel> {
        let request: Single<Response> = authProvider.rx.request(MultiTarget(HomeAPIs.getSearchList(keyword: keyword, sortBy: sortBy, page: page, size: size)))
        
        return request.tryMap(PostListResponseModel.self)
    }
    
    // MARK: - 게시글 상세
    // 게시글 상세 정보 불러오기
    func getPost(id: Int) -> Single<PostModel> {
        let request: Single<Response> = authProvider.rx.request(MultiTarget(HomeAPIs.getPost(id: id)))
        
        return request.tryMap(PostModel.self)
    }
    
    // 게시글 저장 유무 불러오기
    func checkPostSaved(id: Int) -> Single<Bool> {
        let request: Single<Response> = authProvider.rx.request(MultiTarget(HomeAPIs.checkPostSaved(id: id)))
        
        return request.tryMap(Bool.self)
    }
    
    // 게시글 댓글 개수 불러오기
    func getPostCommentsCount(id: Int) -> Single<CommentCountModel> {
        let request: Single<Response> = authProvider.rx.request(MultiTarget(HomeAPIs.getPostCommentsCount(id: id)))
        
        return request.tryMap(CommentCountModel.self)
    }
    
    // 게시글 댓글 불러오기
    func getPostComments(id: Int) -> Single<[CommentModel]> {
        let request: Single<Response> = authProvider.rx.request(MultiTarget(HomeAPIs.getPostComments(id: id)))
        
        return request.tryMap([CommentModel].self)
    }
    
    // 게시글 저장
    func savePost(id: Int) -> Single<PlainResponseModel> {
        let request: Single<Response> = authProvider.rx.request(MultiTarget(HomeAPIs.savePost(id: id)))
        
        return request.tryMap(PlainResponseModel.self)
    }
    
    // 게시글 저장 취소
    func cancelSavePost(id: Int) -> Single<PlainResponseModel> {
        let request: Single<Response> = authProvider.rx.request(MultiTarget(HomeAPIs.cancelSavePost(id: id)))
        
        return request.tryMap(PlainResponseModel.self)
    }
    
    // 게시글 삭제
    func deletePost(id: Int) -> Single<PlainResponseModel> {
        let request: Single<Response> = authProvider.rx.request(MultiTarget(HomeAPIs.deletePost(id: id)))
        
        return request.tryMap(PlainResponseModel.self)
    }
    
    // 댓글 생성
    func createPostComment(postId: Int, content: String) -> Single<PlainResponseModel> {
        let request: Single<Response> = authProvider.rx.request(MultiTarget(HomeAPIs.createPostComment(postId: postId, content: content)))
        
        return request.tryMap(PlainResponseModel.self)
    }
    
    // 댓글 수정
    func patchPostComment(id: Int, content: String) -> Single<PlainResponseModel> {
        let request: Single<Response> = authProvider.rx.request(MultiTarget(HomeAPIs.patchPostComment(id: id, content: content)))
        
        return request.tryMap(PlainResponseModel.self)
    }
    
    // 댓글 삭제
    func deletePostComment(id: Int) -> Single<PlainResponseModel> {
        let request: Single<Response> = authProvider.rx.request(MultiTarget(HomeAPIs.deletePostComment(id: id)))
        
        return request.tryMap(PlainResponseModel.self)
    }
    
    // 채팅방 id 조회
    func createChatRoomId(userId: Int, groupPostId: Int) -> Single<CreateChatRoomResponseModel> {
        let request: Single<Response> = authProvider.rx.request(MultiTarget(HomeAPIs.createChatRoomId(userId: userId, groupPostId: groupPostId)))
        
        return request.tryMap(CreateChatRoomResponseModel.self)
    }
    
    // MARK: - 내 프로필
    func getMyProfile(tab: String, page: Int, size: Int) -> Single<MyProfileResponseModel> {
        let request: Single<Response> = authProvider.rx.request(MultiTarget(HomeAPIs.getMyProfile(tab: tab, page: page, size: size)))
        
        return request.tryMap(MyProfileResponseModel.self)
    }
}
