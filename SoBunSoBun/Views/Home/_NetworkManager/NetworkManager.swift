//
//  NetworkManager.swift
//  SoBunSoBun
//
//  Created by 김태은 on 2/6/26.
//

import Foundation
import Moya
import RxMoya
import RxSwift

class HomeNetworkManager {
    private let provider = MoyaProvider<MultiTarget>(session: Session(interceptor: AuthInterceptor.shared), plugins: [MoyaLoggingPlugin()])
    
    // MARK: - 피드
    
    // MARK: - 검색
    
    // MARK: - 게시글 상세
    // 게시글 상세 정보 불러오기
    func getPost(id: Int) -> Single<PostModel> {
        return provider.rx.request(
            MultiTarget(HomeAPIs.getPost(id: id))
        )
        .filterSuccessfulStatusCodes()
        .map(PostModel.self)
    }
    
    // 게시글 저장 유무 불러오기
    func checkPostSaved(id: Int) -> Single<Bool> {
        return provider.rx.request(
            MultiTarget(HomeAPIs.checkPostSaved(id: id))
        )
        .filterSuccessfulStatusCodes()
        .map(Bool.self)
    }
    
    // 게시글 댓글 개수 불러오기
    func getPostCommentsCount(id: Int) -> Single<CommentCountModel> {
        return provider.rx.request(
            MultiTarget(HomeAPIs.getPostCommentsCount(id: id))
        )
        .filterSuccessfulStatusCodes()
        .map(CommentCountModel.self)
    }
    
    // 게시글 댓글 불러오기
    func getPostComments(id: Int) -> Single<[CommentModel]> {
        return provider.rx.request(
            MultiTarget(HomeAPIs.getPostComments(id: id))
        )
        .filterSuccessfulStatusCodes()
        .map([CommentModel].self)
    }
    
    // 게시글 저장
    func savePost(id: Int) -> Single<Void> {
        return provider.rx.request(
            MultiTarget(HomeAPIs.savePost(id: id))
        )
        .filterSuccessfulStatusCodes()
        .map { _ in () }
    }
    
    // 게시글 저장 취소
    func cancelSavePost(id: Int) -> Single<Void> {
        return provider.rx.request(
            MultiTarget(HomeAPIs.cancelSavePost(id: id))
        )
        .filterSuccessfulStatusCodes()
        .map { _ in () }
    }
    
    // 게시글 신고
    func reportPost(id: Int) -> Single<Void> {
        return provider.rx.request(
            MultiTarget(HomeAPIs.reportPost(id: id))
        )
        .filterSuccessfulStatusCodes()
        .map { _ in () }
    }
    
    // 게시글 삭제
    func deletePost(id: Int) -> Single<Void> {
        return provider.rx.request(
            MultiTarget(HomeAPIs.deletePost(id: id))
        )
        .filterSuccessfulStatusCodes()
        .map { _ in () }
    }
    
    // 댓글 생성
    func createPostComment(postId: Int, content: String) -> Single<Void> {
        return provider.rx.request(
            MultiTarget(HomeAPIs.createPostComment(postId: postId, content: content))
        )
        .filterSuccessfulStatusCodes()
        .map { _ in () }
    }
    
    // 댓글 수정
    func patchPostComment(id: Int, content: String) -> Single<Void> {
        return provider.rx.request(
            MultiTarget(HomeAPIs.patchPostComment(id: id, content: content))
        )
        .filterSuccessfulStatusCodes()
        .map { _ in () }
    }
    
    // 댓글 삭제
    func deletePostComment(id: Int) -> Single<Void> {
        return provider.rx.request(
            MultiTarget(HomeAPIs.deletePostComment(id: id))
        )
        .filterSuccessfulStatusCodes()
        .map { _ in () }
    }
    
    // 댓글 신고
    func reportPostComment(id: Int) -> Single<Void> {
        return provider.rx.request(
            MultiTarget(HomeAPIs.reportPostComment(id: id))
        )
        .filterSuccessfulStatusCodes()
        .map { _ in () }
    }
}
