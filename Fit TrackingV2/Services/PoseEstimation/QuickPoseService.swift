//
//  QuickPoseService.swift
//  Fit TrackingV2
//
//  Created by Baruck Botton on 3/05/25.
//
import SwiftUI
import QuickPoseCore
import QuickPoseSwiftUI
import ReplayKit

struct QuickPoseService: View {
    private var quickPose = QuickPose(sdkKey: "01JTC3H0M71GVAKTPSMJRCN7K2") // register for your free key at dev.quickpose.ai
    enum SquatPhase { case idle, eccentric, concentric }
    @State private var squatPhase: SquatPhase = .idle
    @State private var eccentricStartTime: Date?
    @State private var concentricStartTime: Date?
    @State private var squatRepsTiempos: [(tfe: Double, tfc: Double)] = []
    @State private var overlayImage: UIImage?
    @State private var feedbackText: String = "Inicia cuando quieras"
    @State private var squatCounter = QuickPoseThresholdCounter()
    @State private var pressCounter = QuickPoseThresholdCounter(enterThreshold: 0.8, exitThreshold: 0.2)
    @Binding var navegarAFinal: Bool
    @ObservedObject var summary: PostureEvaluationSummary
    init(navegarAFinal: Binding<Bool>, summary: PostureEvaluationSummary) {
        self._navegarAFinal = navegarAFinal
        self.summary = summary
    }
    let umbralROM: Double = 0.85
    
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                QuickPoseCameraView(useFrontCamera: true, delegate: quickPose)
                QuickPoseOverlayView(overlayImage: $overlayImage)
                VStack {
                    Spacer()
                    Text(feedbackText)
                        .font(.title2)
                        .padding()
                        .background(Color.black.opacity(0.6))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.bottom, 40)
                Button(action: {
                    quickPose.stop()
                    DispatchQueue.main.async {
                        let valgoEvaluacion = summary.valgoFrameData.evaluar()
                        summary.valgoDetectedLeft = valgoEvaluacion.left
                        summary.valgoDetectedRight = valgoEvaluacion.right
                    }
                       navegarAFinal = true                }) {
                    Text("Finalizar Evaluación")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
                }
            }
            .frame(width: geometry.size.width)
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                summary.inicioEvaluacion = Date()
                quickPose.start(features: [.overlay(.wholeBody), .showPoints(), .fitness(.squats),.rangeOfMotion(.shoulder(side:.left, clockwiseDirection: false)), .rangeOfMotion(.shoulder(side:.right, clockwiseDirection: true))],
                                onFrame: { status, image, features,  feedback, landmarks in
                    if case .success(_) = status {
                        overlayImage = image
                        
                        print("TIPO DE LANDMARKS:", type(of: landmarks))
                        if let squatProgress = features[.fitness(.squats)]{
                            if let squatProgress = features[.fitness(.squats)] {
                                let value = squatProgress.value
                                let now = Date()
                                
                                switch squatPhase {
                                case .idle:
                                    if value < 0.1 {
                                        // Inicia fase excéntrica
                                        eccentricStartTime = now
                                        squatPhase = .eccentric
                                    }
                                    
                                case .eccentric:
                                    if value > 0.9 {
                                        // Cambia a concéntrica
                                        if let start = eccentricStartTime {
                                            let tfe = now.timeIntervalSince(start)
                                            concentricStartTime = now
                                            squatPhase = .concentric
                                            print("🕒 Fase excéntrica: \(tfe)s")
                                        }
                                    }
                                    
                                case .concentric:
                                    if value < 0.1 {
                                        // Fin de repetición
                                        if let start = concentricStartTime {
                                            let tfc = now.timeIntervalSince(start)
                                            if let tfeStart = eccentricStartTime {
                                                let tfe = start.timeIntervalSince(tfeStart)
                                                DispatchQueue.main.async {
                                                    summary.squatRepsTiempos.append((tfe: tfe, tfc: tfc))
                                                }
                                                print("✅ Repetición completa - TFE: \(tfe), TFC: \(tfc)")
                                            }
                                            squatPhase = .idle
                                        }
                                    }
                                }
                            }
                            let reps = squatCounter.count(squatProgress.value)
                            let progress = Int(squatProgress.value*100)
                            feedbackText = "Progreso: \(progress)% | Repeticiones: \(reps.count)"
                        }
                        /*
                         if let romLeft = features[.rangeOfMotion(.shoulder(side: .left, clockwiseDirection: false))],
                         let romRight = features[.rangeOfMotion(.shoulder(side: .right, clockwiseDirection: true))] {
                         
                         let average = (romLeft.value + romRight.value)/2
                         let normalizedValue = average/180.0
                         
                         print("ROM izquierdo: \(romLeft.value)")
                         print("ROM derecho: \(romRight.value)")
                         print("💡 ROM mínimo entre ambos: \(normalizedValue)")
                         
                         if average > umbralROM {
                         let reps = pressCounter.count(normalizedValue)
                         if reps.count > 0 {
                         feedbackText = "🏋️‍♂️ Press Banca: \(reps.count)"
                         print("🏋️‍♂️ Press Banca: \(reps.count)")
                         } else {
                         print("Movimiento válido, pero aún no completaste la repetición")
                         }
                         } else {
                         // ✅ Esta línea solo se mostrará si realmente NO alcanza el umbral
                         print("⚠️ Movimiento no alcanza el umbral de \(umbralROM)")
                         feedbackText = "Inicia cuando quieras"
                         }
                         }
                         */
                        if let landmarks = landmarks {
                            var hayErrores = false

                                // 📌 Detector de Valgo
                                let valgoDetector = ValgoDetector(landmarks: landmarks)
                                if let valgoResult = valgoDetector.evaluate() {
                                    DispatchQueue.main.async {
                                            summary.valgoFrameData.agregar(valgoResult: valgoResult)
                                        }
                                    if valgoResult.leftValgo && valgoResult.rightValgo {
                                        if let inicio = summary.inicioEvaluacion {
                                            let ahora = Date()
                                            let segundos = Int(ahora.timeIntervalSince(inicio))
                                            DispatchQueue.main.async {
                                                if !summary.segundosDeValgo.contains(segundos) {
                                                    summary.segundosDeValgo.append(segundos)
                                                }
                                            }
                                        }
                                    }
                                } else {
                                    print("⚠️ Valgo no evaluado (baja visibilidad)")
                                }

                                // 📌 Detector de Asimetría
                                let asymmetryDetector = AsymmetryDetector(landmarks: landmarks)
                                if let asy = asymmetryDetector.evaluate() {
                                    if asy.overallAsymmetry {
                                        print("⚠️ Asimetría:")
                                        hayErrores = true
                                        if asy.hipAsymmetry {
                                            print("↕️ Desnivel de caderas")
                                            hayErrores = true
                                        }
                                        if asy.kneeAsymmetry {
                                            print("↔️ Desalineación de rodillas")
                                            hayErrores = true
                                        }
                                        if asy.shoulderAsymmetry {
                                            print("↕️ Inclinación de hombros")
                                            hayErrores = true
                                        }
                                    }
                                }

                                // 📌 Detector de Butt Wink
                                let buttWinkDetector = ButtWinkDetector(landmarks: landmarks)
                            if let bw = buttWinkDetector.evaluate(), bw.detected {
                                    print("📉 Butt Wink detectado (retroversión pélvica)")
                                    hayErrores = true
                                }

                                // 📌 Detector de Heel Lift
                                let heelLiftDetector = HeelLiftDetector(landmarks: landmarks)
                                if let hl = heelLiftDetector.evaluate() {
                                    if hl.leftElevated || hl.rightElevated {
                                        print("⚠️ Talón elevado")
                                        hayErrores = true
                                        if hl.leftElevated {
                                            print("🦶 Talón izquierdo elevado")
                                            hayErrores = true
                                        }
                                        if hl.leftElevated && hl.rightElevated {
                                            print("🦶 Talón derecho e izquiedo elevados")
                                            hayErrores = true
                                        }
                                        if hl.rightElevated {
                                            print("🦶 Talón derecho elevado")
                                            hayErrores = true
                                        }
                                    }
                                }
                                    if !hayErrores {
                                    print("✅ Sin errores posturales detectados.")
                                }
                            }
                    }
                })
            }.onDisappear {
                quickPose.stop()
            }
            
        }
    }
}
    
    /*
     private func EstiloRodilla() -> QuickPose.Style {
     return QuickPose.Style(
     relativeFontSize: 0.5,
     relativeArcSize: 0.5,
     relativeLineWidth: 0.5,
     conditionalColors: [
     .init(min: 55, max: 110, color: .green),
     .init(min: nil, max: 55, color: .red),
     .init(min: 110, max: nil, color: .red)
     ]
     )
     }
     private func estiloCadera() -> QuickPose.Style {
     return QuickPose.Style(
     relativeFontSize: 0.5,
     relativeArcSize: 0.5,
     relativeLineWidth: 0.5,
     conditionalColors: [
     .init(min: 60, max: 130, color: .green), // ejemplo
     .init(min: nil, max: 60, color: .red),
     .init(min: 130, max: nil, color: .red)
     ]
     )
     }
     
     private func estiloTobillo() -> QuickPose.Style {
     return QuickPose.Style(
     relativeFontSize: 0.5,
     relativeArcSize: 0.5,
     relativeLineWidth: 0.5,
     conditionalColors: [
     .init(min: 25, max: 60, color: .green), // ejemplo
     .init(min: nil, max: 25, color: .orange),
     .init(min: 60, max: nil, color: .red)
     ]
     )
     }
     
     private func estiloEspalda() -> QuickPose.Style {
     return QuickPose.Style(
     relativeFontSize: 0.5,
     relativeArcSize: 0.5,
     relativeLineWidth: 0.5,
     conditionalColors: [
     .init(min: 0, max: 30, color: .green), // poca inclinación del torso
     .init(min: 30, max: nil, color: .orange)
     ]
     )
     }
     func processVideo(inputURL: URL, completion: @escaping (Result<URL, Error>) -> Void, progressHandler: @escaping (Double) -> Void) {
     let outputURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
     .appendingPathComponent("processed_video.mov")
     
     let request = QuickPosePostProcessor.Request(
     input: inputURL,
     output: outputURL,
     outputType: .mov
     )
     
     let features: [QuickPose.Feature] = [
     .rangeOfMotion(
     .knee(side: .left, clockwiseDirection: true),// <- este es el grupo de landmarks
     style: EstiloRodilla()
     ),
     .rangeOfMotion(
     .knee(side: .right, clockwiseDirection: false),
     style: EstiloRodilla()
     ),
     .rangeOfMotion(.hip(side: .left, clockwiseDirection: false), style: estiloCadera()),
     .rangeOfMotion(.hip(side: .right, clockwiseDirection: true), style: estiloCadera()),
     
     .rangeOfMotion(.ankle(side: .left, clockwiseDirection: true), style: estiloTobillo()),
     .rangeOfMotion(.ankle(side: .right, clockwiseDirection: false), style: estiloTobillo()),
     
     .rangeOfMotion(.back(clockwiseDirection: true), style: estiloEspalda()),
     .overlay(.wholeBody),
     .showPoints(),
     ]
     
     DispatchQueue.global(qos: .userInitiated).async {
     do {
     try self.processor.process(features: features, isFrontCamera: false, request: request) { progress, _, _, _, _, _, _ in
     progressHandler(progress)
     }
     DispatchQueue.main.async {
     completion(.success(outputURL))
     }
     } catch {
     DispatchQueue.main.async {
     completion(.failure(error))
     }
     }
     }
     }
     }
     */
