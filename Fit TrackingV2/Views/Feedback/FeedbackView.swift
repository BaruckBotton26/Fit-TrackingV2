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
        NavigationView{
            ScrollView{
                VStack(alignment: .leading, spacing: 12) {
                    if !summary.squatRepsTiempos.isEmpty {
                            Text("⏱ Tiempos por repetición:")
                                .font(.headline)
                                .padding(.bottom, 4)

                            ForEach(Array(summary.squatRepsTiempos.enumerated()), id: \.offset) { (index, rep) in
                                let ice = rep.tfc > 0 ? rep.tfe / rep.tfc : 0.0
                                Text(String(format: "- Repetición %d:\n   • Fase excéntrica: %.2fs\n   • Fase concéntrica: %.2fs\n   • ICE: %.2f",
                                            index + 1, rep.tfe, rep.tfc, ice))
                                    .padding(.bottom, 4)
                            }
                        }
                    Text("Errores detectados:")
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
                    } else {
                        Text("✅ Buena alineación de rodillas durante la ejecución.")
                    }
                    
                    // Aquí puedes agregar evaluaciones similares si agregas más detectores a summary
                }
            }
        }
    }
}
    #Preview {
        let mockSummary = PostureEvaluationSummary()
        return FeedbackView(summary: mockSummary)
    }


