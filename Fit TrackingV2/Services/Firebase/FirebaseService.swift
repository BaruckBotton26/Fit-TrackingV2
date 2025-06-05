//
//  FirebaseService.swift
//  Fit TrackingV2
//
//  Created by Baruck Botton on 26/05/25.
//
import Foundation
import FirebaseFirestore

class FirebaseService {
    static let shared = FirebaseService()
    private let db = Firestore.firestore()

    private init() {}

    func guardarEvaluacion(
        ejercicio: String,
        repeticiones: [(tfe: Double, tfc: Double)],
        errores: [String: Any] = [:]
    ) {
        let fecha = Date()

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_PE")
        formatter.timeZone = TimeZone(identifier: "America/Lima")
        formatter.dateFormat = "d-MM-yyyy_HH-mm-ss" // ejemplo: 1-06-2025_21-12-07

        let fechaFormateada = formatter.string(from: fecha)
        let idDocumento = "\(ejercicio)_\(fechaFormateada)"
        
        let datos: [String: Any] = [
            "ejercicio": ejercicio,
            "fecha": Timestamp(date: Date()),
            "repeticiones": repeticiones.enumerated().map { (index, rep) in
                return [
                    "repeticion": index + 1, // 👈 Esto hace que empiece en 1
                    "fase_excéntrica": rep.tfe,
                    "fase_concéntrica": rep.tfc
                ]
            },
            "errores": errores
        ]

        db.collection("evaluaciones").document(idDocumento).setData(datos) { error in
            if let error = error {
                print("❌ Error al guardar evaluación: \(error.localizedDescription)")
            } else {
                print("✅ Evaluación guardada correctamente")
            }
        }
    }
}

