# 🏋️ Fit Tracking V2

**Fit Tracking V2** es una aplicación iOS de análisis de ejercicios basada en visión por computadora, que permite detectar errores comunes en la postura durante rutinas físicas mediante el análisis de video y la visualización de puntos clave del cuerpo humano.

## 🚀 ¿Qué hace la app?

- Permite **grabar un video** desde la cámara del dispositivo.
- **usa la cámara en tiempo real**, mediante el sistema de **post-procesamiento de QuickPose**.
- Detecta errores comunes de postura como:
  - 🔴 Profundidad insuficiente
  - 🔴 Rodillas desalineadas
  - 🟡 Pérdida de tensión en el core
- Muestra una vista de retroalimentación visual y textual luego del análisis.
- Usa arquitectura **MVVM** con separación entre vistas, servicios y lógica de procesamiento.

## 🧠 Tecnologías utilizadas

- `SwiftUI`
- `AVFoundation`
- [`QuickPose iOS SDK`](https://quickpose.ai/products/ios-sdk/)
  - QuickPoseCore
  - QuickPoseCamera
- CocoaPods (para manejo de dependencias)

## 🧩 Funcionalidades implementadas

| Funcionalidad                  | Estado  |
|-------------------------------|---------|
| Grabación de video            | ✅      |
| Post-procesamiento del video  | ✅      |
| Análisis y retroalimentación  | ✅      |
| Navegación entre vistas       | ✅      |

## 📈 Avances semanales

- **Semana actual:** Integración completa con el SDK de QuickPose para post-procesamiento y visualización de articulaciones.
- Se reemplazó MediaPipe por QuickPose para mejorar rendimiento y control en dispositivos iOS.
- Se logró representar con éxito los **33 puntos clave del cuerpo humano**, incluyendo pies y manos.
- Se automatizó la navegación a la vista de Feedback tras el procesamiento del video.
- Implementación de lógica visual de retroalimentación (errores y recomendaciones).

## 📱 Captura de pantalla

![image](https://github.com/user-attachments/assets/ce1f2c19-6ee3-4e4b-bb63-8d80c1786477)

![image](https://github.com/user-attachments/assets/a4252d8c-8689-41df-99b0-a75ec929c533)

![image](https://github.com/user-attachments/assets/75996a0b-da08-44b0-be67-5a4f5ea6599d)

## 🗂️ Estructura del proyecto

FitTrackingV2/
│
├── Services/ # QuickPoseService, manejo del procesamiento
├── ViewModels/ # Lógica de estado (Feedback, Inicio, QuickPose)
├── Views/ # SwiftUI views (EvaluacionView, FeedbackView, etc.)
├── Assets/ # Recursos visuales y configuraciones
└── Pods/ # Dependencias gestionadas por CocoaPods


## 📋 Requisitos

- iOS 14.0+
- Xcode 15+
- SDK Key de QuickPose (gratis en [https://dev.quickpose.ai](https://dev.quickpose.ai))

## 🧪 Próximos pasos

- Añadir métricas cuantitativas del desempeño (repeticiones, rango de movimiento)
- Implementar exportación o reporte de resultados.
- Mejorar el sistema de retroalimentación con IA más especializada por ejercicio.
- Posible soporte multiplataforma en versiones futuras.

---

🎯 *Este proyecto forma parte de una tesis orientada al análisis automatizado de movimientos físicos y corrección de posturas utilizando visión por computadora y modelos de pose estimation.*
