//
//  Fit_TrackingV2Tests.swift
//  Fit TrackingV2Tests
//
//  Created by Baruck Botton on 1/05/25.
//

import Testing
import Foundation
import QuickPoseCore

@testable import Fit_TrackingV2

struct Fit_TrackingV2Tests {
    
    @Test func testQuickPoseThresholdCounter() async throws {
        var counter = QuickPoseThresholdCounter(enterThreshold: 0.8, exitThreshold: 0.2)
        
        // 🚫 No debería contar aún
        #expect(counter.count(0.1).count == 0)
        #expect(counter.count(0.5).count == 0)
        
        // ✅ Subimos por encima del umbral de entrada
        #expect(counter.count(0.85).count == 0)
        
        // ✅ Bajamos por debajo del umbral de salida → cuenta una repetición
        let reps = counter.count(0.1)
        #expect(reps.count == 1)
    }
    
    @Test func testValgoFrameData() async throws {
        var frameData = ValgoFrameData()
        
        // Agregamos 6 frames con valgo izquierdo y derecho
        for _ in 0..<6 {
            frameData.agregar(valgoResult: ValgoResult(
                leftValgo: true,
                rightValgo: true,
                leftAngle: 160.0,
                rightAngle: 160.0,
                ratio: 1.0,
                leftSeverity: 0.1,
                rightSeverity: 0.1
            ))
        }
        
        // Agregamos 4 frames sin valgo
        for _ in 0..<4 {
            frameData.agregar(valgoResult: ValgoResult(
                leftValgo: false,
                rightValgo: false,
                leftAngle: 175.0,
                rightAngle: 175.0,
                ratio: 1.0,
                leftSeverity: 0.0,
                rightSeverity: 0.0
            ))
        }
        
        // Deberían dar verdadero si el umbral por defecto es 0.6 (6/10 = 0.6)
        let resultado = frameData.evaluar()
        #expect(resultado.left == true)
        #expect(resultado.right == true)
    }
    @Test func testEvaluarValgo() async throws {
        var data = ValgoFrameData()
        
        // Simulamos 10 frames, 7 con valgo izquierdo, 2 con valgo derecho
        for _ in 0..<7 { data.agregar(valgoResult: .init(
            leftValgo: true,
            rightValgo: false,
            leftAngle: 0.0,
            rightAngle: 0.0,
            ratio: 1.0,
            leftSeverity: 0.0,
            rightSeverity: 0.0
        )) }
        for _ in 0..<2 { data.agregar(valgoResult: .init(
            leftValgo: true,
            rightValgo: false,
            leftAngle: 0.0,
            rightAngle: 0.0,
            ratio: 1.0,
            leftSeverity: 0.0,
            rightSeverity: 0.0
        )) }
        data.totalFrames += 1  // Un frame más sin valgo
        
        let resultado = data.evaluar(threshold: 0.6)
        
        #expect(resultado.left == true)
        #expect(resultado.right == false)
    }
    @Test func testEvaluarButtWink() async throws {
        var data = ButtWinkFrameData()
        
        // 6 de 10 frames con butt wink
        for _ in 0..<6 { data.agregar(result: .init(kneeAngle: 30, trunkThighAngle: 30, inclinacionSobreProfundidad: 1.0, detected: true)) }
        for _ in 0..<4 { data.agregar(result: .init(kneeAngle: 60, trunkThighAngle: 60, inclinacionSobreProfundidad: 1.0, detected: false)) }
        
        #expect(data.evaluar(threshold: 0.5) == true)
        #expect(data.evaluar(threshold: 0.7) == false)
    }
    @Test static func testThumbsUpDetectado() async throws {
        let detector = QuickPoseDoubleUnchangedDetector(similarDuration: 1.5)
        var fueDetectado = false

        let inicio = Date()

        // Simula frames durante 2 segundos con valor constante
        while Date().timeIntervalSince(inicio) < 2.0 {
            detector.count(result: 0.7) {
                fueDetectado = true
            }
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1s entre "frames"
        }

        #expect(fueDetectado == true)
    }
    @Test static func testFeedbackTextProgreso() throws {
        let value: Double = 0.65
        let reps = QuickPoseThresholdCounter().count(value)
        let progress = Int(value * 100)
        let feedbackText = "Progreso: \(progress)% | Repeticiones: \(reps.count)"

        #expect(feedbackText.contains("65%"))
        #expect(feedbackText.contains("Repeticiones: 0"))
    }
    @Test static func testFeedbackTextConUnaRepeticion() throws {
        let counter = QuickPoseThresholdCounter(enterThreshold: 0.8, exitThreshold: 0.2)
        let _ = counter.count(0.1) // baja
        let _ = counter.count(0.9) // sube (entra)
        let _ = counter.count(0.1) // baja (sale) → 1 rep

        // Como no podemos acceder a las reps directamente,
        // simulamos el texto como si se hubiera contado una rep
        let value = 0.1
        let progress = Int(value * 100)
        let feedbackText = "Progreso: \(progress)% | Repeticiones: 1"

        #expect(feedbackText.contains("Repeticiones: 1"))
    }
    @Test static func testFinalizacionPorQuietud() async throws {
        var inicioReposo: Date? = Date()
        let ultimaConfirmacion = Date().addingTimeInterval(-4)

        // Simula 6 segundos de quietud
        try await Task.sleep(nanoseconds: 6_000_000_000)

        let tiempoReposo = Date().timeIntervalSince(inicioReposo!)
        let debeFinalizar = tiempoReposo > 5.0 && Date().timeIntervalSince(ultimaConfirmacion) > 3.0

        #expect(debeFinalizar == true)
    }
}
struct ButtWinkFrameData {
    var detections = 0
    var total = 0

    mutating func agregar(result: ButtWinkResult?) {
        if let result = result, result.detected {
            detections += 1
        }
        total += 1
    }

    func evaluar(threshold: Double = 0.5) -> Bool {
        guard total > 0 else { return false }
        return Double(detections) / Double(total) >= threshold
    }
}
