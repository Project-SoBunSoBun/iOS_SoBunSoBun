//
//  ChatRoomListWebSocketManager.swift
//  SoBunHaeYo
//
//  Created by 김태은 on 3/10/26.
//

import Foundation
import SwiftStomp
import UIKit
import RxSwift
import RxCocoa
import OSLog

class ChatRoomListWebSocketManager {
    private var swiftStomp: SwiftStomp?
    private let WEBSOCKET_URL: String = Bundle.main.object(forInfoDictionaryKey: "WEBSOCKET_URL") as! String
    
    private let logger = Logger(
        subsystem: "SoBunHaeYo",
        category: "NavigationTab.ChatRoomListWebSocketManager"
    )
    
    let didReceiveChatRoom = PublishRelay<ChatRoomListResponseDataModel>()
    
    private var isWaitingForRefreshToken: Bool = false
    private var subscribeUrl: String = ""
    
    private var isReconnecting: Bool = false
    private var reconnectAttempts: Int = 0
    private let maxReconnectAttempts: Int = 10
    
    // 예약된 재연결 작업 - cancel()로 취소 가능
    private var reconnectWorkItem: DispatchWorkItem?
    
    private let disposeBag = DisposeBag()
    
    func connect() {
        guard let accessToken = KeyChain.shared.get(key: "ACCESS_TOKEN") else {
            logger.error("액세스 토큰 오류")
            
            return
        }
        
        // 이전 인스턴스의 stale 콜백 방지
        swiftStomp?.delegate = nil
        
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
        swiftStomp?.delegate = nil
        swiftStomp?.disconnect()
        reconnectWorkItem?.cancel()
        logger.debug("채팅방 목록 Websocket 연결 종료")
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
                self.logger.debug("리프레시 토큰 갱신 완료, 채팅방 목록 웹소켓 재연결")
                self.reconnect()
            }, onError: { [weak self] _ in
                guard let self else { return }
                
                self.isWaitingForRefreshToken = false
                self.logger.fault("리프레시 토큰 갱신 대기 타임아웃, 채팅방 목록 웹소켓 재연결 중단")
            })
            .disposed(by: disposeBag)
    }
    
    // STOMP 인증 실패 시 토큰을 직접 갱신한 후 재연결
    private func refreshTokenAndReconnect() {
        guard !isWaitingForRefreshToken else { return }
        isWaitingForRefreshToken = true
        
        logger.debug("채팅방 목록 STOMP 인증 실패 감지, 토큰 갱신 후 재연결 시도")
        
        AuthInterceptor.shared.refreshAccessToken { [weak self] isSuccess in
            guard let self else { return }
            self.isWaitingForRefreshToken = false
            
            if isSuccess {
                self.logger.debug("채팅방 목록 토큰 갱신 성공, 웹소켓 재연결")
                self.reconnect()
            } else {
                self.logger.fault("채팅방 목록 토큰 갱신 실패, 재연결 중단")
            }
        }
    }
    
    private func reconnect() {
        logger.debug("채팅방 목록 Websocket 재연결 시작")
        disconnect()
        connect()
    }
    
    private func scheduleReconnect() {
        guard !isReconnecting else {
            logger.fault("채팅방 목록 이미 재연결 대기 중, 추가 재연결 무시")
            
            return
        }
        
        guard reconnectAttempts < maxReconnectAttempts else {
            logger.fault("채팅방 목록 최대 재연결 시도 횟수(\(self.maxReconnectAttempts)) 초과. 재연결 중단")
            
            return
        }
        
        isReconnecting = true
        reconnectAttempts += 1
        
        logger.debug("채팅방 목록 2초 후 재연결 시도 (시도 \(self.reconnectAttempts)/\(self.maxReconnectAttempts))")
        
        reconnectWorkItem?.cancel()
        
        let workItem = DispatchWorkItem { [weak self] in
            guard let self else { return }
            
            self.isReconnecting = false
            self.reconnect()
        }
        
        reconnectWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: workItem)
    }
}

extension ChatRoomListWebSocketManager: SwiftStompDelegate {
    func onConnect(swiftStomp: SwiftStomp, connectType: StompConnectType) {
        switch connectType {
        case .toSocketEndpoint:
            logger.debug("채팅방 목록 Socket 연결 성공")
            
        case .toStomp:
            logger.debug("채팅방 목록 Stomp 연결 성공")
            
            // 재연결 플래그 및 시도 횟수 초기화
            isReconnecting = false
            reconnectAttempts = 0
            
            // STOMP 연결 완료 시에만 구독 (Socket + STOMP 이중 구독 방지)
            subscribe()
        }
    }
    
    func onDisconnect(swiftStomp: SwiftStomp, disconnectType: StompDisconnectType) {
        switch disconnectType {
        case .fromSocket:
            logger.error("채팅방 목록 Socket에서 연결 끊김")
            
            // onError 없이 소켓이 끊긴 경우(서버가 ERROR 프레임 없이 연결 종료)를 대비한 재연결
            if !isReconnecting && !isWaitingForRefreshToken {
                scheduleReconnect()
            }
            
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
        
        // Error handler
        // Spring의 ExecutorSubscribableChannel 오류는 STOMP 인증 실패(만료 토큰)를 의미
        let isAuthError = briefDescription.contains("ExecutorSubscribableChannel")
        
        if isAuthError && !AuthInterceptor.shared.isRefreshing && !isWaitingForRefreshToken {
            logger.debug("채팅방 목록 STOMP 인증 실패 감지, 토큰 갱신 시도")
            refreshTokenAndReconnect()
        } else if AuthInterceptor.shared.isRefreshing {
            logger.debug("리프레시 토큰 갱신 대기 중, 채팅방 목록 웹소켓 재연결 예정")
            waitForRefreshAndReconnect()
        } else if !isWaitingForRefreshToken {
            scheduleReconnect()
        }
    }
}
