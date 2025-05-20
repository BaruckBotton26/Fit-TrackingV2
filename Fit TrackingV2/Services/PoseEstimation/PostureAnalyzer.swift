//
//  PostureAnalyzer.swift
//  Fit TrackingV2
//
//  Created by Baruck Botton on 17/05/25.
//

import Foundation
import QuickPoseCore

class PostureAnalyzer{
    func detectarErroresEnSentadilla(from landmarks: QuickPoseCore.QuickPose.Landmarks) -> String? {
        /*
         let caderaIzq = landmarks.landmark(forBody: .hip(side: .left))
         let caderaDer = landmarks.landmark(forBody: .hip(side: .right))
         let rodillaIzq = landmarks.landmark(forBody: .knee(side: .left))
         let rodillaDer = landmarks.landmark(forBody: .knee(side: .right))
         let tobilloIzq = landmarks.landmark(forBody: .ankle(side: .left))
         let tobilloDer = landmarks.landmark(forBody: .ankle(side: .right))
         
         
         let puntos = [caderaIzq, caderaDer, rodillaIzq, rodillaDer, tobilloIzq, tobilloDer]
         let puntosVisibles = puntos.filter { $0.visibility > 0.5 }
         
         guard puntosVisibles.count == puntos.count else {
         print("🚫 Puntos clave no visibles, se omite análisis")
         return nil
         }
         
         var errores: [String] = []
         
         let umbralIzq = abs(caderaIzq.x - tobilloIzq.x) * 0.2
         let umbralDer = abs(caderaDer.x - tobilloDer.x) * 0.2
         
         // Valgo izquierda
         if rodillaIzq.x < min(caderaIzq.x, tobilloIzq.x) - umbralIzq ||
         rodillaIzq.x > max(caderaIzq.x, tobilloIzq.x) + umbralIzq {
         errores.append("⚠️ Valgo en rodilla izquierda")
         }
         
         // Valgo derecha
         if rodillaDer.x < min(caderaDer.x, tobilloDer.x) - umbralDer ||
         rodillaDer.x > max(caderaDer.x, tobilloDer.x) + umbralDer {
         errores.append("⚠️ Valgo en rodilla derecha")
         }
         
         return errores.isEmpty ? nil : errores.joined(separator: "\n")
         }
         }
         */
        
        let hipL = landmarks.landmark(forBody: .hip(side: .left))
        let kneeL = landmarks.landmark(forBody: .knee(side: .left))
        let ankleL = landmarks.landmark(forBody: .ankle(side: .left))
        
        let hipR = landmarks.landmark(forBody: .hip(side: .right))
        let kneeR = landmarks.landmark(forBody: .knee(side: .right))
        let ankleR = landmarks.landmark(forBody: .ankle(side: .right))
        
        let puntos = [hipL, kneeL, ankleL, hipR, kneeR, ankleR]
        let confidenceThreshold = 0.5
        
        guard puntos.allSatisfy({ $0.visibility > confidenceThreshold }) else {
            return nil
        }
        
        var errores: [String] = []
        
        // --- Umbrales ---
        let VALGO_RATIO_THRESHOLD = 0.85
        
        let ratioIzq = calcularRatioRodillaEntre(hipL, kneeL, ankleL)
        let ratioDer = calcularRatioRodillaEntre(hipR, kneeR, ankleR)
        
        print("📐 Ratio rodilla izquierda:", ratioIzq)
        print("📐 Ratio rodilla derecha:", ratioDer)
        
        if ratioIzq < VALGO_RATIO_THRESHOLD {
            errores.append("⚠️ Valgo en rodilla izquierda")
        }
        
        if ratioDer < VALGO_RATIO_THRESHOLD {
            errores.append("⚠️ Valgo en rodilla derecha")
        }
        
        return errores.isEmpty ? nil : errores.joined(separator: "\n")
    }
    
    private func calcularRatioRodillaEntre(_ cadera: QuickPose.Point3d, _ rodilla: QuickPose.Point3d, _ tobillo: QuickPose.Point3d) -> Double {
        let ancho = abs(cadera.x - tobillo.x)
        guard ancho > 0 else { return 1.0 }
        let desplazamiento = abs(rodilla.x - ((cadera.x + tobillo.x) / 2))
        let ratio = 1.0 - (desplazamiento / ancho)
        return ratio
    }
}
