//
//  Utils.swift
//  SoBunSoBun
//
//  Created by 허성필 on 9/5/25.
//

import Foundation
import UIKit

// 미리보기
#if DEBUG
import SwiftUI

struct UIViewControllerPreview: UIViewControllerRepresentable {
    let viewController: () -> UIViewController
    
    init(_ viewController: @escaping () -> UIViewController) {
        self.viewController = viewController
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        return viewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
#endif
