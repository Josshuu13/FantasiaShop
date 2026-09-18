//
//  BarcodeGenerator.swift
//  FantasiaShop
//
//  Created by Josue Cardoso on 15/06/26.
//

import UIKit
import CoreImage.CIFilterBuiltins

/// Genera imágenes de código de barras Code128 a partir de un texto.
/// Se usa al crear un producto para imprimir su etiqueta.
enum BarcodeGenerator {

    private static let contexto = CIContext()

    /// Devuelve una UIImage con el código de barras Code128 del texto dado.
    /// - Parameters:
    ///   - texto: contenido a codificar (el `codigoBarras` del producto).
    ///   - escala: cuánto agrandar la imagen (el filtro genera una muy pequeña).
    /// - Returns: la imagen lista para mostrar/imprimir, o nil si el texto no es válido.
    static func generar(desde texto: String, escala: CGFloat = 10) -> UIImage? {
        guard !texto.isEmpty, let datos = texto.data(using: .ascii) else { return nil }

        let filtro = CIFilter.code128BarcodeGenerator()
        filtro.message = datos
        filtro.quietSpace = 10   // margen blanco a los lados

        guard let salida = filtro.outputImage else { return nil }

        // El filtro produce una imagen diminuta; la escalamos sin difuminar.
        let imagenEscalada = salida.transformed(by: CGAffineTransform(scaleX: escala, y: escala))

        guard let cgImagen = contexto.createCGImage(imagenEscalada, from: imagenEscalada.extent) else {
            return nil
        }
        return UIImage(cgImage: cgImagen)
    }
}
