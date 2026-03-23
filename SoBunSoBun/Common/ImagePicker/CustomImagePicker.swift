//
//  ProfileImagePicker.swift
//  SoBunSoBun
//
//  Created by 허성필 on 2/3/26.
//

import Foundation
import Photos
import PhotosUI
import UIKit
import OSLog
import RxSwift
import RxCocoa

class CustomImagePicker: NSObject {
    private let logger = Logger(
        subsystem: "SoBunSoBun",
        category: "ProfileImagePicker"
    )
    
    weak var presentingViewController: UIViewController?
    private let selectionMode: SelectionMode
    
    let imageSelected = PublishSubject<UIImage>()
    let imagesSelected = PublishSubject<[UIImage]>()
    let cancelled = PublishSubject<Void>()
    
    var allowEditing: Bool = true
    
    enum SelectionMode {
        case single
        case multi(limit: Int)
    }
    
    // .single .multi // limit: Int
    init(presentingViewController: UIViewController, selectionMode: SelectionMode = .single) {
        self.presentingViewController = presentingViewController
        self.selectionMode = selectionMode
        
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
        
        switch selectionMode {
        case .single:
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.mediaTypes = ["public.image"]
            picker.allowsEditing = allowEditing
            picker.delegate = self
            picker.presentationController?.delegate = self
            
            viewController.present(picker, animated: true)
            
        case .multi(let limit):
            var config = PHPickerConfiguration()
            config.selectionLimit = limit
            config.filter = .images
            
            let picker = PHPickerViewController(configuration: config)
            picker.delegate = self
            
            viewController.present(picker, animated: true)
        }
    }
    
    // 권한 요청이 없을 때 설정으로 이동시키는 알러트
    private func showPermissionAlert() {
        guard let viewController = presentingViewController else { return }
        
        let alertView = CustomAlertView(
            title: String(localized: "GalleryPermissionMessage", table: "SignIn"),
            primaryTitleKey: String(localized: "GoToSetting", table: "Common")
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

// 단일 선택 피커뷰
extension CustomImagePicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAdaptivePresentationControllerDelegate {
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
        
        showImagePickerConfirmView(image: image)
    }
    
    private func showImagePickerConfirmView(image: UIImage) {
        guard let viewController = presentingViewController else { return }
        
        let vc = ImagePickerConfirmView(image: image)
        
        vc.onConfirm
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                
                imageSelected.onNext(image)
                
            })
            .disposed(by: vc.disposeBag)
        
        viewController.present(vc, animated: true)
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

// 다중 선택 피커뷰
extension CustomImagePicker: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        // 취소 처리
        if results.isEmpty {
            cancelled.onNext(())
            
            return
        }
        
        var selectedImages: [UIImage] = []
        let group = DispatchGroup()
        
        var hasLargeImage = false
        
        for result in results {
            group.enter()
            let itemProvider = result.itemProvider
            
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                    defer { group.leave() }
                    
                    guard let self = self, let image = image as? UIImage else { return }
                    
                    // 이미지 크기 체크 (5MB 제한)
                    if let imageData = image.jpegData(compressionQuality: 0.8) {
                        let imageSizeInMB = Double(imageData.count) / (1024.0 * 1024.0)
                        self.logger.debug("이미지 사이즈: \(imageSizeInMB) MB")
                        
                        if imageSizeInMB > 5.0 {
                            hasLargeImage = true
                            
                            return
                        }
                    }
                    
                    selectedImages.append(image)
                }
            } else {
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            
            if hasLargeImage {
                self.showImageSizeAlert()
            }
            
            self.imagesSelected.onNext(selectedImages)
        }
    }
}
