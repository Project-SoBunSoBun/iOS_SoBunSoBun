//
//  ChatDataBaseManager.swift
//  SoBunSoBun
//
//  Created by 김태은 on 2/22/26.
//

import Foundation
import GRDB
import OSLog

class ChatDataBaseManager {
    private var dbQueue: DatabaseQueue!
    private let logger = Logger(subsystem: "SoBunSoBun", category: "ChatDatabase")
    
    init() {
        setup()
    }
    
    private func setup() {
        do {
            // Library/Application Support
            let folder = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let dbPath = folder.appendingPathComponent("chat.db").path
            
            dbQueue = try DatabaseQueue(path: dbPath)
            try createTable()
            
            logger.debug("DB init 성공: \(dbPath)")
        } catch {
            logger.fault("DB init 실패: \(error.localizedDescription)")
        }
    }
    
    private func createTable() throws {
        try dbQueue.write { db in
            try db.create(table: "messages", ifNotExists: true) { t in
                t.column("id", .text).notNull().primaryKey()
                t.column("roomId", .integer).notNull()
                t.column("userId", .integer).notNull()
                t.column("nickname", .text)
                t.column("profileImage", .text)
                t.column("type", .text).notNull()
                t.column("content", .text)
                t.column("imageUrl", .text)
                t.column("createdAt", .text).notNull()
                t.column("settlementId", .integer)
                t.column("inviteId", .integer)
            }
            
            try db.create(index: "messages_roomId_createdAt", on: "messages", columns: ["roomId", "createdAt"], ifNotExists: true)
        }
    }
    
    func getMessages(roomId: Int, beforeCreatedAt: String?, limit: Int) -> [ChatMessageModel] {
        do {
            return try dbQueue.read { db in
                try ChatMessageModel
                    .filter(
                        beforeCreatedAt != nil ?
                        Column("roomId") == roomId && Column("createdAt") < beforeCreatedAt :
                        Column("roomId") == roomId
                    )
                    .order(Column("createdAt").desc)
                    .limit(limit)
                    .fetchAll(db)
            }
        } catch {
            logger.fault("메시지 조회 실패: \(error.localizedDescription)")
            return []
        }
    }
    
    func insertMessage(_ message: ChatMessageModel) {
        do {
            try dbQueue.write { db in
                try message.upsert(db)
            }
            logger.debug("메시지 ID \(message.id) SQLite 저장 성공: \(message.id)")
        } catch {
            logger.fault("메시지 ID \(message.id) SQLite 저장 실패: \(error.localizedDescription)")
        }
    }
    
    func insertMessages(_ messages: [ChatMessageModel]) {
        do {
            try dbQueue.write { db in
                for message in messages {
                    try message.upsert(db)
                }
            }
            logger.debug("메시지 \(messages.count)개 저장 성공")
        } catch {
            logger.fault("메시지 \(messages.count)개 저장 실패: \(error.localizedDescription)")
        }
    }
    
    func deleteMessages(roomId: Int) {
        do {
            _ = try dbQueue.write { db in
                try ChatMessageModel
                    .filter(Column("roomId") == roomId)
                    .deleteAll(db)
            }
            logger.debug("채팅방 \(roomId)의 모든 메시지 삭제 성공")
        } catch {
            logger.fault("채팅방 \(roomId)의 모든 메시지 삭제 실패")
        }
    }
}

