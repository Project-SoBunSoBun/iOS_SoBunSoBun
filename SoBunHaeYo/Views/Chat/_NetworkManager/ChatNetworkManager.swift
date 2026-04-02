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
        return authProvider.rx.request(MultiTarget(ChatAPIs.getChatRoomDetail(id: id)))
            .tryMap(ChatRoomDetailModel.self)
    }
    
    func getChatHistory(id: Int, cursor: String?, size: Int) -> Single<ChatMessageHistoryModel> {
        return authProvider.rx.request(MultiTarget(ChatAPIs.getChatHistory(id: id, cursor: cursor, size: size)))
            .tryMap(ChatMessageHistoryModel.self)
    }
    
    func sendText(id: Int, message: String) -> Single<PlainResponseModel> {
        return authProvider.rx.request(MultiTarget(ChatAPIs.sendText(id: id, message: message)))
            .tryMap(PlainResponseModel.self)
    }
    
    func sendChatImage(id: Int, message: String?, image: Data) -> Single<PlainResponseModel> {
        return authProvider.rx.request(MultiTarget(ChatAPIs.sendChatImage(id: id, message: message, image: image)))
            .tryMap(PlainResponseModel.self)
    }
    
    func sendInviteCard(chatRoomId: Int, inviteeId: Int) -> Single<PlainResponseModel> {
        return authProvider.rx.request(MultiTarget(ChatAPIs.sendInviteCard(chatRoomId: chatRoomId, inviteeId: inviteeId)))
            .tryMap(PlainResponseModel.self)
    }
    
    func acceptInvitation(inviteId: Int) -> Single<GroupChatAcceptResponseModel> {
        return authProvider.rx.request(MultiTarget(ChatAPIs.acceptInvitation(inviteId: inviteId)))
            .tryMap(GroupChatAcceptResponseModel.self)
    }
    
    func sendSettlementCard(chatRoomId: Int, settlementId: Int) -> Single<PlainResponseModel> {
        return authProvider.rx.request(MultiTarget(ChatAPIs.sendSettlementCard(chatRoomId: chatRoomId, settlementId: settlementId)))
            .tryMap(PlainResponseModel.self)
    }
    
    func leaveChatRoom(id: Int) -> Single<PlainResponseModel> {
        return authProvider.rx.request(MultiTarget(ChatAPIs.leaveChatRoom(id: id)))
            .tryMap(PlainResponseModel.self)
    }
    
    func kickMember(chatRoomId: Int, userId: Int) -> Single<PlainResponseModel> {
        return authProvider.rx.request(MultiTarget(ChatAPIs.kickMember(chatRoomId: chatRoomId, userId: userId)))
            .tryMap(PlainResponseModel.self)
    }
    
    func rateManners(groupPostId: Int, manners: [Int: [String]]) -> Single<PlainResponseModel> {
        return authProvider.rx.request(MultiTarget(ChatAPIs.rateManners(groupPostId: groupPostId, manners: manners)))
            .tryMap(PlainResponseModel.self)
    }
}
