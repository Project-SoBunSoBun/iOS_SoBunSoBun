//
//  ChatNetworkManager.swift
//  SoBunSoBun
//
//  Created by 김태은 on 2/24/26.
//

import Foundation
import Moya
import RxMoya
import RxSwift

class ChatNetworkManager {
    private let authProvider = MoyaProvider<MultiTarget>(session: Session(interceptor: AuthInterceptor.shared), plugins: [MoyaLoggingPlugin()])
    
    func getChatRoomDetail(id: Int) -> Single<ChatRoomDetailModel> {
        return authProvider.rx.request(
            MultiTarget(ChatAPIs.getChatRoomDetail(id: id))
        )
        .filterSuccessfulStatusCodes()
        .map(ChatRoomDetailModel.self)
    }
    
    func getChatHistory(id: Int, cursor: String?, size: Int) -> Single<ChatMessageHistoryModel> {
        return authProvider.rx.request(
            MultiTarget(ChatAPIs.getChatHistory(id: id, cursor: cursor, size: size))
        )
        .filterSuccessfulStatusCodes()
        .map(ChatMessageHistoryModel.self)
    }
    
    func uploadChatImage(id: Int, message: String?, image: Data) -> Single<Void> {
        return authProvider.rx.request(
            MultiTarget(ChatAPIs.uploadChatImage(id: id, message: message, image: image))
        )
        .filterSuccessfulStatusCodes()
        .map { _ in () }
    }
    
    func leaveChatRoom(id: Int) -> Single<Void> {
        return authProvider.rx.request(
            MultiTarget(ChatAPIs.leaveChatRoom(id: id))
        )
        .filterSuccessfulStatusCodes()
        .map { _ in () }
    }
    
    func kickMember(chatRoomId: Int, userId: Int) -> Single<Void> {
        return authProvider.rx.request(
            MultiTarget(ChatAPIs.kickMember(chatRoomId: chatRoomId, userId: userId))
        )
        .filterSuccessfulStatusCodes()
        .map { _ in () }
    }
    
    func rateManners(groupPostId: Int, manners: [Int: [String]]) -> Single<Void> {
        return authProvider.rx.request(
            MultiTarget(ChatAPIs.rateManners(groupPostId: groupPostId, manners: manners))
        )
        .filterSuccessfulStatusCodes()
        .map { _ in () }
    }
}
