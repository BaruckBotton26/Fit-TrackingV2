//
//  FeedbackViewModel.swift
//  Fit TrackingV2
//
//  Created by Baruck Botton on 1/05/25.
//
import Foundation
import AVFoundation

class FeedbackViewModel: ObservableObject {
    @Published var player: AVPlayer?
    
    func configureWithProcessedVideo(url: URL) {
        player = AVPlayer(url: url)
    }
}
