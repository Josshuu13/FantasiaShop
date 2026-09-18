//
//  ScannerViewController.swift
//  FantasiaShop
//
//  Created by Josue Cardoso on 15/06/26.
//

import SwiftUI
import VisionKit

/// Envuelve DataScannerViewController de VisionKit para usarlo en SwiftUI.
/// Reconoce códigos de barras y avisa al detectar uno.
///
/// ⚠️ DataScanner SOLO funciona en dispositivos físicos compatibles (no en el simulador).
struct EscanerView: UIViewControllerRepresentable {

    /// Se llama cada vez que se reconoce un código de barras nuevo.
    var alEscanear: (String) -> Void

    /// Indica si este dispositivo puede escanear (revisar antes de mostrar la vista).
    static var disponible: Bool {
        DataScannerViewController.isSupported && DataScannerViewController.isAvailable
    }

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let escaner = DataScannerViewController(
            recognizedDataTypes: [.barcode()],
            qualityLevel: .balanced,
            recognizesMultipleItems: false,
            isHighFrameRateTrackingEnabled: false,
            isHighlightingEnabled: true
        )
        escaner.delegate = context.coordinator
        return escaner
    }

    func updateUIViewController(_ escaner: DataScannerViewController, context: Context) {
        // Iniciamos el escaneo una sola vez, cuando la vista ya está en pantalla.
        if !context.coordinator.escaneando {
            try? escaner.startScanning()
            context.coordinator.escaneando = true
        }
    }

    static func dismantleUIViewController(_ escaner: DataScannerViewController, coordinator: Coordinator) {
        escaner.stopScanning()
    }

    func makeCoordinator() -> Coordinator { Coordinator(alEscanear: alEscanear) }

    /// Recibe los eventos del DataScannerViewController.
    final class Coordinator: NSObject, DataScannerViewControllerDelegate {
        private let alEscanear: (String) -> Void
        var escaneando = false
        /// Evita disparar el mismo código repetidamente en milisegundos.
        private var ultimoCodigo: String?

        init(alEscanear: @escaping (String) -> Void) {
            self.alEscanear = alEscanear
        }

        func dataScanner(_ dataScanner: DataScannerViewController,
                         didAdd addedItems: [RecognizedItem],
                         allItems: [RecognizedItem]) {
            for item in addedItems {
                if case let .barcode(codigo) = item, let texto = codigo.payloadStringValue {
                    guard texto != ultimoCodigo else { continue }
                    ultimoCodigo = texto
                    alEscanear(texto)
                }
            }
        }
    }
}
