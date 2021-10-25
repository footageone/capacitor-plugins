import Foundation
import Capacitor
import Photos
import PhotosUI
import Logging

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitor.ionicframework.com/docs/plugins/ios
 */
@available(iOS 13, *)
@objc(PhotoLibraryPlugin)
public class PhotoLibraryPlugin: CAPPlugin {

    private var call: CAPPluginCall?
    var logger = Logger(label: "one.footage.PhotoLibraryPlugin")
    
    var mediaItems: PickedMediaItems = PickedMediaItems()

    private var settings = CameraSettings()

    @objc override public func checkPermissions(_ call: CAPPluginCall) {
        let state: String
        if #available(iOS 14, *) {
            state = PHPhotoLibrary.authorizationStatus(for: .readWrite).authorizationState
        } else {
            state = PHPhotoLibrary.authorizationStatus().authorizationState
        }
        call.resolve(["authorizationStatus": state])
    }

    @objc override public func requestPermissions(_ call: CAPPluginCall) {
        // request the permissions
        let group = DispatchGroup()
        if #available(iOS 14, *) {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { (_) in
                group.leave()
            }
        } else {
            PHPhotoLibrary.requestAuthorization({ (_) in
                group.leave()
            })
        }
        group.notify(queue: DispatchQueue.main) { [weak self] in
            self?.checkPermissions(call)
        }
    }

    @objc func openPhotoPicker(_ call: CAPPluginCall) {
        self.call = call
        
        if #available(iOS 14, *) {
            DispatchQueue.main.async {
                self.showPhotos()
            }
        } else {
            // Fallback on earlier versions
        };
        
    }
    
    @objc func test(_ call: CAPPluginCall) {
        call.resolve([
            "items": [
                [
                    "id": 1
                ],
                [
                    "id": 2
                ]
            ]
        ])
    }
}

@available(iOS 13, *)
extension PhotoLibraryPlugin: UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverPresentationControllerDelegate {
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        call?.reject("User cancelled photos app")
    }

    public func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        call?.reject("User cancelled photos app")
    }

    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        call?.reject("User cancelled photos app")
    }

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)
        call?.reject("Not implemented yet")
    }
}


@available(iOS 14, *)
extension PhotoLibraryPlugin: PHPickerViewControllerDelegate {
    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        logger.info("Result count: \(results.count)")
        
        guard !results.isEmpty else {
            logger.error("result empty")
            call?.reject("User cancelled photos app")
            return
        }
        processResult(results: results);
    }
}

@available(iOS 14, *)
private extension PhotoLibraryPlugin {
    
    func processResult(results: [PHPickerResult]) {

        let fetchOptions: PHFetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

        let ids: [String] = results.map {
            $0.assetIdentifier!
        };
            self.logger.info("ids \(ids)")
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: ids, options: fetchOptions);

        assets.enumerateObjects { asset, _, _ in
            self.mediaItems.append(item: PhotoPickerModel(with: asset))
        }

        self.call?.resolve(self.mediaItems.result());
        
    }

    func showPhotos() {
        // check for permission
        let authStatus = PHPhotoLibrary.authorizationStatus()
        if authStatus == .restricted || authStatus == .denied {
            call?.reject("User denied access to photos")
            return
        }
        // we either already have permission or can prompt
        if authStatus == .authorized || authStatus == .limited {
            self.presentPhotoPicker()
        } else {
            PHPhotoLibrary.requestAuthorization({ [weak self] (status) in
                if status == .authorized || status == .limited {
                    DispatchQueue.main.async { [weak self] in
                        self?.presentPhotoPicker()
                    }
                } else {
                    self?.call?.reject("User denied access to photos")
                }
            })
        }
    }

    func presentImagePicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = self.settings.allowEditing
        // select the input
        picker.sourceType = .photoLibrary
        // present
        picker.modalPresentationStyle = settings.presentationStyle
        if settings.presentationStyle == .popover {
            picker.popoverPresentationController?.delegate = self
            setCenteredPopover(picker)
        }
        bridge?.viewController?.present(picker, animated: true, completion: nil)
    }

    func presentPhotoPicker() {
        var configuration = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        configuration.selectionLimit = 0
        configuration.filter = .any(of: [.images,.livePhotos,.videos])
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        // present
        picker.modalPresentationStyle = settings.presentationStyle
        if settings.presentationStyle == .popover {
            picker.popoverPresentationController?.delegate = self
            setCenteredPopover(picker)
        }
        bridge?.viewController?.present(picker, animated: true, completion: nil)
    }
}
