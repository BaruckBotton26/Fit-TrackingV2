//
//  ValgoDetector.swift
//  Fit TrackingV2
//
//  Created by Baruck Botton on 18/05/25.
//

import Foundation
import QuickPoseCore

struct ValgoFrameData {
    var leftValgoCount = 0
    var rightValgoCount = 0
    var totalFrames = 0

    mutating func agregar(valgoResult: ValgoResult) {
        if valgoResult.leftValgo { leftValgoCount += 1 }
        if valgoResult.rightValgo { rightValgoCount += 1 }
        totalFrames += 1
    }

    func evaluar(threshold: Double = 0.6) -> (left: Bool, right: Bool) {
        guard totalFrames > 0 else { return (false, false) }
        let leftRatio = Double(leftValgoCount) / Double(totalFrames)
        let rightRatio = Double(rightValgoCount) / Double(totalFrames)
        return (leftRatio >= threshold, rightRatio >= threshold)
    }
}
class ValgoDetector {
    
    private let landmarks: QuickPose.Landmarks
    private let angleThreshold: Double
    
    init(landmarks: QuickPose.Landmarks, angleThreshold: Double = 165.0) {
        self.landmarks = landmarks
        self.angleThreshold = angleThreshold
    }
    func evaluate() -> ValgoResult? {
            let hipL = landmarks.landmark(forBody: .hip(side: .left))
            let kneeL = landmarks.landmark(forBody: .knee(side: .left))
            let ankleL = landmarks.landmark(forBody: .ankle(side: .left))
            
            let hipR = landmarks.landmark(forBody: .hip(side: .right))
            let kneeR = landmarks.landmark(forBody: .knee(side: .right))
            let ankleR = landmarks.landmark(forBody: .ankle(side: .right))
            
            let puntos = [hipL, kneeL, ankleL, hipR, kneeR, ankleR]
            guard puntos.allSatisfy({ $0.visibility > 0.5 }) else {
                return nil
            }

            // Calculamos ángulos
            let leftAngle = calcularAngulo(p1: hipL, p2: kneeL, p3: ankleL)
            let rightAngle = calcularAngulo(p1: hipR, p2: kneeR, p3: ankleR)

            // Calculamos distancias entre rodillas y tobillos
            let kneeDist = distanciaEuclidiana(a: kneeL, b: kneeR)
            let ankleDist = distanciaEuclidiana(a: ankleL, b: ankleR)
            let ratio = ankleDist > 0 ? kneeDist / ankleDist : Double.infinity
            
            // Definir margen para detectar desplazamiento
            let margen: Double = 0.02 // Ajusta este valor según la sensibilidad que necesites
            
            let centroX = (ankleL.x + ankleR.x) / 2.0

        // Valgo izquierdo: rodilla más cerca del centro que cadera y tobillo
            let leftValgo = (kneeL.x - hipL.x) < -margen || (kneeL.x - ankleL.x) < -margen

        // Valgo derecho: rodilla más cerca del centro que cadera y tobillo
            let rightValgo = (kneeR.x - hipR.x) > margen || (kneeR.x - ankleR.x) > margen


            // Cálculo de severidad basado en el ratio
            let leftSeverity = leftValgo ? abs(kneeL.x - hipL.x) * 5 : 0.0
            let rightSeverity = rightValgo ? abs(hipR.x - kneeR.x) * 5 : 0.0


            return ValgoResult(
                leftValgo: leftValgo,
                rightValgo: rightValgo,
                leftAngle: leftAngle,
                rightAngle: rightAngle,
                ratio: ratio,
                leftSeverity: leftSeverity,
                rightSeverity: rightSeverity
            )
        }
        
        private func calcularAngulo(p1: QuickPose.Point3d, p2: QuickPose.Point3d, p3: QuickPose.Point3d) -> Double {
            let v1 = (
                x: p1.x - p2.x,
                y: p1.y - p2.y,
                z: p1.z - p2.z
            )
            let v2 = (
                x: p3.x - p2.x,
                y: p3.y - p2.y,
                z: p3.z - p2.z
            )
            
            let dotProduct = v1.x * v2.x + v1.y * v2.y + v1.z * v2.z
            let magnitude1 = sqrt(v1.x * v1.x + v1.y * v1.y + v1.z * v1.z)
            let magnitude2 = sqrt(v2.x * v2.x + v2.y * v2.y + v2.z * v2.z)

            guard magnitude1 > 0, magnitude2 > 0 else {
                return 0.0
            }

            let cosAngle = max(-1.0, min(1.0, dotProduct / (magnitude1 * magnitude2)))
            return acos(cosAngle) * (180 / .pi)
        }
        
