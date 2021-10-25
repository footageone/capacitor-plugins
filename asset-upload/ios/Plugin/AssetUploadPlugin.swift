import Foundation
import Capacitor
import Photos
import Logging
import MultipartFormDataKit
import MobileCoreServices

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@available(iOS 13, *)
@objc(AssetUploadPlugin)
public class AssetUploadPlugin: CAPPlugin {
    private var observations: [NSKeyValueObservation] = []
    private var call: CAPPluginCall?
    private let imageManager = PHImageManager.default()
    private let logger = Logger(label: "one.footage.AssetUploadPlugin")
    private var localIdentifiers: [String]?
    private var idsDone: [String] = []
    
    @objc func upload(_ call: CAPPluginCall) {
        self.call = call
        let url = call.getString("url") ?? ""
        if (url.isEmpty) {
            call.reject("Url is empty or not a string")
            return
        }
    
        
        let ids = call.getArray("ids") ?? []
        if (ids.isEmpty) {
            call.reject("Ids is empty")
            return
        }
        
        logger.info("ids: \(ids)")
        
        localIdentifiers = ids.map({ item in
            item as! String
        })
        
        let fetchOptions: PHFetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        DispatchQueue.global(qos: .background).async {
            let assets = PHAsset.fetchAssets(withLocalIdentifiers: self.localIdentifiers!, options: fetchOptions)
            
            assets.enumerateObjects { asset, _, _ in
                self.processAsset(asset: asset, url: url)
            }
        }
    }
    
    deinit {
        for observation in observations {
            observation.invalidate()
        }
      }
}

@available(iOS 13, *)
extension AssetUploadPlugin {
    func processAsset(asset: PHAsset, url: String) {
    
        logger.info("processing asset \(asset.localIdentifier)");
        switch (asset.mediaType) {
        case .video:
            let options = PHVideoRequestOptions()
            options.isNetworkAccessAllowed = true
        
            imageManager.requestExportSession(forVideo: asset, options: options, exportPreset: AVAssetExportPresetPassthrough) { exportSession, _ in
                let assetUpload = AssetUpload(exportSession: exportSession, asset: asset)
                let task = assetUpload.processUpload(url: url)
                let observation = task.observe(\.fractionCompleted) { progress, _ in
                    self.reportProgress(id: assetUpload.id, progress: progress.fractionCompleted)
                }
                self.observations.append(observation)
            }
        case .image:
            let options = PHImageRequestOptions()
            options.isNetworkAccessAllowed = true
            imageManager.requestImageDataAndOrientation(for: asset, options: options) { data, _, orientation,_ in
                let assetUpload = AssetUpload(data: data!, asset: asset)
                let task = assetUpload.processUpload(url: url)
                let observation = task.observe(\.fractionCompleted) { progress, _ in
                    self.reportProgress(id: assetUpload.id, progress: progress.fractionCompleted)
                }
                self.observations.append(observation)
            }
        case .unknown:
            logger.warning("unkown not implemented")
        case .audio:
            logger.warning("audi not implemented")
        @unknown default:
            logger.warning("default case new media type?")
        }
    }
    func reportProgress(id: String, progress: Double) {
        DispatchQueue.main.async {
            self.notifyListeners("assetUploadProgress", data: ["id": id, "progress": progress], retainUntilConsumed: true)
            if (progress == 1) {
                self.idsDone.append(id)
            }
            self.checkAllDone();
        }
    }
    
    func checkAllDone() {
        let done = self.localIdentifiers?.containsSameElements(as: self.idsDone);
        if (done!) {
            self.call!.resolve([
                "done": true
            ])
        }
    }
}
