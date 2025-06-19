//
//  Fit_TrackingV2UITests.swift
//  Fit TrackingV2UITests
//
//  Created by Baruck Botton on 1/05/25.
//

import XCTest

final class Fit_TrackingV2UITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            let app = XCUIApplication()
            app.launchArguments.append("-UITest")
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                app.launch()
            }
        }
    }
    func testComenzarEjercicioButton() throws {
        let app = XCUIApplication()
        app.launch()
        
        let comenzarButton = app.buttons["comenzarEjercicio"]
        XCTAssertTrue(comenzarButton.waitForExistence(timeout: 5), "El botón 'Comenzar Ejercicio' no aparece")
        
        comenzarButton.tap()

    }
    func testSeleccionarSentadilla() throws {
        let app = XCUIApplication()
           app.launch()

           // Esperar a que aparezca la vista principal (con el botón "Comenzar Ejercicio")
           let comenzarButton = app.buttons["comenzarEjercicio"]
           XCTAssertTrue(comenzarButton.waitForExistence(timeout: 5))
           comenzarButton.tap()

           // Buscar y tocar el botón de sentadillas
           let sentadillasButton = app.buttons["button_squat"]
           XCTAssertTrue(sentadillasButton.waitForExistence(timeout: 5))
           sentadillasButton.tap()

           // Validar que estamos en la EvaluacionView, por ejemplo con un texto esperable
           let evaluacionLabel = app.staticTexts["evaluacionViewLabel"]
           XCTAssertTrue(evaluacionLabel.waitForExistence(timeout: 5))
    }
    func testSeleccionarFlexiones() throws {
        let app = XCUIApplication()
           app.launch()

           // Esperar a que aparezca la vista principal (con el botón "Comenzar Ejercicio")
           let comenzarButton = app.buttons["comenzarEjercicio"]
           XCTAssertTrue(comenzarButton.waitForExistence(timeout: 5))
           comenzarButton.tap()

           // Buscar y tocar el botón de sentadillas
           let sentadillasButton = app.buttons["button_pushUp"]
           XCTAssertTrue(sentadillasButton.waitForExistence(timeout: 5))
           sentadillasButton.tap()

           // Validar que estamos en la EvaluacionView, por ejemplo con un texto esperable
           let evaluacionLabel = app.staticTexts["evaluacionViewLabel"]
           XCTAssertTrue(evaluacionLabel.waitForExistence(timeout: 5))
    }
    func testSeleccionarCurls() throws {
        let app = XCUIApplication()
           app.launch()

           // Esperar a que aparezca la vista principal (con el botón "Comenzar Ejercicio")
           let comenzarButton = app.buttons["comenzarEjercicio"]
           XCTAssertTrue(comenzarButton.waitForExistence(timeout: 5))
           comenzarButton.tap()

           // Buscar y tocar el botón de sentadillas
           let bicepCurlButton = app.buttons["button_bicepCurl"]
           XCTAssertTrue(bicepCurlButton.waitForExistence(timeout: 5))
           bicepCurlButton.tap()

           // Validar que estamos en la EvaluacionView, por ejemplo con un texto esperable
           let evaluacionLabel = app.staticTexts["evaluacionViewLabel"]
           XCTAssertTrue(evaluacionLabel.waitForExistence(timeout: 5))
    }
    func testSeleccionarPressMilitar() throws {
        let app = XCUIApplication()
           app.launch()

           // Esperar a que aparezca la vista principal (con el botón "Comenzar Ejercicio")
           let comenzarButton = app.buttons["comenzarEjercicio"]
           XCTAssertTrue(comenzarButton.waitForExistence(timeout: 5))
           comenzarButton.tap()

           // Buscar y tocar el botón de sentadillas
           let sentadillasButton = app.buttons["button_overheadDumbellPress"]
           XCTAssertTrue(sentadillasButton.waitForExistence(timeout: 5))
           sentadillasButton.tap()

           // Validar que estamos en la EvaluacionView, por ejemplo con un texto esperable
           let evaluacionLabel = app.staticTexts["evaluacionViewLabel"]
           XCTAssertTrue(evaluacionLabel.waitForExistence(timeout: 5))
    }
    func testFeedback() throws {
        let app = XCUIApplication()
           app.launch()

           // Esperar a que aparezca la vista principal (con el botón "Comenzar Ejercicio")
           let comenzarButton = app.buttons["comenzarEjercicio"]
           XCTAssertTrue(comenzarButton.waitForExistence(timeout: 5))
           comenzarButton.tap()

           // Buscar y tocar el botón de sentadillas
           let sentadillasButton = app.buttons["button_squat"]
           XCTAssertTrue(sentadillasButton.waitForExistence(timeout: 5))
           sentadillasButton.tap()

            let finalizarButton = app.buttons["FinalizarEvaluationButton"]
            XCTAssertTrue(finalizarButton.waitForExistence(timeout: 10))
            finalizarButton.tap()
            
            let feedbackLabel = app.staticTexts["feedbackViewLabel"]
            XCTAssertTrue(feedbackLabel.waitForExistence(timeout: 10))
    }
}
