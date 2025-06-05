//
//  SquatPhaseTracker.swift
//  Fit TrackingV2
//
//  Created by Baruck Botton on 25/05/25.
//

import Foundation

class SquatPhaseTracker {
    enum Phase {
        case idle, eccentric, concentric
    }

    private(set) var phase: Phase = .idle
    private var eccentricStart: Date?
    private var concentricStart: Date?
    private var framesBajando: Int = 0
    private let framesNecesariosParaIniciar = 3

    func procesar(value: Double, now: Date) -> (tfe: Double, tfc: Double)? {
        switch phase {
        case .idle:
                    if value < 0.15 {
                        framesBajando += 1
                        if framesBajando >= framesNecesariosParaIniciar {
                            eccentricStart = now
                            phase = .eccentric
                            framesBajando = 0
                        }
                    } else {
                        // Si deja de bajar, reinicia el contador
                        framesBajando = 0
                    }

                case .eccentric:
                    if value > 0.85 {
                        guard let ecc = eccentricStart else {
                            phase = .idle
                            return nil
                        }
                        concentricStart = now
                        phase = .concentric
                    }

                case .concentric:
                    if value < 0.15 {
                        guard let ecc = eccentricStart, let conc = concentricStart else {
                            phase = .idle
                            return nil
                        }
                        let tfe = conc.timeIntervalSince(ecc)
                        let tfc = now.timeIntervalSince(conc)
                        phase = .idle
                        return (tfe, tfc)
                    }
                }
                return nil
            }

            func reset() {
                phase = .idle
                eccentricStart = nil
                concentricStart = nil
                framesBajando = 0
            }
        }

            /*
        case .idle:
            if value < 0.15 {
                eccentricStart = now
                phase = .eccentric
            }

        case .eccentric:
            if value > 0.85 {
                guard let ecc = eccentricStart else {
                    phase = .idle
                    return nil
                }
                concentricStart = now
                phase = .concentric
            }

        case .concentric:
            if value < 0.15 {
                guard let ecc = eccentricStart, let conc = concentricStart else {
                    phase = .idle
                    return nil
                }
                let tfe = conc.timeIntervalSince(ecc)
                let tfc = now.timeIntervalSince(conc)
                phase = .idle
                return (tfe, tfc)
            }
        }
        return nil
    }

    func reset() {
        phase = .idle
        eccentricStart = nil
        concentricStart = nil
    }
}
*/
