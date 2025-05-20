//
//  ButtWinkDetector.swift
//  Fit TrackingV2
//
//  Created by Baruck Botton on 18/05/25.
//

import Foundation
import QuickPoseCore

class ButtWinkDetector {
    private let landmarks: QuickPose.Landmarks
    private let trunkAngleThreshold: Double = 45.0
    private let kneeAngleThreshold: Double = 55.0
    private let confidenceThreshold: Double = 0.5

    init(landmarks: QuickPose.Landmarks) {
        self.landmarks = landmarks
    }

    func evaluate() -> ButtWinkResult? {
        let shoulderL = landmarks.landmark(forBody: .shoulder(side: .left))
        let shoulderR = landmarks.landmark(forBody: .shoulder(side: .right))
        let hipL = landmarks.landmark(forBody: .hip(side: .left))
        let hipR = landmarks.landmark(forBody: .hip(side: .right))
        let kneeL = landmarks.landmark(forBody: .knee(side: .left))
        let kneeR = landmarks.landmark(forBody: .knee(side: .right))
        let ankleL = landmarks.landmark(forBody: .ankle(side: .left))
        let ankleR = landmarks.landmark(forBody: .ankle(side: .right))

        let puntos = [shoulderL, shoulderR, hipL, hipR, kneeL, kneeR, ankleL, ankleR]
        guard puntos.allSatisfy({ $0.visibility > confidenceThreshold }) else {
            return nil
        }

        // Usamos solo coordenadas necesarias: (x, y)
        let shoulderCenter = averageXY(shoulderL, shoulderR)
        let hipCenter = averageXY(hipL, hipR)
        let kneeCenter = averageXY(kneeL, kneeR)
        let ankleCenter = averageXY(ankleL, ankleR)

        let kneeAngle = calcularAngulo(p1: hipCenter, p2: kneeCenter, p3: ankleCenter)
        let trunkThighAngle = calcularAngulo(p1: shoulderCenter, p2: hipCenter, p3: kneeCenter)
        let inclinacionSobreProfundidad = kneeAngle != 0 ? trunkThighAngle / kneeAngle : .infinity

        let detected = kneeAngle < kneeAngleThreshold && trunkThighAngle < trunkAngleThreshold

        return ButtWinkResult(
            kneeAngle: kneeAngle,
            trunkThighAngle: trunkThighAngle,
            inclinacionSobreProfundidad: inclinacionSobreProfundidad,
            detected: detected
        )
    }

    private func calcularAngulo(p1: (x: Double, y: Double),
                                p2: (x: Double, y: Double),
                                p3: (x: Double, y: Double)) -> Double {
        let v1 = CGVector(dx: p1.x - p2.x, dy: p1.y - p2.y)
        let v2 = CGVector(dx: p3.x - p2.x, dy: p3.y - p2.y)
        let dot = v1.dx * v2.dx + v1.dy * v2.dy
        let mag1 = sqrt(v1.dx * v1.dx + v1.dy * v1.dy)
        let mag2 = sqrt(v2.dx * v2.dx + v2.dy * v2.dy)
        let cosAngle = max(-1.0, min(1.0, dot / (mag1 * mag2)))
        return acos(cosAngle) * (180 / .pi)
    }

    private func averageXY(_ a: QuickPose.Point3d, _ b: QuickPose.Point3d) -> (x: Double, y: Double) {
        return ((a.x + b.x) / 2, (a.y + b.y) / 2)
    }
}
