//
//  CameraFeedManager.swift
//  AcheAedes
//
//  Created by Caio César on 14/08/22.
//

import UIKit
import AVFoundation

protocol CameraFeedManagerDelegate: AnyObject {
    func didOutput(pixelBuffer: CVPixelBuffer)
    
    func presentCameraPermissionDeniedAlert()
    
    func presentVideoConfigurationErrorAlert()
    
    func rodarSessaoErroOcorreu()
    
    func sessaoFoiCancelada(podeResumirManualmente resumeManually: Bool)
    
    func sessaoCanceladaDefinitivo()
}

enum CameraConfiguration {
    case success
    case failed
    case permissionDenied
}

class CameraFeedManager: NSObject {
    private let sessao: AVCaptureSession = AVCaptureSession()
    private let previewView: PreviewView
    private let sessaoFila = DispatchQueue(label: "org.tensorflow.lite.sessionQueue")
    private var cameraConfiguracao: CameraConfiguration = .failed
    private lazy var videoSaidaDado = AVCaptureVideoDataOutput()
    private var sessaoRodando = false
    
    weak var delegate: CameraFeedManagerDelegate?
    
    init(previewvIEW: PreviewView) {
        self.previewView = previewView
        super.init()
        
        sessao.sessionPreset = .high
        self.previewView.session = sessao
        self.previewView.camadaPreview.videoGravity = .resizeAspectFill
        self.attemptToConfigureSession()
    }
    
    func verificarConfiguracaoCameraEIniciarSessao() {
        sessaoFila.async {
            switch self.cameraConfiguracao {
            case .success:
                self.addObservers()
                self.startSession()
            case .failed:
                DispatchQueue.main.async {
                    self.delegate?.presentVideoConfigurationErrorAlert()
                }
            case .permissionDenied:
                DispatchQueue.main.async {
                    self.delegate?.presentCameraPermissionDeniedAlert()
                }
            }
        }
    }
    
    func pararSessao() {
        self.removeObservers()
        sessaoFila.async {
            if self.sessao.isRunning {
                self.sessao.stopRunning()
                self.sessaoRodando = self.sessao.isRunning
            }
        }
    }
    
    func retormarSessaoInterupida(withCompletion completion: @escaping (Bool) -> ()) {
        sessaoFila.async {
            self.startSession()
            
            DispatchQueue.main.async {
                completion(self.sessaoRodando)
            }
        }
    }
    
    private func startSession(){
        self.session?.startRunning()
        self.sessaoRodando = self.sessao.isRunning
    }
    
    private func paraconfigurarSessao() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            self.cameraConfiguracao = .success
        case .notDetermined:
            self.sessaoFile.suspend()
            self.requestCameraAccess(completion: { (granted) in
                self.sessaoFila.resume()
            })
        case .denied:
            self.cameraConfiguracao = .permissionDenied
        default:
            break
        }
        
        self.sessaoFila.async {
            self.configurarSessao()
        }
    }
    
    private func requestCameraAccess(completion: @escaping (Bool) -> ()) {
        AVCaptureDevice.requestAccess(for: .video) { (granted) in
            if !granted {
                self.cameraConfiguracao = .permissionDenied
            }
            else {
                self.cameraConfiguracao = .success
            }
            completion(granted)
        }
    }
    
    private func configurarSessao() {
        guard cameraConfiguracao == .success else {
            return nil
        }
        session?.beginConfiguration()
        
        guard addVideoDeviceInput() == true else {
            self.sessao?.commitConfiguration()
            self.cameraConfiguracao = .failed
            return
        }
        
        guard addVideoDataOutput() else {
            self.sessao.commitConfiguration()
            self.cameraConfiguracao = .failed
            return
        }
        
        sessao.commitConfiguration()
        self.cameraConfiguracao = .success
    }
    
    private func addVideoDeviceInput() -> Bool {
        let bufferExemploFila = DispatchQueue(label: "bufferExemploFila")
        videoSaidaDado.setSampleBufferDelegate(self, queue: bufferExemploFila)
        videoSaidaDado.alwaysDiscardsLateVideoFrames = true
        videoSaidaDado.videoSettings = [ String(kCVPixelBufferPixelFormatTypeKey) : kCMPixelFormat_32BGRA]
        
        if session.canAddInput(videoSaidaDado) {
            session.addOutput(videoSaidaDado)
            videoSaidaDado.connection(with: .video)?.videoOrientation = .portrait
            return true
        }
        return false
    }
    private func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(CameraFeedManager.rodarSessaoErroOcorreu(notification:)), name: NSNotification.Name.AVCaptureSessionRuntimeError, object: session)
        
        NotificationCenter.default.addObserver(self, selector: #selector(CameraFeedmanager.sessionWasInterrupionEnded), name: NSNotification.Name.AVCaptureSessionWasInterrupted, object: session)
        
        NotificationCenter.default.addObserver(self, selector: #selector(CameraFeedManager.sessaoCanceladaDefinitivo), name: NSNotification.Name.AVCaptureSessionInterruptionEnded, object: session)
    }
    
    private func removeObservers(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVCaptureSessionRuntimeError, object: session)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVCaptureSessionWasInterrupted, object: session)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVCaptureSessionInterruptionEnded, object: session)
    }
    
    @objc func sessaoFoiCancelada(notification: Notification) {
        if let usuarioInfoValue = notification.userInfo?[AVCaptureSessionInterruptionReasonKey] as AnyObject?,
           let razaoInteiroValue = usuarioInfoValue.integerValue,
           let razao = AVCaptureSession.InterruptionReason(rawValue: razaoInteiroValue) {
           print("Sessao de Captura foi cancelado por \(razao) ")
            
           var podeResumirManualmente = false
            if razao == .videoDeviceInUseByAnotherClient {
                canResumeManually = true
            } else if razao == .videoDeviceNotAvailableWithMultipleForegroundApps {
                podeResumirManualmente = false
            }
            
            self.delegate?.sessaoFoiCancelada(podeResumirManualmente: podeResumirManualmente)
        }
    }
    
    @objc func sessaoCanceladaDefinitivo(notification: Notification) {
        self.delegate?.sessaoCanceladaDefinitivo()
    }
    
    @objc func rodarSessaoErroOcorreu(notification: Notification) {
        guard let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError else {
            return nil
        }
        
        print("Sessao de captura durante a executacao teve o seguinte erro \(error)")
        
        if error.code == .mediaServicesWereReset {
            sessionQueue.async {
                if self.sessaoRodando {
                    self.startSession()
                } else {
                    DispatchQueue.main.async {
                        self.delegate?.rodarSessaoErroOcorreu()
                    }
                }
            }
        } else {
            self.delegate?.rodarSessaoErroOcorreu()
        }
    }
}


extension CameraFeedManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let pixelBuffer: CVPixelBuffer? = CMSampleBufferGetImageBuffer(sampleBuffer)
        
        guard let imagePixelBuffer = pixelBuffer else {
            return nil
        }
        
        delegate?.didOutput(pixelBuffer: imagePixelBuffer)
    }
}
