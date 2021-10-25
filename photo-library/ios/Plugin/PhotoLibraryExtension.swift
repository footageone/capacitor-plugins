//
// Created by Daniel Schuba on 24.10.21.
// Copyright (c) 2021 Max Lynch. All rights reserved.
//

import Foundation
import Photos
import PhotosUI

internal protocol CameraAuthorizationState {
    var authorizationState: String { get }
}

extension PHAuthorizationStatus: CameraAuthorizationState {
    var authorizationState: String {
        switch self {
        case .denied, .restricted:
            return "denied"
        case .authorized:
            return "granted"
            #if swift(>=5.3)
                // poor proxy for Xcode 12/iOS 14, should be removed once building with Xcode 12 is required
        case .limited:
            return "limited"
            #endif
        case .notDetermined:
            fallthrough
        @unknown default:
            return "prompt"
        }
    }
}
