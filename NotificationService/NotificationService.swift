//
//  NotificationService.swift
//  NotificationService
//
//  Created by 허성필 on 3/20/26.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        guard let bestAttemptContent else { return }
        
        let userInfo = request.content.userInfo
        print("푸시 수신 데이터: \(userInfo)")
        
        let type = userInfo["type"] as? String
        let nickname = userInfo["nickname"] as? String ?? ""
        
        switch type {
        case "COMMENT":
            bestAttemptContent.body = String(
                format: NSLocalizedString("COMMENT", tableName: "PushNotifications", bundle: .main, comment: ""),
                nickname
            )
            
        case "COMMENT_MENTIONED":
            bestAttemptContent.body = String(
                format: NSLocalizedString("COMMENT_MENTIONED", tableName: "PushNotifications", bundle: .main, comment: ""),
                nickname
            )
            
        case "PARTICIPATION":
            bestAttemptContent.body = String(
                format: NSLocalizedString("PARTICIPATION", tableName: "PushNotifications", bundle: .main, comment: ""),
                nickname
            )
            
        case "POST_UPDATE":
            bestAttemptContent.body = NSLocalizedString("POST_UPDATE", tableName: "PushNotifications", bundle: .main, comment: "")
            
        case "SETTLEMENT":
            bestAttemptContent.body = NSLocalizedString("SETTLEMENT", tableName: "PushNotifications", bundle: .main, comment: "")
            
        case "CHAT":
            let chatRoomName = userInfo["chatRoomName"] as? String ?? ""
            let content = userInfo["content"] as? String ?? ""
            let chatType = userInfo["chatType"] as? String
            
            bestAttemptContent.title = chatRoomName
            
            switch chatType {
            case "TEXT":
                bestAttemptContent.body = "\(nickname): \(content)"
                
            case "IMAGE":
                bestAttemptContent.body = "\(nickname): \(NSLocalizedString("imageCHAT", tableName: "PushNotifications", bundle: .main, comment: ""))"
                
            default:
                break
            }
            
        default:
            bestAttemptContent.body = NSLocalizedString("body", tableName: "PushNotifications", bundle: .main, comment: "")
        }
        
        contentHandler(bestAttemptContent)
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}
