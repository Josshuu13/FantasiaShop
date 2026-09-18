//
//  CamaraPicker.swift
//  FantasiaShop
//
//  Created by Josue Cardoso on 26/08/26.
//

import SwiftUI
import UIKit

/// Envuelve UIImagePickerController para tomar una foto con la cámara.
/// ⚠️ La cámara solo funciona en dispositivos físicos (no en el simulador).
struct CamaraPicker: UIViewControllerRepresentable {
    /// Devuelve los datos de la foto tomada.
    var alTomarFoto: (Data) -> Void
    @Environment(\.dismiss) private var dismiss

    /// Indica si el dispositivo tiene cámara disponible.
    static var disponible: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let padre: CamaraPicker

        init(_ padre: CamaraPicker) { self.padre = padre }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let imagen = info[.originalImage] as? UIImage,
               let datos = imagen.jpegData(compressionQuality: 0.8) {
                padre.alTomarFoto(datos)
            }
            padre.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            padre.dismiss()
        }
    }
}