        private func distanciaEuclidiana(a: QuickPose.Point3d, b: QuickPose.Point3d) -> Double {
            let dx = a.x - b.x
            let dy = a.y - b.y
            let dz = a.z - b.z
            return sqrt(dx * dx + dy * dy + dz * dz)
        }
    }
    /*
    func evaluate() -> ValgoResult? {
        let hipL = landmarks.landmark(forBody: .hip(side: .left))
        let kneeL = landmarks.landmark(forBody: .knee(side: .left))
        let ankleL = landmarks.landmark(forBody: .ankle(side: .left))
        
        let hipR = landmarks.landmark(forBody: .hip(side: .right))
        let kneeR = landmarks.landmark(forBody: .knee(side: .right))
        let ankleR = landmarks.landmark(forBody: .ankle(side: .right))
        
        let puntos = [hipL, kneeL, ankleL, hipR, kneeR, ankleR]
        guard puntos.allSatisfy({ $0.visibility > 0.5 }) else {
            return nil
        }

        let leftAngle = calcularAngulo(p1: hipL, p2: kneeL, p3: ankleL)
        let rightAngle = calcularAngulo(p1: hipR, p2: kneeR, p3: ankleR)

        let kneeDist = distanciaEuclidiana(a: kneeL, b: kneeR)
        let ankleDist = distanciaEuclidiana(a: ankleL, b: ankleR)
        let ratio = ankleDist > 0 ? kneeDist / ankleDist : Double.infinity

        
        let margen: Double = 0.015

        let leftValgo = (kneeL.x - hipL.x) > margen && (kneeL.x - ankleL.x) > margen
        let rightValgo = (hipR.x - kneeR.x) > margen && (ankleR.x - kneeR.x) > margen
        

        let leftSeverity = leftValgo ? (1.0 - min(1.0, ratio)) : 0.0
        let rightSeverity = rightValgo ? (1.0 - min(1.0, ratio)) : 0.0

        print("🦵 LeftAngle: \(leftAngle), RightAngle: \(rightAngle), Ratio: \(ratio)")
        print("🔍 Valgo izquierda: \(leftValgo), derecha: \(rightValgo)")

        return ValgoResult(
            leftValgo: leftValgo,
            rightValgo: rightValgo,
            leftAngle: leftAngle,
            rightAngle: rightAngle,
            ratio: ratio,
            leftSeverity: leftSeverity,
            rightSeverity: rightSeverity
        )
    }
    
    private func calcularAngulo(p1: QuickPose.Point3d, p2: QuickPose.Point3d, p3: QuickPose.Point3d) -> Double {
        let v1 = (
            x: p1.x - p2.x,
            y: p1.y - p2.y,
            z: p1.z - p2.z
        )
        let v2 = (
            x: p3.x - p2.x,
            y: p3.y - p2.y,
            z: p3.z - p2.z
        )
        
        let dotProduct = v1.x * v2.x + v1.y * v2.y + v1.z * v2.z
        let magnitude1 = sqrt(v1.x * v1.x + v1.y * v1.y + v1.z * v1.z)
        let magnitude2 = sqrt(v2.x * v2.x + v2.y * v2.y + v2.z * v2.z)

        guard magnitude1 > 0, magnitude2 > 0 else {
            return 0.0
        }

        let cosAngle = max(-1.0, min(1.0, dotProduct / (magnitude1 * magnitude2)))
        return acos(cosAngle) * (180 / .pi)
    }
    
    private func distanciaEuclidiana(a: QuickPose.Point3d, b: QuickPose.Point3d) -> Double {
        let dx = a.x - b.x
        let dy = a.y - b.y
        let dz = a.z - b.z
        return sqrt(dx * dx + dy * dy + dz * dz)
    }

}
*/
