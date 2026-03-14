//
//  ChatRoomListWebSocketManager.swift
//  SoBunSoBun
//
//  Created by 김태은 on 3/10/26.
//

import Foundation
import SwiftStomp
import UIKit
import RxCocoa
import OSLog

class ChatRoomListWebSocketManager {
    private var swiftStomp: SwiftStomp?
    private let WEBSOCKET_URL: String = Bundle.main.object(forInfoDictionaryKey: "WEBSOCKET_URL") as! String
    private var isRefreshing: Bool = false
    
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "ChatRoomListWebSocketManager"
    )
    
    let didReceiveChatRoom = PublishRelay<ChatRoomListResponseDataModel>()
    
    private var tryCount: Int = 0
    private var subscribeUrl: String = ""
    
    func connect() {
        guard let accessToken = KeyChain.shared.get(key: "ACCESS_TOKEN") else {
            logger.error("액세스 토큰 오류")
            
            return
        }
        
        swiftStomp = SwiftStomp(host: URL(string: WEBSOCKET_URL)!, headers: ["Authorization": "Bearer \(accessToken)"])
        swiftStomp?.delegate = self
        swiftStomp?.connect()
    }
    
    func subscribe() {
        guard let myIdString = KeyChain.shared.get(key: "USER_ID") else { return }
        
        subscribeUrl = "/sub/users/\(myIdString)/chat-rooms"
        swiftStomp?.subscribe(to: subscribeUrl)
        
        logger.debug("채팅방 목록 Websocket 구독: \(self.subscribeUrl)")
    }
    
    func disconnect() {
        swiftStomp?.disconnect()
        logger.debug("채팅방 목록 Websocket 연결 종료")
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
        tryCount = 0
        logger.debug("채팅방 목록 WebSocket 재연결 시작")
        disconnect()
        connect()
    }
}

extension ChatRoomListWebSocketManager: SwiftStompDelegate {
    func onConnect(swiftStomp: SwiftStomp, connectType: StompConnectType) {
        switch connectType {
        case .toSocketEndpoint:
            logger.debug("채팅방 목록 Socket 연결 성공")
            
        case .toStomp:
            logger.debug("채팅방 목록 Stomp 연결 성공")
        }
        
        subscribe()
    }
    
    func onDisconnect(swiftStomp: SwiftStomp, disconnectType: StompDisconnectType) {
        switch disconnectType {
        case .fromSocket:
            logger.error("채팅방 목록 Socket에서 연결 끊김")
            
        case .fromStomp:
            logger.error("채팅방 목록 Stomp에서 구독 \(self.subscribeUrl) 끊김")
        }
    }
    
    func onMessageReceived(swiftStomp: SwiftStomp, message: Any?, messageId: String, destination: String, headers: [String : String]) {
        logger.debug("[채팅방 목록 메시지 수신]\n\ndestination: \(destination)\nmessageId: \(messageId)")
        
        guard let messageString = message as? String else {
            logger.fault("채팅방 목록 Websocket 메시지를 String으로 변환 중 실패")
            
            return
        }
        
        guard let data = messageString.data(using: .utf8) else {
            logger.fault("Websocket \(destination) 메시지를 Data로 변환 중 실패: \(messageString)")
            
            return
        }
        
        do {
            logger.debug("Websocket \(destination) 수신 내용: \(messageString)")
            
            let decoder = JSONDecoder()
            
            let model = try decoder.decode(ChatRoomListResponseDataModel.self, from: data)
            didReceiveChatRoom.accept(model)
        } catch {
            logger.fault("ChatRoomListResponseDataModel 디코딩 실패: \(error.localizedDescription)")
        }
    }
    
    func onReceipt(swiftStomp: SwiftStomp, receiptId: String) {
        var log: String = "[채팅방 목록 수신 확인]\n\n"
        log += "receiptId: \(String(describing: receiptId))"
        
        logger.debug("\(log)")
    }
    
    func onError(swiftStomp: SwiftStomp, briefDescription: String, fullDescription: String?, receiptId: String?, type: StompErrorType) {
        var log: String = ""
        
        switch type {
        case .fromSocket:
            log += "[채팅방 목록 Socket 오류]\n\n"
            
        case .fromStomp:
            log += "[채팅방 목록 Stomp 오류]\n\n"
        }
        
        log += "receiptId: \(String(describing: receiptId))\n"
        log += "briefDescription: \(briefDescription)\n"
        log += "fullDescription: \(String(describing: fullDescription))"
        
        logger.critical("\(log)")
        
        if tryCount < 2 {
            tryCount += 1
            handleUnauthorized()
        } else {
            logger.fault("채팅방 목록 Websocket 연결 재시도 3회 실패")
        }
    }
}
