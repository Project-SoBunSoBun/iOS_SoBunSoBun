//
//  ChatNetworkManager.swift
//  SoBunHaeYo
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
        let request: Single<Response> = authProvider.rx.request(MultiTarget(ChatAPIs.getChatRoomDetail(id: id)))
        
        return request.tryMap(ChatRoomDetailModel.self)
    }
    
    func getChatHistory(id: Int, cursor: String?, size: Int) -> Single<ChatMessageHistoryModel> {
        let request: Single<Response> = authProvider.rx.request(MultiTarget(ChatAPIs.getChatHistory(id: id, cursor: cursor, size: size)))
        
        return request.tryMap(ChatMessageHistoryModel.self)
    }
    
    func sendText(id: Int, message: String) -> Single<PlainResponseModel> {
        let request: Single<Response> = authProvider.rx.request(MultiTarget(ChatAPIs.sendText(id: id, message: message)))
        
        return request.tryMap(PlainResponseModel.self)
    }
    
    func sendChatImage(id: Int, message: String?, image: Data) -> Single<PlainResponseModel> {
        let request: Single<Response> = authProvider.rx.request(MultiTarget(ChatAPIs.sendChatImage(id: id, message: message, image: image)))
        
        return request.tryMap(PlainResponseModel.self)
    }
    
    func sendInviteCard(chatRoomId: Int, inviteeId: Int) -> Single<PlainResponseModel> {
        let request: Single<Response> = authProvider.rx.request(MultiTarget(ChatAPIs.sendInviteCard(chatRoomId: chatRoomId, inviteeId: inviteeId)))
        
        return request.tryMap(PlainResponseModel.self)
    }
    
    func acceptInvitation(inviteId: Int) -> Single<GroupChatAcceptResponseModel> {
        let request: Single<Response> = authProvider.rx.request(MultiTarget(ChatAPIs.acceptInvitation(inviteId: inviteId)))
        
        return request.tryMap(GroupChatAcceptResponseModel.self)
    }
    
    func sendSettlementCard(chatRoomId: Int, settlementId: Int) -> Single<PlainResponseModel> {
        let request: Single<Response> = authProvider.rx.request(MultiTarget(ChatAPIs.sendSettlementCard(chatRoomId: chatRoomId, settlementId: settlementId)))
        
        return request.tryMap(PlainResponseModel.self)
    }
    
    func leaveChatRoom(id: Int) -> Single<PlainResponseModel> {
        let request: Single<Response> = authProvider.rx.request(MultiTarget(ChatAPIs.leaveChatRoom(id: id)))
        
        return request.tryMap(PlainResponseModel.self)
    }
    
    func kickMember(chatRoomId: Int, userId: Int) -> Single<PlainResponseModel> {
        let request: Single<Response> = authProvider.rx.request(MultiTarget(ChatAPIs.kickMember(chatRoomId: chatRoomId, userId: userId)))
        
        return request.tryMap(PlainResponseModel.self)
    }
    
    func rateManners(groupPostId: Int, manners: [Int: [String]]) -> Single<PlainResponseModel> {
        let request: Single<Response> = authProvider.rx.request(MultiTarget(ChatAPIs.rateManners(groupPostId: groupPostId, manners: manners)))
        
        return request.tryMap(PlainResponseModel.self)
    }
}
