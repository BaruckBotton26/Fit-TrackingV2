//
//  QuickPoseViewModel.swift
//  Fit TrackingV2
//
//  Created by Baruck Botton on 3/05/25.
//
import Foundation

class QuickPoseViewModel: ObservableObject {
    @Published var processedVideoURL: URL? = nil
    @Published var isProcessing = false
    @Published var progress: Int = 0

    private let quickPoseService = QuickPoseService()

    
    func processVideo(from url: URL) {
        let startTime = Date()
        DispatchQueue.main.async {
            self.isProcessing = true
            self.progress = 0
        }

        quickPoseService.processVideo(inputURL: url) { result in
            let endTime = Date() // ⏱️ Tiempo de fin
            let elapsed = endTime.timeIntervalSince(startTime)
            DispatchQueue.main.async {
                self.isProcessing = false
                switch result {
                case .success(let output):
                    self.processedVideoURL = output
                    print("✅ Video procesado en \(elapsed) segundos")
                case .failure(let error):
                    print("❌ Error al procesar video: \(error)")
                }
            }
        } progressHandler: { currentProgress in
            DispatchQueue.main.async {
                self.progress = Int(currentProgress * 100)
            }
        }
    }
}
