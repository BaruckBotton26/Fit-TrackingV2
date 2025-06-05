//
//  BicepCurlTracker.swift
//  Fit TrackingV2
//
//  Created by Baruck Botton on 26/05/25.
//
import Foundation

class BicepCurlTracker {
    enum Phase {
        case idle, flexing, extending
    }

    private(set) var phase: Phase = .idle
    private var flexStart: Date?
    private var extendStart: Date?

    func procesar(value: Double, now: Date) -> (tfe: Double, tfc: Double)? {
        switch phase {
        case .idle:
            if value < 0.15 {
                flexStart = now
                phase = .flexing
            }

        case .flexing:
            if value > 0.85 {
                guard let start = flexStart else {
                    phase = .idle
                    return nil
                }
                extendStart = now
                phase = .extending
                print("🌀 Fase de flexión terminada: \(now.timeIntervalSince(start))s")
            }

        case .extending:
            if value < 0.15 {
                guard let flex = flexStart, let extend = extendStart else {
                    phase = .idle
                    return nil
                }
                let tfe = extend.timeIntervalSince(flex)
                let tfc = now.timeIntervalSince(extend)
                phase = .idle
                return (tfe, tfc)
            }
        }

        return nil
    }

    func reset() {
        phase = .idle
        flexStart = nil
        extendStart = nil
    }
}
