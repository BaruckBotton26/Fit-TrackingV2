//
//  PostureEvaluationSummary.swift
//  Fit TrackingV2
//
//  Created by Baruck Botton on 18/05/25.
//

import Foundation

class PostureEvaluationSummary: ObservableObject {
    @Published var valgoDetectedLeft = false
    @Published var valgoDetectedRight = false
    @Published var valgoFrameData = ValgoFrameData()
    // Puedes agregar más como asimetría, butt wink, etc.
    @Published var inicioEvaluacion: Date? = nil
    @Published var segundosDeValgo: [Int] = []
    @Published var segundosDeButtWink: [Int] = []
    @Published var squatRepsTiempos: [(tfe: Double, tfc: Double)] = []
    @Published var pushUpRepsTiempos: [(tfe: Double, tfc: Double)] = []
    @Published var bicepCurlReps: [(tfe: Double, tfc: Double)] = []
    @Published var overheadDumbellPressReps: [(tfe: Double, tfc: Double)] = []
    @Published var erroresPorRepeticion: [[String]] = []

}

