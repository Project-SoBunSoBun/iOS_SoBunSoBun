//
//  ChatWebSocketManager.swift
//  SoBunSoBun
//
//  Created by 김태은 on 2/21/26.
//

import Foundation
import SwiftStomp
import UIKit
import RxCocoa
import OSLog

class ChatWebSocketManager {
    private var swiftStomp: SwiftStomp?
    private let WEBSOCKET_URL: String = Bundle.main.object(forInfoDictionaryKey: "WEBSOCKET_URL") as! String
    private var currentChatRoomId: Int?
    private var isRefreshing: Bool = false
    
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "ChatWebSocketManager"
    )
    
    let didReceiveMessage = PublishRelay<ChatMessageModel>()
    let didReceiveSettlement = PublishRelay<Void?>()
    
    private var subscribeUrl: String = ""
    
    func connect(chatRoomId: Int) {
        guard let accessToken = KeyChain.shared.get(key: "ACCESS_TOKEN") else {
            logger.error("액세스 토큰 오류")
            return
        }
        
        currentChatRoomId = chatRoomId
        
        swiftStomp = SwiftStomp(host: URL(string: WEBSOCKET_URL)!, headers: ["Authorization": "Bearer \(accessToken)"])
        swiftStomp?.delegate = self
        swiftStomp?.connect()
    }
    
    func subscribe(chatRoomId: Int) {
        subscribeUrl = "/topic/chat/room/\(chatRoomId)"
        swiftStomp?.subscribe(to: subscribeUrl)
        
        logger.debug("채팅방 구독: \(self.subscribeUrl)")
    }
    
    func sendMessage(message: String) {
        guard let currentChatRoomId else { return }
        
        let model = ChatSendMessageModel(roomId: currentChatRoomId, type: .TEXT, content: message)
        
        swiftStomp?.send(body: model, to: "/app/chat/send")
        logger.debug("메시지 전송")
    }
    
    func disconnect() {
        swiftStomp?.disconnect()
        currentChatRoomId = nil
        logger.debug("연결 종료")
    }
    
    private func handleUnauthorized() {
        guard !isRefreshing else {
            logger.debug("이미 토큰 갱신 중")
            return
        }
        
        isRefreshing = true
        logger.debug("401 에러 감지 - 토큰 갱신 시작")
        
        AuthInterceptor.shared.refreshAccessToken { [weak self] isSuccess in
            guard let self = self else { return }
            
            self.isRefreshing = false
            
            if isSuccess, let newToken = KeyChain.shared.get(key: "ACCESS_TOKEN") {
                self.reconnect(token: newToken)
            } else {
                AuthManager.shared.logout()
            }
        }
    }
    
    private func reconnect(token: String) {
        guard let chatRoomId = currentChatRoomId else {
            logger.fault("currentChatRoomId가 없어 재연결을 할 수 없습니다.")
            return
        }
        
        logger.debug("재연결 시작")
        disconnect()
        connect(chatRoomId: chatRoomId)
    }
}

extension ChatWebSocketManager: SwiftStompDelegate {
    func onConnect(swiftStomp: SwiftStomp, connectType: StompConnectType) {
        logger.debug("STOMP 연결 성공")
        
        if let currentChatRoomId {
            subscribe(chatRoomId: currentChatRoomId)
        }
    }
    
    func onDisconnect(swiftStomp: SwiftStomp, disconnectType: StompDisconnectType) {
        switch disconnectType {
        case .fromSocket:
            logger.error("Socket에서 연결 끊김")
        case .fromStomp:
            logger.error("Stomp에서 구독 \(self.subscribeUrl) 끊김")
        }
    }
    
    func onMessageReceived(swiftStomp: SwiftStomp, message: Any?, messageId: String, destination: String, headers: [String : String]) {
        logger.debug("메시지 수신\ndestination: \(destination)\nmessageId: \(messageId)")
        
        guard let messageString = message as? String else {
            logger.fault("메시지를 String으로 변환 중 실패")
            return
        }
        
        guard let data = messageString.data(using: .utf8) else {
            logger.fault("\(destination) 메시지를 Data로 변환 중 실패: \(messageString)")
            return
        }
        
        do {
            logger.debug("\(destination) 수신 내용: \(messageString)")
            
            let decoder = JSONDecoder()
            
            let model = try decoder.decode(ChatMessageModel.self, from: data)
            didReceiveMessage.accept(model)
            
            if model.type == .SETTLEMENT_CARD {
                didReceiveSettlement.accept(())
            }
        } catch {
            logger.fault("ChatMessageModel 디코딩 실패: \(error.localizedDescription)")
        }
    }
    
    func onReceipt(swiftStomp: SwiftStomp, receiptId: String) {
        logger.debug("수신 확인: \(receiptId)")
    }
    
    func onError(swiftStomp: SwiftStomp, briefDescription: String, fullDescription: String?, receiptId: String?, type: StompErrorType) {
        switch type {
        case .fromSocket:
            logger.fault("Socket 오류(\(String(describing: receiptId))): \(briefDescription) | \(String(describing: fullDescription))")
        case .fromStomp:
            logger.critical("Stomp 오류(\(String(describing: receiptId))): \(briefDescription) | \(String(describing: fullDescription))")
        }
        
        if fullDescription?.contains("401") == true ||
            fullDescription?.contains("Unauthorized") == true {
            handleUnauthorized()
        }
    }
}
