//
//  ChatWebSocketManager.swift
//  SoBunSoBun
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
        subsystem: "SoBunSoBun",
        category: "Chat.ChatWebSocketManager"
    )
    
    let didReceiveMessage = PublishRelay<ChatMessageModel>()
    let didReceiveSettlement = PublishRelay<Void?>()
    let didReceiveError = PublishRelay<Void?>()
    
    private var isWaitingForRefreshToken: Bool = false
    private var subscribeUrl: String = ""
    
    private let disposeBag = DisposeBag()
    
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
        
        logger.debug("\(self.currentChatRoomId ?? -1)번 채팅방 Websocket 구독: \(self.subscribeUrl)")
    }
    
    func sendMessage(message: String) {
        guard let currentChatRoomId else { return }
        
        let model = ChatSendMessageModel(roomId: currentChatRoomId, type: .TEXT, content: message)
        
        swiftStomp?.send(body: model, to: "/app/chat/send")
        logger.debug("메시지 전송")
    }
    
    func read(lastMessageId: String) {
        guard let currentChatRoomId else { return }
        
        let model = ChatReadMessageModel(roomId: currentChatRoomId, lastReadMessageId: lastMessageId)
        
        swiftStomp?.send(body: model, to: "/app/chat/read")
        logger.debug("메시지 읽음")
    }
    
    func disconnect() {
        swiftStomp?.disconnect()
        logger.debug("\(self.currentChatRoomId ?? -1)번 채팅방 Websocket 연결 종료")
    }
    
    private func waitForRefreshAndReconnect() {
        guard !isWaitingForRefreshToken else { return }
        
        isWaitingForRefreshToken = true
        
        AuthInterceptor.shared.didFinishRefreshing
            .take(1)
            .timeout(.seconds(10), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                
                self.isWaitingForRefreshToken = false
                self.logger.debug("리프레시 토큰 갱신 완료, \(self.currentChatRoomId ?? -1)번 채팅방 웹소켓 재연결")
                self.reconnect()
            }, onError: { [weak self] _ in
                guard let self else { return }
                
                self.isWaitingForRefreshToken = false
                self.logger.fault("리프페시 토큰 갱신 대기 타임아웃, \(self.currentChatRoomId ?? -1)번 채팅방 웹소켓 재연결 중단")
            })
            .disposed(by: disposeBag)
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
}

extension ChatWebSocketManager: SwiftStompDelegate {
    func onConnect(swiftStomp: SwiftStomp, connectType: StompConnectType) {
        switch connectType {
        case .toSocketEndpoint:
            logger.debug("\(self.currentChatRoomId ?? -1)번 채팅방 Socket 연결 성공")
            
        case .toStomp:
            logger.debug("\(self.currentChatRoomId ?? -1)번 채팅방 Stomp 연결 성공")
        }
        
        if let currentChatRoomId {
            subscribe(chatRoomId: currentChatRoomId)
        }
    }
    
    func onDisconnect(swiftStomp: SwiftStomp, disconnectType: StompDisconnectType) {
        switch disconnectType {
        case .fromSocket:
            logger.error("\(self.currentChatRoomId ?? -1)번 채팅방 Socket에서 연결 끊김")
            
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
        if AuthInterceptor.shared.isRefreshing {
            logger.debug("리프레시 토큰 갱신 대기 중, \(self.currentChatRoomId ?? -1)번 채팅방 웹소켓 재연결 예정")
            waitForRefreshAndReconnect()
        } else {
            if !isWaitingForRefreshToken {
                logger.debug("\(self.currentChatRoomId ?? -1)번 채팅방 웹소켓 재연결 시도")
                didReceiveError.accept(())
                reconnect()
            } else {
                logger.fault("\(self.currentChatRoomId ?? -1)번 채팅방 웹소켓 재연결 시도 후 다시 오류 발생, 재시도 중단")
            }
        }
    }
}
