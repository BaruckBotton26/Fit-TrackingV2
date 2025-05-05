//
//  QuickPoseService.swift
//  Fit TrackingV2
//
//  Created by Baruck Botton on 3/05/25.
//
import Foundation
import QuickPoseCore

class QuickPoseService {
    private let processor = QuickPosePostProcessor(sdkKey: "01JTC3H0M71GVAKTPSMJRCN7K2")

    func processVideo(inputURL: URL, completion: @escaping (Result<URL, Error>) -> Void, progressHandler: @escaping (Double) -> Void) {
        let outputURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("processed_video.mov")

        let request = QuickPosePostProcessor.Request(
            input: inputURL,
            output: outputURL,	
            outputType: .mov
        )

        let features: [QuickPose.Feature] = [
            .overlay(
                .wholeBody,  // <- este es el grupo de landmarks
                style: QuickPose.Style(
                    relativeFontSize: 0.5,
                    relativeArcSize: 0.5,
                    relativeLineWidth: 0.5
                )
            ),
            .showPoints()
        ]

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try self.processor.process(features: features, isFrontCamera: false, request: request) { progress, _, _, _, _, _, _ in
                    progressHandler(progress)
                }
                DispatchQueue.main.async {
                    completion(.success(outputURL))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}
