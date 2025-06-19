//
//  FeedbackView.swift
//  Fit TrackingV2
//
//  Created by Baruck Botton on 1/05/25.
//

import SwiftUI
import AVKit

struct FeedbackView: View {
    @ObservedObject var summary: PostureEvaluationSummary
    @StateObject private var viewModel = FeedbackViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // 🔹 Card 1: Nombre del ejercicio
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                            .shadow(radius: 4)
                        Text("Análisis del ejercicio:")
                            .font(.title3)
                            .fontWeight(.bold)
                            .padding()
                            .accessibilityIdentifier("feedbackViewLabel")
                    }
                    .padding(.horizontal)

                    // 🔹 Card 2: Repeticiones
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                            .shadow(radius: 4)
                        VStack(alignment: .leading, spacing: 10) {
                            if !summary.squatRepsTiempos.isEmpty {
                                Text("⏱ Repeticiones - Sentadillas:")
                                    .font(.headline)
                                ForEach(Array(summary.squatRepsTiempos.enumerated()), id: \.offset) { (index, rep) in
                                    let ice = rep.tfc > 0 ? rep.tfe / rep.tfc : 0.0
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Repetición \(index + 1):")
                                            .fontWeight(.semibold)
                                        Text(String(format: "• Fase excéntrica: %.2fs", rep.tfe))
                                        Text(String(format: "• Fase concéntrica: %.2fs", rep.tfc))
                                        Text(String(format: "• ICE: %.2f", ice))
                                        if index < summary.erroresPorRepeticion.count {
                                            let errores = summary.erroresPorRepeticion[index]
                                            if errores.isEmpty {
                                                Text("✅ Sin errores posturales detectados.")
                                                    .foregroundColor(.green)
                                            } else {
                                                ForEach(errores, id: \.self) { error in
                                                    Text("⚠️ \(error)")
                                                        .foregroundColor(.red)
                                                }
                                            }
                                        }
                                    }
                                    .padding(.bottom, 6)
                                }
                            }

                            if !summary.pushUpRepsTiempos.isEmpty {
                                Text("💪 Flexiones:")
                                    .font(.headline)
                                ForEach(Array(summary.pushUpRepsTiempos.enumerated()), id: \.offset) { (index, rep) in
                                    let ice = rep.tfc > 0 ? rep.tfe / rep.tfc : 0.0
                                    Text(String(format: "Repetición %d: Fase descendente: %.2fs | Fase ascendente: %.2fs | ICE: %.2f", index + 1, rep.tfe, rep.tfc, ice))
                                }
                            }

                            if !summary.bicepCurlReps.isEmpty {
                                Text("💪 Curl de Bíceps:")
                                    .font(.headline)
                                ForEach(Array(summary.bicepCurlReps.enumerated()), id: \.offset) { (index, rep) in
                                    let ice = rep.tfc > 0 ? rep.tfe / rep.tfc : 0.0
                                    Text(String(format: "Repetición %d: Fase excéntrica: %.2fs | Fase concéntrica: %.2fs | ICE: %.2f", index + 1, rep.tfe, rep.tfc, ice))
                                }
                            }

                            if !summary.overheadDumbellPressReps.isEmpty {
                                Text("💪 Press Militar:")
                                    .font(.headline)
                                ForEach(Array(summary.overheadDumbellPressReps.enumerated()), id: \.offset) { (index, rep) in
                                    let ice = rep.tfc > 0 ? rep.tfe / rep.tfc : 0.0
                                    Text(String(format: "Repetición %d: Fase excéntrica: %.2fs | Fase concéntrica: %.2fs | ICE: %.2f", index + 1, rep.tfe, rep.tfc, ice))
                                }
                            }
                        }
                        .padding()
                    }
                    .padding(.horizontal)

                    // 🔹 Card 3: Errores detectados
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                            .shadow(radius: 4)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("🩺 Errores detectados:")
                                .font(.headline)
                            let valgoFinal = summary.valgoFrameData.evaluar(threshold: 0.6)

                            if valgoFinal.left || valgoFinal.right {
                                Text("🔴 Se detectó valgo en la mayoría de la ejecución.")
                                if !summary.segundosDeValgo.isEmpty {
                                    ForEach(summary.segundosDeValgo.sorted(), id: \.self) { segundo in
                                        let minutos = segundo / 60
                                        let segundos = segundo % 60
                                        Text(String(format: "- %02d:%02d ⚠️ Valgo bilateral", minutos, segundos))
                                    }
                                }
                            } else if !summary.segundosDeButtWink.isEmpty {
                                Text("📉 Butt Wink (retroversión pélvica):")
                                ForEach(summary.segundosDeButtWink.sorted(), id: \.self) { segundo in
                                    let minutos = segundo / 60
                                    let segundos = segundo % 60
                                    Text(String(format: "- %02d:%02d 📉 Butt Wink detectado", minutos, segundos))
                                }
                            } else {
                                Text("✅ Sin errores detectados.")
                                    .foregroundColor(.green)
                            }
                        }
                        .padding()
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
            }

        }
    }
}

