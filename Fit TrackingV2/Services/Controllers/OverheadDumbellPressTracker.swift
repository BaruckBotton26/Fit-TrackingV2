//
//  OverheadDumbellPressTracker.swift
//  Fit TrackingV2
//
//  Created by Baruck Botton on 4/06/25.
//
import Foundation

class OverheadDumbbellPressTracker {
    enum Phase {
        case idle, lowering, pressing
    }

    private(set) var phase: Phase = .idle
    private var loweringStart: Date?
    private var pressingStart: Date?

    func procesar(value: Double, now: Date) -> (tfe: Double, tfc: Double)? {
        switch phase {
        case .idle:
            if value < 0.15 {
                loweringStart = now
                phase = .lowering
            }

        case .lowering:
            if value > 0.85 {
                guard let start = loweringStart else {
                    phase = .idle
                    return nil
                }
                pressingStart = now
                phase = .pressing
            }

        case .pressing:
            if value < 0.15 {
                guard let down = loweringStart, let up = pressingStart else {
                    phase = .idle
                    return nil
                }
                let tfe = up.timeIntervalSince(down)
                let tfc = now.timeIntervalSince(up)
                phase = .idle
                return (tfe, tfc)
            }
        }

        return nil
    }

    func reset() {
        phase = .idle
        loweringStart = nil
        pressingStart = nil
    }
}
