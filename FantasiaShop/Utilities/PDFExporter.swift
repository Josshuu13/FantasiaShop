//
//  PDFExporter.swift
//  FantasiaShop
//
//  Created by Josue Cardoso on 15/06/26.
//

import UIKit
import PDFKit

/// Datos necesarios para imprimir el corte del día.
/// Lo arma el ResumenViewModel (Fase 3) y se lo pasa al exportador.
struct DatosCorte {
    let nombreTienda: String
    let fecha: Date
    let totalVendido: Double
    let piezas: Int
    let transacciones: Int
    /// Top productos del día: (nombre, cantidad vendida). Máximo 3.
    let topProductos: [(nombre: String, cantidad: Int)]
}

/// Genera el PDF del corte del día con PDFKit. Tamaño carta.
enum PDFExporter {

    /// Crea el PDF y devuelve la URL del archivo temporal listo para compartir/imprimir.
    static func generarCorte(_ datos: DatosCorte) -> URL? {
        let pagina = CGRect(x: 0, y: 0, width: 612, height: 792) // carta
        let renderizador = UIGraphicsPDFRenderer(bounds: pagina)

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("Corte-\(Int(datos.fecha.timeIntervalSince1970)).pdf")

        do {
            try renderizador.writePDF(to: url) { contexto in
                contexto.beginPage()
                dibujarContenido(datos, en: pagina)
            }
            return url
        } catch {
            return nil
        }
    }

    // MARK: - Dibujo

    private static func dibujarContenido(_ datos: DatosCorte, en pagina: CGRect) {
        let margen: CGFloat = 48
        let x = margen
        var y = margen

        let tintaPrimaria   = UIColor(red: 0.10, green: 0.10, blue: 0.12, alpha: 1)
        let tintaSecundaria = UIColor(red: 0.42, green: 0.42, blue: 0.46, alpha: 1)
        let acento          = UIColor(red: 0.325, green: 0.290, blue: 0.717, alpha: 1) // #534AB7

        // Encabezado
        y = dibujar(datos.nombreTienda, fuente: .systemFont(ofSize: 26, weight: .bold),
                    color: tintaPrimaria, x: x, y: y)
        y += 4
        y = dibujar("Corte del día · \(datos.fecha.textoFechaLarga)",
                    fuente: .systemFont(ofSize: 13), color: tintaSecundaria, x: x, y: y)
        y += 28

        // Total
        y = dibujar("Total vendido", fuente: .systemFont(ofSize: 14, weight: .semibold),
                    color: tintaSecundaria, x: x, y: y)
        y += 2
        y = dibujar(datos.totalVendido.comoMonedaMXN, fuente: .systemFont(ofSize: 22, weight: .bold),
                    color: acento, x: x, y: y)
        y += 20

        // Métricas
        y = dibujar("Piezas vendidas: \(datos.piezas)", fuente: .systemFont(ofSize: 14),
                    color: tintaPrimaria, x: x, y: y)
        y += 6
        y = dibujar("Transacciones: \(datos.transacciones)", fuente: .systemFont(ofSize: 14),
                    color: tintaPrimaria, x: x, y: y)
        y += 28

        // Top productos
        y = dibujar("Productos más vendidos", fuente: .systemFont(ofSize: 14, weight: .semibold),
                    color: tintaSecundaria, x: x, y: y)
        y += 8
        if datos.topProductos.isEmpty {
            _ = dibujar("Sin ventas registradas.", fuente: .systemFont(ofSize: 14),
                        color: tintaSecundaria, x: x, y: y)
        } else {
            for (indice, producto) in datos.topProductos.enumerated() {
                let linea = "\(indice + 1). \(producto.nombre) — \(producto.cantidad) pza."
                y = dibujar(linea, fuente: .systemFont(ofSize: 14), color: tintaPrimaria, x: x, y: y)
                y += 6
            }
        }

        // Pie de página
        let pieY = pagina.height - margen - 14
        _ = dibujar("Generado por FantasiaShop · \(datos.fecha.textoFechaCorta)",
                    fuente: .systemFont(ofSize: 13), color: tintaSecundaria, x: x, y: pieY)
    }

    /// Dibuja una línea de texto y devuelve la nueva posición vertical.
    private static func dibujar(_ texto: String, fuente: UIFont, color: UIColor,
                                x: CGFloat, y: CGFloat) -> CGFloat {
        let atributos: [NSAttributedString.Key: Any] = [.font: fuente, .foregroundColor: color]
        let cadena = NSAttributedString(string: texto, attributes: atributos)
        cadena.draw(at: CGPoint(x: x, y: y))
        return y + cadena.size().height
    }
}
