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
    private var quickPose = QuickPose(sdkKey: "01JTC3H0M71GVAKTPSMJRCN7K2")
    let exercise: ExerciseType
    enum PushUpPhase { case idle, lowering, pushing }
    @State private var mostrarIndicadorFinalizar = false
    @State private var ultimaConfirmacion = Date()
    @State private var ultimaLandmarks: QuickPose.Landmarks?
    @State private var inicioReposo: Date?
    @State private var pushUpPhase: PushUpPhase = .idle
    @State private var pushDownStart: Date?
    @State private var pushUpStart: Date?
    @State private var pushUpRepsTiempos: [(tfe: Double, tfc: Double)] = []
    @State private var pushUpCounter = QuickPoseThresholdCounter()
    enum SquatPhase { case idle, eccentric, concentric }
    @State private var squatTracker = SquatPhaseTracker()
    @State private var pushUpTracker = PushUpPhaseTracker()
    @State private var squatPhase: SquatPhase = .idle
    @State private var eccentricStartTime: Date?
    @State private var concentricStartTime: Date?
    @State private var bicepCurlTracker = BicepCurlTracker()
    @State private var bicepCounter = QuickPoseThresholdCounter()
    @State private var squatRepsTiempos: [(tfe: Double, tfc: Double)] = []
    @State private var overlayImage: UIImage?
    @State private var evaluacionIniciada = false
    @State private var thumbsUpDetector = QuickPoseDoubleUnchangedDetector(similarDuration: 1.5)
    @State private var feedbackText: String = "Haz 👍 para comenzar"
    @State private var squatCounter = QuickPoseThresholdCounter()
    @State private var pressCounter = QuickPoseThresholdCounter(enterThreshold: 0.8, exitThreshold: 0.2)
    @State private var erroresPorRepeticion: [String] = []
    @State private var erroresDetectadosActuales: Set<String> = []
    @State private var erroresFrameRepeticion: [String: Int] = [:]
    @State private var totalFramesRepeticion: Int = 0
    @State private var overheadDumbellPressTracker = OverheadDumbbellPressTracker()
    @State private var overheadDumbellCounter = QuickPoseThresholdCounter()
    @State private var valgoFramesSeguidos = 0
    let umbralValgoFrames = 10

    @Binding var navegarAFinal: Bool
    @ObservedObject var summary: PostureEvaluationSummary
    init(navegarAFinal: Binding<Bool>, summary: PostureEvaluationSummary, exercise: ExerciseType) {
        self._navegarAFinal = navegarAFinal
        self.summary = summary
        self.exercise = exercise
    }
    let umbralROM: Double = 0.85
    func exportarResultadosACSV() {
        let fileManager = FileManager.default
        let docsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = docsURL.appendingPathComponent("resultado_biomecanico.csv")

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let fecha = formatter.string(from: Date())

        // Cabecera
        let headers = "Fecha,Ejercicio,Repeticiones,ValgoIzq,ValgoDer,ValgoBilateral,ButtWink,SegundosValgo,SegundosButtWink\n"

        // Repeticiones por tipo de ejercicio
        let repeticiones: [(Double, Double)]
        switch exercise {
        case .squat:
            repeticiones = summary.squatRepsTiempos
        case .pushUp:
            repeticiones = summary.pushUpRepsTiempos
        case .bicepCurl:
            repeticiones = summary.bicepCurlReps
        case .overheadDumbellPress:
            repeticiones = summary.overheadDumbellPressReps
        }

        // Valgo bilateral
        let valgoBilateral = summary.valgoDetectedLeft && summary.valgoDetectedRight

        // Convertir arrays en strings legibles
        let segundosValgo = summary.segundosDeValgo.sorted().map { String($0) }.joined(separator: "-")
        let segundosButtWink = summary.segundosDeButtWink.sorted().map { String($0) }.joined(separator: "-")

        // Fila de datos con orden correcto
        let row = "\(fecha),\(exercise),\(repeticiones.count),\(summary.valgoDetectedLeft),\(summary.valgoDetectedRight),\(valgoBilateral),\(!summary.segundosDeButtWink.isEmpty),\"\(segundosValgo)\",\"\(segundosButtWink)\"\n"

        // Crear archivo si no existe
        if !fileManager.fileExists(atPath: fileURL.path) {
            do {
                try headers.write(to: fileURL, atomically: true, encoding: .utf8)
            } catch {
                print("❌ Error al crear archivo CSV: \(error.localizedDescription)")
            }
        }

        // Añadir fila al archivo
        do {
            let fileHandle = try FileHandle(forWritingTo: fileURL)
            fileHandle.seekToEndOfFile()
            if let data = row.data(using: .utf8) {
                fileHandle.write(data)
            }
            fileHandle.closeFile()
            print("✅ CSV guardado automáticamente: \(fileURL.path)")
        } catch {
            print("❌ Error al guardar CSV: \(error.localizedDescription)")
        }
    }
    private func guardarEnFirebaseYFinalizar() {
        let valgoEvaluacion = summary.valgoFrameData.evaluar()
        summary.valgoDetectedLeft = valgoEvaluacion.left
        summary.valgoDetectedRight = valgoEvaluacion.right

        var errores: [String: Any] = [:]
        if exercise == .squat {
            errores["valgo_detectado"] = valgoEvaluacion.left || valgoEvaluacion.right
            errores["segundosDeValgo"] = summary.segundosDeValgo.sorted()
            errores["buttWink_detectado"] = !summary.segundosDeButtWink.isEmpty
            errores["segundosDeButtWink"] = summary.segundosDeButtWink.sorted()
        }

        var repeticiones: [(Double, Double)] = []
        switch exercise {
        case .squat: repeticiones = summary.squatRepsTiempos
        case .pushUp: repeticiones = summary.pushUpRepsTiempos
        case .bicepCurl: repeticiones = summary.bicepCurlReps
        case .overheadDumbellPress: repeticiones = summary.overheadDumbellPressReps
        }

        FirebaseService.shared.guardarEvaluacion(
            ejercicio: String(describing: exercise),
            repeticiones: repeticiones,
            errores: errores
        )
        exportarResultadosACSV()
    }
    func hayMovimiento(actuales: QuickPose.Landmarks?, anteriores: QuickPose.Landmarks?, umbral: Double = 0.02) -> Bool {
        guard let actuales = actuales, let anteriores = anteriores else { return true }

        // Lista de puntos clave a comparar
        let puntosClave: [QuickPose.Landmarks.Body] = [
            .shoulder(side: .left), .shoulder(side: .right),
            .hip(side: .left), .hip(side: .right),
            .knee(side: .left), .knee(side: .right),
            .elbow(side: .left), .elbow(side: .right),
            .wrist(side: .left), .wrist(side: .right)
        ]

        for punto in puntosClave {
            let actual = actuales.landmark(forBody: punto)
            let anterior = anteriores.landmark(forBody: punto)

            let dx = actual.x - anterior.x
            let dy = actual.y - anterior.y

            if abs(dx) > umbral || abs(dy) > umbral {
                return true // Se detectó movimiento
            }
        }

        return false // Quietud total
    }
    
    func detectarErroresPosturales(landmarks: QuickPose.Landmarks?) -> [String] {
        guard let landmarks = landmarks else { return [] }
        var errores: [String] = []

        if let buttWink = ButtWinkDetector(landmarks: landmarks).evaluate(), buttWink.detected {
            errores.append("Butt Wink (retroversión pélvica)")
            if let inicio = summary.inicioEvaluacion {
                let ahora = Date()
                let segundos = Int(ahora.timeIntervalSince(inicio))
                DispatchQueue.main.async{
                    if !summary.segundosDeButtWink.contains(segundos) {
                        summary.segundosDeButtWink.append(segundos)
                    }
                }
            }
        }

        if let valgo = ValgoDetector(landmarks: landmarks).evaluate() {
            if valgo.leftValgo && valgo.rightValgo {
                errores.append("Valgo bilateral")
                if let inicio = summary.inicioEvaluacion {
                    let ahora = Date()
                    let segundos = Int(ahora.timeIntervalSince(inicio))
                    DispatchQueue.main.async{
                        if !summary.segundosDeValgo.contains(segundos) {
                            summary.segundosDeValgo.append(segundos)
                        }
                    }
                }
            }
        }

        return errores
    }

    
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
                        guardarEnFirebaseYFinalizar()
                       navegarAFinal = true
                    }
                    }) {
                    Text("Finalizar Evaluación")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .accessibilityIdentifier("FinalizarEvaluationButton")
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
                }
            }
            .frame(width: geometry.size.width)
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                quickPose.start(features: [.thumbsUp()], onFrame: { status, image, features, feedback, landmarks in
                    switch status {
                    case .success:
                        overlayImage = image
                        if !evaluacionIniciada {
                            if let result = features[.thumbsUp()] {
                                print("👍 Valor detectado: \(result.value)")
                                thumbsUpDetector.count(result: result.value) {
                                    if result.value > 0.5 {
                                        print("👍 Pulgar arriba detectado. Iniciando evaluación...")
                                        evaluacionIniciada = true
                                        summary.inicioEvaluacion = Date()
                                        feedbackText = "Comienza el ejercicio"
                                        var selectedFeatures: [QuickPose.Feature] = [
                                            .overlay(.wholeBody),
                                            .showPoints()
                                        ]
                                        
                                        switch exercise {
                                        case .squat:
                                            selectedFeatures.append(.fitness(.squats))
                                        case .pushUp:
                                            selectedFeatures.append(.fitness(.pushUps))
                                        case .bicepCurl:
                                            selectedFeatures.append(.fitness(.bicepCurls))
                                        case .overheadDumbellPress:
                                            selectedFeatures.append(.fitness(.overheadDumbbellPress))
                                        }
                                        quickPose.update(features: selectedFeatures)
                                    }
                                }
                            }
                        } else {
                            
                            /*
                             summary.inicioEvaluacion = Date()
                             var selectedFeatures: [QuickPose.Feature] = [
                             .overlay(.wholeBody),
                             .showPoints()
                             ]
                             
                             switch exercise {
                             case .squat:
                             selectedFeatures.append(.fitness(.squats))
                             case .pushUp:
                             selectedFeatures.append(.fitness(.pushUps))
                             case .bicepCurl:
                             selectedFeatures.append(.fitness(.bicepCurls))
                             
                             }
                             
                             quickPose.start(features: selectedFeatures, onFrame: { status, image, features, feedback, landmarks in
                             if case .success(_) = status{
                             overlayImage = image
                             
                             print("TIPO DE LANDMARKS:", type(of: landmarks))
                             */
                            guard let landmarks = landmarks else { return }
                            if evaluacionIniciada {
                                if let prevLandmarks = ultimaLandmarks,
                                   !hayMovimiento(actuales: landmarks, anteriores: prevLandmarks) {
                                    
                                    if inicioReposo == nil {
                                        inicioReposo = Date()
                                    }
                                    
                                    let tiempoReposo = Date().timeIntervalSince(inicioReposo!)
                                    
                                    if tiempoReposo > 5.0 {
                                        mostrarIndicadorFinalizar = true
                                        
                                        if Date().timeIntervalSince(ultimaConfirmacion) > 3.0 {
                                            DispatchQueue.main.async {
                                            quickPose.stop()
                                            guardarEnFirebaseYFinalizar()
                                            feedbackText = "✅ Evaluación finalizada por quietud"
                                            navegarAFinal = true
                                            return
                                        }
                                        }
                                    }
                                } else {
                                    mostrarIndicadorFinalizar = false
                                    inicioReposo = nil
                                    ultimaConfirmacion = Date()
                                }
                                
                                ultimaLandmarks = landmarks
                            }

                            let erroresFrame = detectarErroresPosturales(landmarks: landmarks)
                            erroresDetectadosActuales.formUnion(erroresFrame)
                            for error in erroresFrame {
                                erroresFrameRepeticion[error, default: 0] += 1
                            }
                            totalFramesRepeticion += 1

                            let valgoDetector = ValgoDetector(landmarks: landmarks)
                            if let valgo = valgoDetector.evaluate() {
                                if valgo.leftValgo && valgo.rightValgo {
                                    valgoFramesSeguidos += 1
                                } else {
                                    valgoFramesSeguidos = 0
                                }
                                
                                if valgoFramesSeguidos >= umbralValgoFrames {
                                    if let inicio = summary.inicioEvaluacion {
                                        let ahora = Date()
                                        let segundos = Int(ahora.timeIntervalSince(inicio))
                                        DispatchQueue.main.async {
                                            if let ultimo = summary.segundosDeValgo.last {
                                                if segundos - ultimo >= 2 {
                                                    summary.segundosDeValgo.append(segundos)
                                                }
                                            } else {
                                                summary.segundosDeValgo.append(segundos)
                                            }
                                        }
                                    }
                                }
                            }
                            if exercise == .squat, let squatProgress = features[.fitness(.squats)]{
                                let value = squatProgress.value
                                let now = Date()
                                
                                
                                if let resultado = squatTracker.procesar(value: value, now: now) {
                                    var erroresFinales: [String] = []

                                    for (error, count) in erroresFrameRepeticion {
                                        let porcentaje = Double(count) / Double(max(totalFramesRepeticion, 1))
                                        
                                        if error == "Valgo bilateral" {
                                            if porcentaje >= 0.6 {
                                                erroresFinales.append(error)
                                            }
                                        } else {
                                            // Cualquier otro error (como Butt Wink) lo agregamos si apareció al menos 1 vez
                                            erroresFinales.append(error)
                                        }
                                    }

                                    DispatchQueue.main.async {
                                        print("Repetición \(summary.squatRepsTiempos.count + 1) - errores:", erroresFinales)
                                        summary.squatRepsTiempos.append(resultado)
                                        summary.erroresPorRepeticion.append(erroresFinales)
                                        erroresFrameRepeticion = [:]
                                        totalFramesRepeticion = 0
                                        print("✅ Repetición registrada con tracker - TFE: \(resultado.tfe), TFC: \(resultado.tfc)")
                                    }
                                }
                                
                                let reps = squatCounter.count(squatProgress.value)
                                let progress = Int(squatProgress.value*100)
                                feedbackText = "Progreso: \(progress)% | Repeticiones: \(reps.count)"
                            }
                            if let pushUpProgress = features[.fitness(.pushUps)] {
                                let value = pushUpProgress.value
                                let now = Date()
                                
                                if let resultado = pushUpTracker.procesar(value: value, now: now) {
                                    DispatchQueue.main.async {
                                        summary.pushUpRepsTiempos.append(resultado)
                                        print("✅ Push-Up registrada: TFE: \(resultado.tfe), TFC: \(resultado.tfc)")
                                    }
                                }
                                
                                let reps = pushUpCounter.count(value)
                                let progress = Int(value * 100)
                                feedbackText = "➡️ progreso: \(progress)% | Repeticiones: \(reps.count)"
                            }
                            if exercise == .bicepCurl, let curlProgress = features[.fitness(.bicepCurls)] {
                                let value = curlProgress.value
                                let now = Date()
                                
                                if let resultado = bicepCurlTracker.procesar(value: value, now: now) {
                                    DispatchQueue.main.async {
                                        summary.bicepCurlReps.append(resultado)
                                        print("✅ Curl registrada: TFE: \(resultado.tfe), TFC: \(resultado.tfc)")
                                    }
                                }
                                
                                let reps = bicepCounter.count(value)
                                let progress = Int(value * 100)
                                feedbackText = "💪progreso: \(progress)% | Repeticiones: \(reps.count)"
                            }
                            if exercise == .overheadDumbellPress, let DumbellProgress = features[.fitness(.overheadDumbbellPress)]{
                                let value = DumbellProgress.value
                                let now = Date()
                                
                                if let resultado = overheadDumbellPressTracker.procesar(value: value, now: now) {
                                    DispatchQueue.main.async {
                                        summary.overheadDumbellPressReps.append(resultado)
                                        print("✅ Dumbell registrada: TFE: \(resultado.tfe), TFC: \(resultado.tfc)")
                                    }
                                }
                                let reps = overheadDumbellCounter.count(value)
                                let progress = Int(value * 100)
                                feedbackText = "💪 progreso: \(progress)% | Repeticiones: \(reps.count)"
                            }
                            
                            if exercise == .squat{
                                    var hayErrores = false
                                    
                                    // 📌 Detector de Valgo
                                var valgoFramesSeguidos = 0
                                let umbralValgoFrames = 5  // Puedes ajustar esto

                                // Dentro de tu loop de análisis de frame:
                                let valgoDetector = ValgoDetector(landmarks: landmarks)
                                if let valgoResult = valgoDetector.evaluate() {
                                    // 1. Guardar para evaluación por porcentaje al final
                                    DispatchQueue.main.async {
                                        summary.valgoFrameData.agregar(valgoResult: valgoResult)
                                    }
                                    
                                    // 2. Detectar valgo bilateral sostenido
                                    if valgoResult.leftValgo && valgoResult.rightValgo {
                                        valgoFramesSeguidos += 1
                                    } else {
                                        valgoFramesSeguidos = 0
                                    }
                                    
                                    if valgoFramesSeguidos >= umbralValgoFrames {
                                        if let inicio = summary.inicioEvaluacion {
                                            let ahora = Date()
                                            let segundos = Int(ahora.timeIntervalSince(inicio))
                                            DispatchQueue.main.async {
                                                if let ultimo = summary.segundosDeValgo.last {
                                                    if segundos - ultimo >= 2 {
                                                        summary.segundosDeValgo.append(segundos)
                                                    }
                                                } else {
                                                    summary.segundosDeValgo.append(segundos)
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
                                        
                                        if let inicio = summary.inicioEvaluacion {
                                            let ahora = Date()
                                            let segundos = Int(ahora.timeIntervalSince(inicio))
                                            DispatchQueue.main.async {
                                                if !summary.segundosDeButtWink.contains(segundos){
                                                    summary.segundosDeButtWink.append(segundos)
                                                }
                                            }
                                        }
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
                            
                        }
                    case .noPersonFound:
                        if features[.thumbsUp()] == nil {
                                feedbackText = "Ubícate frente a la cámara"
                            }
                                        case .sdkValidationError:
                                            feedbackText = "Error con QuickPose"
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