/*
struct FeedbackView: View {
    @ObservedObject var summary: PostureEvaluationSummary
    @StateObject private var viewModel = FeedbackViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    
                    // 📌 SENTADILLAS
                    if !summary.squatRepsTiempos.isEmpty {
                        
                        Text("⏱ Tiempos por repetición - Sentadillas:")
                            .font(.headline)
                            .padding(.bottom, 4)
                        
                        ForEach(Array(summary.squatRepsTiempos.enumerated()), id: \.offset) { (index, rep) in
                            let ice = rep.tfc > 0 ? rep.tfe / rep.tfc : 0.0
                            VStack(alignment: .leading, spacing: 2) {
                                Text(String(format: "- Repetición %d:", index + 1))
                                    .fontWeight(.semibold)
                                Text(String(format: "   • Fase excéntrica: %.2fs", rep.tfe))
                                Text(String(format: "   • Fase concéntrica: %.2fs", rep.tfc))
                                Text(String(format: "   • ICE: %.2f", ice))

                                if index < summary.erroresPorRepeticion.count {
                                    let errores = summary.erroresPorRepeticion[index]
                                    if errores.isEmpty {
                                        Text("   ✅ Sin errores posturales detectados.")
                                            .foregroundColor(.green)
                                    } else {
                                        Text("   ⚠️ Errores detectados:")
                                            .foregroundColor(.red)
                                        ForEach(errores, id: \.self) { error in
                                            Text("      • \(error)")
                                                .foregroundColor(.red)
                                        }
                                    }
                                }
                            }
                            .padding(.bottom, 6)
                        }
                    }

                    if !summary.pushUpRepsTiempos.isEmpty {
                        Text("💪 Análisis profundo de repeticiones - Flexiones:")
                            .font(.headline)
                            .padding(.bottom, 4)
                        
                        ForEach(Array(summary.pushUpRepsTiempos.enumerated()), id: \.offset) { (index, rep) in
                            let ice = rep.tfc > 0 ? rep.tfe / rep.tfc : 0.0
                            Text(String(format: "- Repetición %d:\n   • Fase descendente: %.2fs\n   • Fase ascendente: %.2fs\n   • ICE: %.2f",
                                        index + 1, rep.tfe, rep.tfc, ice))
                                .padding(.bottom, 4)
                        }
                    }

                    if !summary.bicepCurlReps.isEmpty {
                        Text("💪 Análisis profundo de repeticiones - Curl de Bíceps:")
                            .font(.headline)
                            .padding(.bottom, 4)
                        
                        ForEach(Array(summary.bicepCurlReps.enumerated()), id: \.offset) { (index, rep) in
                            let ice = rep.tfc > 0 ? rep.tfe / rep.tfc : 0.0
                            Text(String(format: "- Repetición %d:\n   • Fase excéntrica: %.2fs\n   • Fase concéntrica: %.2fs\n   • ICE: %.2f",
                                        index + 1, rep.tfe, rep.tfc, ice))
                                .padding(.bottom, 4)
                        }
                    }
                    if !summary.overheadDumbellPressReps.isEmpty {
                        Text("💪 Análisis profundo de repeticiones - Press Militar:")
                            .font(.headline)
                            .padding(.bottom, 4)

                        ForEach(Array(summary.overheadDumbellPressReps.enumerated()), id: \.offset) { (index, rep) in
                            let ice = rep.tfc > 0 ? rep.tfe / rep.tfc : 0.0
                            VStack(alignment: .leading, spacing: 2) {
                                Text(String(format: "- Repetición %d:", index + 1))
                                    .fontWeight(.semibold)
                                Text(String(format: "   • Fase excéntrica: %.2fs", rep.tfe))
                                Text(String(format: "   • Fase concéntrica: %.2fs", rep.tfc))
                                Text(String(format: "   • ICE: %.2f", ice))
                            }
                            .padding(.bottom, 6)
                        }
                    }

                    Text("🩺 Errores detectados:")
                        .font(.headline)
                    
                    let valgoFinal = summary.valgoFrameData.evaluar(threshold: 0.6)
                    
                    if valgoFinal.left || valgoFinal.right {
                        Text("🔴 Se detectó valgo en la mayoría de la ejecución.")
                        if !summary.segundosDeValgo.isEmpty {
                            Text("⏱ Momentos con valgo bilateral:")
                                .font(.subheadline)
                                .padding(.top, 4)
                            
                            ForEach(summary.segundosDeValgo.sorted(), id: \.self) { segundo in
                                let minutos = segundo / 60
                                let segundos = segundo % 60
                                Text(String(format: "- %02d:%02d ⚠️ Valgo en ambas rodillas", minutos, segundos))
                            }
                        }
                    }else if !summary.segundosDeButtWink.isEmpty {
                        Text("⏱ Momentos con Butt Wink (retroversión pélvica):")
                            .font(.subheadline)
                            .padding(.top, 4)
                        
                        ForEach(summary.segundosDeButtWink.sorted(), id: \.self) { segundo in
                            let minutos = segundo / 60
                            let segundos = segundo % 60
                            Text(String(format: "- %02d:%02d 📉 Butt Wink detectado", minutos, segundos))
                        }
                    }
                    else if !summary.squatRepsTiempos.isEmpty {
                        Text("✅ Buena ejecución de sentadillas. (Sin errores posturales detectados)")
                    }

                    // 📌 MENSAJES FIJOS SI NO HAY DETECTORES PARA PUSHUPS O CURLS
                    if !summary.pushUpRepsTiempos.isEmpty {
                        Text("✅ Buena ejecución de flexiones.")
                            .padding(.top, 8)
                    }

                    if !summary.bicepCurlReps.isEmpty {
                        Text("✅ Buena ejecución de curl de bíceps.")
                            .padding(.top, 8)
                    }
                    if !summary.overheadDumbellPressReps.isEmpty {
                        Text("✅ Buena ejecución de Press Militar.")
                            .padding(.top, 8)
                    }
                }
                .padding()
            }
        }
    }
}
*/
#Preview {
    let mockSummary = PostureEvaluationSummary()
    return FeedbackView(summary: mockSummary)
}
