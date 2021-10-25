//
//  PhotoPickerModel.swift
//  PHPickerDemo
//
//  Created by Gabriel Theodoropoulos.
//

import SwiftUI
import Photos
import Capacitor

@available(iOS 13, *)
struct PhotoPickerModel {
    var id: String
    var asset: PHAsset
    var mediaType: PHAssetMediaType

    init(with asset: PHAsset) {
        self.asset = asset
        id = asset.localIdentifier
        mediaType = asset.mediaType
    }

    var filename: String {
        let resources = PHAssetResource.assetResources(for: asset)
        return ((resources.first!).originalFilename)
    }
    
    var base64: String? {
        let imageRequestOptions = PHImageRequestOptions()
        imageRequestOptions.isSynchronous = true
        imageRequestOptions.resizeMode = PHImageRequestOptionsResizeMode.fast

        var result: String = ""
        _ = PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 2000, height: 2000), contentMode: .aspectFit, options: imageRequestOptions, resultHandler: { (image, _) in
            result = (image?.jpegData(compressionQuality: 0.8)!.base64EncodedString())!
        })

        return result
    }

    var dataUrl: String {
        if ((self.base64) != nil) {
            return "data:image/jpeg;base64," + base64!;
        } else {
            return "";
        }
    }

    mutating func delete() {
//        switch mediaType {
//        case .photo: photo = nil
//        case .livePhoto: livePhoto = nil
//        case .video:
//            guard let url = url else { return }
//            try? FileManager.default.removeItem(at: url)
//            self.url = nil
//        }
    }
    
    func json() -> PluginCallResultData {
        [
            "id": id,
            "base64": base64!,
            "dataUrl": dataUrl,
            "filename": filename,
            "mediaType": mediaType.rawValue
        ]
    }
}


@available(iOS 13, *)
class PickedMediaItems {
    @Published var items = [PhotoPickerModel]()
    
    var count: Int {
        items.count
    }

    func append(item: PhotoPickerModel) {
        items.append(item)
    }

    func deleteAll() {
        for (index, _) in items.enumerated() {
            items[index].delete()
        }

        items.removeAll()
    }
    
    func result() -> PluginCallResultData {
        var jsonItems = [[String: Any]]();
        for i in items {
            jsonItems.append(i.json())
        }
        return [
            "items": jsonItems
        ]
    }
}
