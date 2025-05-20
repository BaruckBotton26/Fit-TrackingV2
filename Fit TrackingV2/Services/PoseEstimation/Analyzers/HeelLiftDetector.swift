//
//  HeelLiftDetector.swift
//  Fit TrackingV2
//
//  Created by Baruck Botton on 18/05/25.
//

import Foundation
import QuickPoseCore

class HeelLiftDetector {
    
    private let landmarks: QuickPose.Landmarks
    private let threshold: Double = 0.02  // HEEL_LIFT_Y_THRESHOLD
    
    init(landmarks: QuickPose.Landmarks) {
        self.landmarks = landmarks
    }
    
    func evaluate() -> HeelLiftResult? {
        let heelL = landmarks.landmark(forBody: .heel(side: .left))
        let toeL = landmarks.landmark(forBody: .footIndex(side: .left))
        
        let heelR = landmarks.landmark(forBody: .heel(side: .right))
        let toeR = landmarks.landmark(forBody: .footIndex(side: .right))
        
        let puntos = [heelL, toeL, heelR, toeR]
        let confidenceThreshold = 0.5
        guard puntos.allSatisfy({ $0.visibility > confidenceThreshold }) else {
            return nil
        }

        let leftScore = toeL.y - heelL.y
        let rightScore = toeR.y - heelR.y
        
        let leftElevated = (heelL.y < toeL.y - threshold)
        let rightElevated = (heelR.y < toeR.y - threshold)
        print("🦶 LeftScore: \(leftScore), RightScore: \(rightScore)")
        let detectedIn: String
        if leftElevated && rightElevated {
            detectedIn = "both"
        } else if leftElevated {
            detectedIn = "left"
        } else if rightElevated {
            detectedIn = "right"
        } else {
            detectedIn = "none"
        }
        
        return HeelLiftResult(
            leftHeelY: heelL.y,
            leftToeY: toeL.y,
            rightHeelY: heelR.y,
            rightToeY: toeR.y,
            leftScore: leftScore,
            rightScore: rightScore,
            leftElevated: leftElevated,
            rightElevated: rightElevated,
            detectedIn: detectedIn
        )
    }
}
