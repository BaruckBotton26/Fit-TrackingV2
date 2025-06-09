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

- **Semana Anteriores:** Integración completa con el SDK de QuickPose para post-procesamiento y visualización de articulaciones.
- Se reemplazó MediaPipe por QuickPose para mejorar rendimiento y control en dispositivos iOS.
- Se logró representar con éxito los **33 puntos clave del cuerpo humano**, incluyendo pies y manos.
- Se automatizó la navegación a la vista de Feedback tras el procesamiento del video.
- Implementación de lógica visual de retroalimentación (errores y recomendaciones).
- **Semana actual:** Finalización automática de la evaluación mediante detección de quietud corporal prolongada.
- Se implementó lógica para detectar 5 segundos de reposo seguidos de 3 segundos sin movimiento para finalizar sin necesidad de presionar un botón.
- Se mantiene opción de finalización manual mediante botón visible durante la evaluación.
- Evaluación de repeticiones y errores posturales ahora ocurre solo tras detectar el gesto de pulgar arriba.
- Se optimizó la detección de errores como valgo, butt wink, asimetría, y elevación de talón con lógica por porcentaje de frames y segundos acumulados.
- Se integró guardado automático en Firebase de repeticiones, tiempos y errores tras finalizar la evaluación (manual o automática).



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
