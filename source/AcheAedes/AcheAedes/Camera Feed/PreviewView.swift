//
//  PreviewView.swift
//  AcheAedes
//
//  Created by Caio César on 14/08/22.
//

import UIKit
import AVFoundation

class PreviewView: UIView {
    var camadaPreview: AVCaptureVideoPreviewLayer {
        guard let layer = layer as? AVCaptureVideoPreviewLayer else {
            fatalError("Camada esperada e um tipo de preview de camada de video")
        }
        return layer
    }
    var session: AVCaptureSession? {
        get {
            return camadaPreview.session
        }
        set {
            camadaPreview.session = newValue
        }
    }
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
}
