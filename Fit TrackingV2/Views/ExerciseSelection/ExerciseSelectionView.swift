//
//  ExerciseSelectionView.swift
//  Fit TrackingV2
//
//  Created by Baruck Botton on 25/05/25.
//
import SwiftUI

enum ExerciseType: Hashable {
    case squat, pushUp, bicepCurl, overheadDumbellPress
}
struct ExerciseSelectionView: View {
    @State private var selectedExercise: ExerciseType? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) { // Reducido de 40 a 20
                Text("Selecciona tu ejercicio")
                    .font(.title)
                    .bold()
                    .padding(.bottom, 60)

                ForEach([
                    (ExerciseType.squat, "Sentadillas"),
                    (ExerciseType.pushUp, "Flexiones"),
                    (ExerciseType.bicepCurl, "Curl de bíceps"),
                    (ExerciseType.overheadDumbellPress, "Press militar")
                ], id: \.0) { type, title in
                    NavigationLink(
                        destination: EvaluacionView(exercise: type),
                        tag: type,
                        selection: $selectedExercise
                    ) {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 	40)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                            .shadow(radius: 1)
                            .accessibilityIdentifier("button_\(type)")
                    }
                }
            }
            .padding(.bottom, 200)
            .frame(maxWidth: 350)
            .frame(maxHeight: .infinity, alignment: .center) // Centrado vertical
            .background(Color.white)
        }
    }
}
/*
struct ExerciseSelectionView: View {
    @State private var selectedExercise: ExerciseType? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Text("Selecciona el ejercicio")
                    .font(.title)
                    .bold()

                NavigationLink(
                    destination: EvaluacionView(exercise: .squat),
                    tag: ExerciseType.squat,
                    selection: $selectedExercise
                ) {
                    Text("Sentadillas")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }

                NavigationLink(
                    destination: EvaluacionView(exercise: .pushUp),
                    tag: ExerciseType.pushUp,
                    selection: $selectedExercise
                ) {
                    Text("Flexiones")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                NavigationLink(
                    destination: EvaluacionView(exercise: .bicepCurl),
                    tag: ExerciseType.bicepCurl,
                    selection: $selectedExercise
                ) {
                    Text("Curl de Bíceps")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                NavigationLink(
                    destination: EvaluacionView(exercise: .overheadDumbellPress),
                    tag: ExerciseType.overheadDumbellPress,
                    selection: $selectedExercise
                ) {
                    Text("Press Militar")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
            }
            .padding()
        }
    }
}
*/
#Preview {
    ExerciseSelectionView()
}
