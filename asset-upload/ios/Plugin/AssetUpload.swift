import Foundation
import Photos
import MultipartFormDataKit
import MobileCoreServices


func getMimeType(fileExtension: CFString) -> MIMEType {
     guard
         let extUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, nil)?.takeUnretainedValue()
    else { return MIMEType(text: "") }
     
     guard
         let mimeUTI = UTTypeCopyPreferredTagWithClass(extUTI, kUTTagClassMIMEType)
    else { return MIMEType(text: "") }
     
    return MIMEType(text: mimeUTI.takeRetainedValue() as String)
}

public class AssetUpload {
    
    var multipartFormData: MultipartFormData.BuildResult
    var asset: PHAsset
    var resources: [PHAssetResource]
    var filename: String
    var mimeType: MIMEType
    
    var id: String {
        return asset.localIdentifier
    }
    
    init(exportSession: AVAssetExportSession?, asset: PHAsset) {
        self.asset = asset
        resources = PHAssetResource.assetResources(for: asset)
        filename = ((resources.first!).originalFilename)
        mimeType = getMimeType(fileExtension: filename.components(separatedBy: ".").last! as CFString)
        
        multipartFormData = try! MultipartFormData.Builder.build(
            with: [
                (
                    name: "files",
                    filename: filename,
                    mimeType: mimeType,
                    data: Data(contentsOf: (exportSession?.outputURL)!)
                ),
            ],
            willSeparateBy: RandomBoundaryGenerator.generate()
        )
    }
    
    init(data: Data, asset: PHAsset) {
        self.asset = asset
        resources = PHAssetResource.assetResources(for: asset)
        filename = ((resources.first!).originalFilename)
        mimeType = getMimeType(fileExtension: filename.components(separatedBy: ".").last! as CFString)
        
        multipartFormData = try! MultipartFormData.Builder.build(
            with: [
                (
                    name: "files",
                    filename: filename,
                    mimeType: mimeType,
                    data: data
                )
                
            ],
            willSeparateBy: RandomBoundaryGenerator.generate()
        )
    }
    
    
    
    func processUpload(url: String) -> Progress {
        let defaults = UserDefaults.standard
        // Read/Get Value
        let token = defaults.string(forKey: "CapacitorStorage.token")!
                
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.addValue(multipartFormData.contentType, forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        request.httpBody = multipartFormData.body

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("error: \(String(describing: error))")
                return
            }
        }
        
        task.resume()
        return task.progress;
    }
}
