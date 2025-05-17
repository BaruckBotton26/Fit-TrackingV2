//
//  CameraPreviewViewController.swift
//  Fit TrackingV2
//
//  Created by Baruck Botton on 1/05/25.
//

import AVFoundation
import UIKit

class CameraPreviewViewController: UIViewController {
    private let CaptureSession = AVCaptureSession()
    private var movieOutput = AVCaptureMovieFileOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    var videoGrabado: ((URL) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurarCamara()
    }
     
    private func configurarCamara() {
        guard let camera = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: camera),
              CaptureSession.canAddInput(input) else {
            return
        }
        
        CaptureSession.beginConfiguration()
        CaptureSession.addInput(input)
        
        if CaptureSession.canAddOutput(movieOutput) {
            CaptureSession.addOutput(movieOutput)
        }
        
        CaptureSession.commitConfiguration()
        
        previewLayer = AVCaptureVideoPreviewLayer(session: CaptureSession)
        previewLayer?.videoGravity = .resizeAspectFill
        previewLayer?.frame = view.bounds
        if let previewLayer = previewLayer {
            view.layer.addSublayer(previewLayer)
        }
        
        // Iniciar la sesión en un hilo en segundo plano
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.CaptureSession.startRunning()
        }
    }
    func startRecording(){
        let outputPath = NSTemporaryDirectory() + UUID().uuidString + ".mov"
        let outputURL = URL(fileURLWithPath: outputPath)
        movieOutput.startRecording(to: outputURL, recordingDelegate: self)
    }
    func stopRecording(){
        movieOutput.stopRecording()
    }
}

extension CameraPreviewViewController: AVCaptureFileOutputRecordingDelegate{
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?){
        if error == nil{
            videoGrabado?(outputFileURL)
        }else{
            print("Error al grabar video: \(String(describing: error))")

        }
    }
}

