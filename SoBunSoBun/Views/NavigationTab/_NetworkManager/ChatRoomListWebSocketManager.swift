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
        guard let myIdString = KeyChain.shared.get(key: "USER_ID") else {
            return
        }
        
        swiftStomp?.subscribe(to: "/sub/users/\(myIdString)/chat-rooms")
        
        logger.debug("채팅방 목록 구독: /sub/users/\(myIdString)/chat-rooms")
    }
    
    func disconnect() {
        swiftStomp?.disconnect()
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
        logger.debug("재연결 시작")
        disconnect()
        connect()
    }
}

extension ChatRoomListWebSocketManager: SwiftStompDelegate {
    func onConnect(swiftStomp: SwiftStomp, connectType: StompConnectType) {
        switch connectType {
        case .toSocketEndpoint:
            logger.debug("Socket에서 연결 성공")
        case .toStomp:
            logger.debug("Stomp에서 연결 성공")
        }
        
        subscribe()
    }
    
    func onDisconnect(swiftStomp: SwiftStomp, disconnectType: StompDisconnectType) {
        switch disconnectType {
        case .fromSocket:
            logger.error("Socket에서 연결 끊김")
        case .fromStomp:
            logger.error("Stomp에서 연결 끊김")
        }
    }
    
    func onMessageReceived(swiftStomp: SwiftStomp, message: Any?, messageId: String, destination: String, headers: [String : String]) {
        logger.debug("메시지 수신\ndestination: \(destination)\nmessageId: \(messageId)")
        
        guard let messageString = message as? String,
              let data = messageString.data(using: .utf8) else {
            logger.fault("메시지를 String, Data로 변환 중 실패")
            return
        }
        
        do {
            let decoder = JSONDecoder()
            
            let model = try decoder.decode(ChatRoomListResponseDataModel.self, from: data)
            didReceiveChatRoom.accept(model)
        } catch {
            logger.fault("ChatRoomListResponseDataModel 디코딩 실패: \(error.localizedDescription)")
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
