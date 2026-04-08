//
//  ChatWebSocketManager.swift
//  SoBunHaeYo
//
//  Created by 김태은 on 2/21/26.
//

import Foundation
import SwiftStomp
import UIKit
import RxSwift
import RxCocoa
import OSLog

class ChatWebSocketManager {
    private var swiftStomp: SwiftStomp?
    private let WEBSOCKET_URL: String = Bundle.main.object(forInfoDictionaryKey: "WEBSOCKET_URL") as! String
    private var currentChatRoomId: Int?
    
    private let logger = Logger(
        subsystem: "SoBunHaeYo",
        category: "Chat.ChatWebSocketManager"
    )
    
    let didReceiveMessage = PublishRelay<ChatMessageModel>()
    let didReceiveSettlement = PublishRelay<Void?>()
    let didReceiveError = PublishRelay<Void?>()
    
    private var isWaitingForRefreshToken: Bool = false
    private var subscribeUrl: String = ""
    
    private var isReconnecting: Bool = false
    private var reconnectAttempts: Int = 0
    private let maxReconnectAttempts: Int = 10
    
    // 예약된 재연결 작업 - cancel()로 취소 가능
    private var reconnectWorkItem: DispatchWorkItem?
    
    private let disposeBag = DisposeBag()
    
    func connect(chatRoomId: Int) {
        guard let accessToken = KeyChain.shared.get(key: "ACCESS_TOKEN") else {
            logger.error("액세스 토큰 오류")
            
            return
        }
        
        currentChatRoomId = chatRoomId
        
        // 이전 인스턴스의 stale 콜백 방지
        swiftStomp?.delegate = nil
        
        swiftStomp = SwiftStomp(host: URL(string: WEBSOCKET_URL)!, headers: ["Authorization": "Bearer \(accessToken)"])
        swiftStomp?.delegate = self
        swiftStomp?.connect()
    }
    
    func subscribe(chatRoomId: Int) {
        subscribeUrl = "/topic/chat/room/\(chatRoomId)"
        swiftStomp?.subscribe(to: subscribeUrl)
        
        logger.debug("\(self.currentChatRoomId ?? -1)번 채팅방 Websocket 구독: \(self.subscribeUrl)")
    }
    
    func read(lastMessageId: String) {
        guard let currentChatRoomId = currentChatRoomId else { return }
        
        let model = ChatReadMessageModel(roomId: currentChatRoomId, lastReadMessageId: lastMessageId)
        
        swiftStomp?.send(body: model, to: "/app/chat/read")
        
        logger.debug("메시지 읽음")
    }
    
    func disconnect() {
        swiftStomp?.delegate = nil
        swiftStomp?.disconnect()
        reconnectWorkItem?.cancel()
        
        logger.debug("\(self.currentChatRoomId ?? -1)번 채팅방 Websocket 연결 종료")
    }
    
    // STOMP 인증 실패 시 토큰을 직접 갱신한 후 재연결
    private func refreshTokenAndReconnect() {
        guard !isWaitingForRefreshToken else { return }
        
        isWaitingForRefreshToken = true
        
        logger.debug("\(self.currentChatRoomId ?? -1)번 채팅방 STOMP 인증 실패 감지, 토큰 갱신 후 재연결 시도")
        
        AuthInterceptor.shared.refreshAccessToken { [weak self] isSuccess in
            guard let self = self else { return }
            
            self.isWaitingForRefreshToken = false
            
            if isSuccess {
                self.logger.debug("\(self.currentChatRoomId ?? -1)번 채팅방 토큰 갱신 성공, 웹소켓 재연결")
                
                self.reconnect()
            } else {
                self.logger.fault("\(self.currentChatRoomId ?? -1)번 채팅방 토큰 갱신 실패, 재연결 중단")
            }
        }
    }
    
    // HTTP 레이어에서 이미 리프레시가 진행 중인 경우 완료될 때까지 대기 후 재연결
    private func waitForRefreshAndReconnect() {
        guard !isWaitingForRefreshToken else { return }
        
        isWaitingForRefreshToken = true
        
        logger.debug("리프레시 토큰 갱신 대기 중, \(self.currentChatRoomId ?? -1)번 채팅방 웹소켓 재연결 예정")
        
        AuthInterceptor.shared.refreshAccessToken { [weak self] isSuccess in
            guard let self = self else { return }
            
            self.isWaitingForRefreshToken = false
            
            if isSuccess {
                self.logger.debug("리프레시 토큰 갱신 완료, \(self.currentChatRoomId ?? -1)번 채팅방 웹소켓 재연결")
                
                self.reconnect()
            } else {
                self.logger.fault("리프레시 토큰 갱신 실패, \(self.currentChatRoomId ?? -1)번 채팅방 웹소켓 재연결 중단")
            }
        }
    }
    
    private func reconnect() {
        guard let chatRoomId = currentChatRoomId else {
            logger.fault("currentChatRoomId가 없어 재연결을 할 수 없습니다.")
            
            return
        }
        
        logger.debug("\(self.currentChatRoomId ?? -1)번 채팅방 Websocket 재연결 시작")
        
        disconnect()
        connect(chatRoomId: chatRoomId)
    }
    
