//
//  AsymetryDetector.swift
//  Fit TrackingV2
//
//  Created by Baruck Botton on 18/05/25.
//
import Foundation
import QuickPoseCore

class AsymmetryDetector {
    
    private let landmarks: QuickPose.Landmarks
    private let hipYThreshold: Double = 0.025
    private let kneeXThreshold: Double = 0.03
    private let shoulderYThreshold: Double = 0.02
    
    init(landmarks: QuickPose.Landmarks) {
        self.landmarks = landmarks
    }
    
    func evaluate() -> AsymmetryResult? {
        let hipL = landmarks.landmark(forBody: .hip(side: .left))
        let hipR = landmarks.landmark(forBody: .hip(side: .right))
        let kneeL = landmarks.landmark(forBody: .knee(side: .left))
        let kneeR = landmarks.landmark(forBody: .knee(side: .right))
        let shoulderL = landmarks.landmark(forBody: .shoulder(side: .left))
        let shoulderR = landmarks.landmark(forBody: .shoulder(side: .right))
        
        let puntos = [hipL, hipR, kneeL, kneeR, shoulderL, shoulderR]
        let confidenceThreshold = 0.5
        guard puntos.allSatisfy({ $0.visibility > confidenceThreshold }) else {
            return nil
        }
        
        let hipDeltaY = abs(hipL.y - hipR.y)
        let kneeDeltaX = abs(kneeL.x - kneeR.x)
        let shoulderDeltaY = abs(shoulderL.y - shoulderR.y)
        
        let hipAsymmetry = hipDeltaY > hipYThreshold
        let kneeAsymmetry = kneeDeltaX > kneeXThreshold
        let shoulderAsymmetry = shoulderDeltaY > shoulderYThreshold
        
        let overall = hipAsymmetry || kneeAsymmetry || shoulderAsymmetry
        
        return AsymmetryResult(
            hipDeltaY: hipDeltaY,
            kneeDeltaX: kneeDeltaX,
            shoulderDeltaY: shoulderDeltaY,
            hipAsymmetry: hipAsymmetry,
            kneeAsymmetry: kneeAsymmetry,
            shoulderAsymmetry: shoulderAsymmetry,
            overallAsymmetry: overall
        )
    }
}
