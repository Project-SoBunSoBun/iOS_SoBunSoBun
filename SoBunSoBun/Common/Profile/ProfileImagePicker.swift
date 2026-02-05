//
//  ProfileImagePicker.swift
//  SoBunSoBun
//
//  Created by 허성필 on 2/3/26.
//

import Foundation
import Photos
import UIKit
import OSLog
import RxSwift
import RxCocoa

class ProfileImagePicker: NSObject {
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "ProfileImagePicker"
    )
    
    weak var presentingViewController: UIViewController?
    
    let imageSelected = PublishSubject<UIImage>()
    let cancelled = PublishSubject<Void>()
    
    init(presentingViewController: UIViewController) {
        self.presentingViewController = presentingViewController
        super.init()
    }
    
    // 사진 권한을 확인하는 함수
    func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch status {
        case .authorized, .limited:
            presentImagePicker()
            
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] newStatus in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    if newStatus == .authorized || newStatus == .limited {
                        self.presentImagePicker()
                    }
                }
            }
            
        case .denied, .restricted:
            showPermissionAlert()
            
        default:
            break
        }
    }
    
    // 사용자가 사진을 선택할 수 있도록 하는 함수
    private func presentImagePicker() {
        guard let viewController = presentingViewController else { return }
        
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = self
        picker.presentationController?.delegate = self
        
        viewController.present(picker, animated: true)
    }
    
    // 권한 요청이 없을 때 설정으로 이동시키는 알러트
    private func showPermissionAlert() {
        guard let viewController = presentingViewController else { return }
        
        let alertView = CustomAlertView(
            title: String(localized: "GalleryPermissionMessage", table: "SignIn")
        )
        
        alertView.onPrimaryTapped = {
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        }
        
        alertView.onCancelTapped = { [weak self] in
            guard let self = self else { return }
            
            self.logger.debug("권한 요청 취소됨")
        }
        
        alertView.show(on: viewController)
    }
    
    // 이미지 크기 초과 알러트
    private func showImageSizeAlert() {
        guard let viewController = presentingViewController else { return }
        
        let alert = UIAlertController(
            title: String(localized: "ImageSizeExceeded", table: "Common"),
            message: String(localized: "SelectOnlyFilesUnder5MB", table: "Common"),
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(
            title: String(localized: "Confirm", table: "Common"),
            style: .default
        ))
        
        viewController.present(alert, animated: true)
    }
}

extension ProfileImagePicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAdaptivePresentationControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        picker.dismiss(animated: true)
        
        var selectedImage: UIImage?
        
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
        }
        
        guard let image = selectedImage else { return }
        
        // 이미지 크기 체크 (5MB 제한)
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            let imageSizeInMB = Double(imageData.count) / (1024.0 * 1024.0)
            logger.debug("이미지 사이즈: \(imageSizeInMB) MB")
            
            if imageSizeInMB > 5.0 {
                showImageSizeAlert()
                return
            }
        }
        
        imageSelected.onNext(image)
    }
    
    // 취소 버튼 눌렀을 때
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        
        cancelled.onNext(())
    }
    
    // 사용자가 스와이프로 이미지 선택을 취소했을 때
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        cancelled.onNext(())
    }
}