    private func scheduleReconnect() {
        guard !isReconnecting else {
            logger.fault("\(self.currentChatRoomId ?? -1)번 채팅방 이미 재연결 대기 중, 추가 재연결 무시")
            
            return
        }
        
        guard reconnectAttempts < maxReconnectAttempts else {
            logger.fault("\(self.currentChatRoomId ?? -1)번 채팅방 최대 재연결 시도 횟수(\(self.maxReconnectAttempts)) 초과. 재연결 중단")
            
            return
        }
        
        isReconnecting = true
        reconnectAttempts += 1
        
        logger.debug("\(self.currentChatRoomId ?? -1)번 채팅방 2초 후 재연결 시도 (시도 \(self.reconnectAttempts)/\(self.maxReconnectAttempts))")
        
        reconnectWorkItem?.cancel()
        
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            
            self.isReconnecting = false
            self.reconnect()
        }
        
        reconnectWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: workItem)
    }
}

extension ChatWebSocketManager: SwiftStompDelegate {
    func onConnect(swiftStomp: SwiftStomp, connectType: StompConnectType) {
        switch connectType {
        case .toSocketEndpoint:
            logger.debug("\(self.currentChatRoomId ?? -1)번 채팅방 Socket 연결 성공")
            
        case .toStomp:
            logger.debug("\(self.currentChatRoomId ?? -1)번 채팅방 Stomp 연결 성공")
            
            // 재연결 플래그 및 시도 횟수 초기화
            isReconnecting = false
            reconnectAttempts = 0
            
            // STOMP 연결 완료 시에만 구독 (Socket + STOMP 이중 구독 방지)
            if let currentChatRoomId {
                subscribe(chatRoomId: currentChatRoomId)
            }
        }
    }
    
    func onDisconnect(swiftStomp: SwiftStomp, disconnectType: StompDisconnectType) {
        switch disconnectType {
        case .fromSocket:
            logger.error("\(self.currentChatRoomId ?? -1)번 채팅방 Socket에서 연결 끊김")
            
            // onError 없이 소켓이 끊긴 경우(서버가 ERROR 프레임 없이 연결 종료)를 대비한 재연결
            if !isReconnecting && !isWaitingForRefreshToken {
                scheduleReconnect()
            }
            
        case .fromStomp:
            logger.error("\(self.currentChatRoomId ?? -1)번 채팅방 Stomp에서 구독 \(self.subscribeUrl) 끊김")
        }
    }
    
    func onMessageReceived(swiftStomp: SwiftStomp, message: Any?, messageId: String, destination: String, headers: [String : String]) {
        logger.debug("\(self.currentChatRoomId ?? -1)번 채팅방 메시지 수신]\n\ndestination: \(destination)\nmessageId: \(messageId)")
        
        guard let messageString = message as? String else {
            logger.fault("\(self.currentChatRoomId ?? -1)번 채팅방 Websocket 메시지를 String으로 변환 중 실패")
            
            return
        }
        
        guard let data = messageString.data(using: .utf8) else {
            logger.fault("Websocket \(destination) 메시지를 Data로 변환 중 실패: \(messageString)")
            
            return
        }
        
        do {
            logger.debug("Websocket \(destination) 수신 내용: \(messageString)")
            
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
        var log: String = "[\(self.currentChatRoomId ?? -1)번 채팅방 수신 확인]\n\n"
        log += "receiptId: \(String(describing: receiptId))"
        
        logger.debug("\(log)")
    }
    
    func onError(swiftStomp: SwiftStomp, briefDescription: String, fullDescription: String?, receiptId: String?, type: StompErrorType) {
        var log: String = ""
        
        switch type {
        case .fromSocket:
            log += "[\(self.currentChatRoomId ?? -1)번 채팅방 Socket 오류]\n\n"
            
        case .fromStomp:
            log += "[\(self.currentChatRoomId ?? -1)번 채팅방 Stomp 오류]\n\n"
        }
        
        log += "receiptId: \(String(describing: receiptId))\n"
        log += "briefDescription: \(briefDescription)\n"
        log += "fullDescription: \(String(describing: fullDescription))"
        
        logger.critical("\(log)")
        
        // Error handler
        // Spring의 ExecutorSubscribableChannel 오류는 STOMP 인증 실패(만료 토큰)를 의미
        let isAuthError = briefDescription.contains("ExecutorSubscribableChannel")
        
        if isAuthError && !AuthInterceptor.shared.isRefreshing && !isWaitingForRefreshToken {
            logger.debug("\(self.currentChatRoomId ?? -1)번 채팅방 STOMP 인증 실패 감지, 토큰 갱신 시도")
            
            refreshTokenAndReconnect()
        } else if isAuthError && AuthInterceptor.shared.isRefreshing {
            logger.debug("리프레시 토큰 갱신 대기 중, \(self.currentChatRoomId ?? -1)번 채팅방 웹소켓 재연결 예정")
            
            waitForRefreshAndReconnect()
        } else if !isWaitingForRefreshToken {
            didReceiveError.accept(())
            scheduleReconnect()
        }
    }
}
