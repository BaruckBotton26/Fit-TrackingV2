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

    private func EstiloRodilla() -> QuickPose.Style {
        return QuickPose.Style(
            relativeFontSize: 0.5,
            relativeArcSize: 0.5,
            relativeLineWidth: 0.5,
            conditionalColors: [
                .init(min: 55, max: 110, color: .green),
                .init(min: nil, max: 55, color: .red),
                .init(min: 110, max: nil, color: .red)
            ]
        )
    }
    private func estiloCadera() -> QuickPose.Style {
        return QuickPose.Style(
            relativeFontSize: 0.5,
            relativeArcSize: 0.5,
            relativeLineWidth: 0.5,
            conditionalColors: [
                .init(min: 60, max: 130, color: .green), // ejemplo
                .init(min: nil, max: 60, color: .red),
                .init(min: 130, max: nil, color: .red)
            ]
        )
    }

    private func estiloTobillo() -> QuickPose.Style {
        return QuickPose.Style(
            relativeFontSize: 0.5,
            relativeArcSize: 0.5,
            relativeLineWidth: 0.5,
            conditionalColors: [
                .init(min: 25, max: 60, color: .green), // ejemplo
                .init(min: nil, max: 25, color: .orange),
                .init(min: 60, max: nil, color: .red)
            ]
        )
    }

    private func estiloEspalda() -> QuickPose.Style {
        return QuickPose.Style(
            relativeFontSize: 0.5,
            relativeArcSize: 0.5,
            relativeLineWidth: 0.5,
            conditionalColors: [
                .init(min: 0, max: 30, color: .green), // poca inclinación del torso
                .init(min: 30, max: nil, color: .orange)
            ]
        )
    }
    func processVideo(inputURL: URL, completion: @escaping (Result<URL, Error>) -> Void, progressHandler: @escaping (Double) -> Void) {
        let outputURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("processed_video.mov")

        let request = QuickPosePostProcessor.Request(
            input: inputURL,
            output: outputURL,
            outputType: .mov
        )

        let features: [QuickPose.Feature] = [
            .rangeOfMotion(
                .knee(side: .left, clockwiseDirection: true),// <- este es el grupo de landmarks
                style: EstiloRodilla()
            ),
            .rangeOfMotion(
                .knee(side: .right, clockwiseDirection: false),
                style: EstiloRodilla()
               ),
            .rangeOfMotion(.hip(side: .left, clockwiseDirection: false), style: estiloCadera()),
            .rangeOfMotion(.hip(side: .right, clockwiseDirection: true), style: estiloCadera()),

            .rangeOfMotion(.ankle(side: .left, clockwiseDirection: true), style: estiloTobillo()),
            .rangeOfMotion(.ankle(side: .right, clockwiseDirection: false), style: estiloTobillo()),

            .rangeOfMotion(.back(clockwiseDirection: true), style: estiloEspalda()),
            .overlay(.wholeBody),
            .showPoints(),
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
