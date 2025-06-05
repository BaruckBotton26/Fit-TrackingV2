//
//  PushUpPhaseTracker.swift
//  Fit TrackingV2
//
//  Created by Baruck Botton on 25/05/25.
//
import Foundation

class PushUpPhaseTracker {
    enum Phase {
        case idle, lowering, pushing
    }

    private(set) var phase: Phase = .idle
    private var downStart: Date?
    private var upStart: Date?

    func procesar(value: Double, now: Date) -> (tfe: Double, tfc: Double)? {
        switch phase {
        case .idle:
            if value < 0.15 {
                downStart = now
                phase = .lowering
            }

        case .lowering:
            if value > 0.85 {
                guard let start = downStart else {
                    phase = .idle
                    return nil
                }
                upStart = now
                phase = .pushing
            }

        case .pushing:
            if value < 0.15 {
                guard let down = downStart, let up = upStart else {
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
        downStart = nil
        upStart = nil
    }
}
