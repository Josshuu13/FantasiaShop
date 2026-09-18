//
//  Color+App.swift
//  FantasiaShop
//
//  Created by Josue Cardoso on 15/06/26.
//

import SwiftUI

/// Paleta única y minimalista de FantasiaShop.
/// Un solo color de acento (índigo) sobre neutros limpios; el color marca lo accionable.
/// Todos los tokens se adaptan automáticamente a modo claro y oscuro.
extension Color {

    // MARK: - Acento (lo accionable: botones primarios, selección)
    static let acento      = adaptativo(claro: "534AB7", oscuro: "6E63E5")
    static let acentoSuave = adaptativo(claro: "ECEBF8", oscuro: "2A2740")

    // MARK: - Semánticos (estados, mínimos necesarios)
    static let exito       = adaptativo(claro: "1D9E75", oscuro: "2BC08F") // stock ok / venta cobrada
    static let advertencia = adaptativo(claro: "E0930F", oscuro: "F0A93A") // stock bajo
    static let critico     = adaptativo(claro: "D14343", oscuro: "F26B6B") // agotado / error

    // MARK: - Neutros
    static let fondo           = adaptativo(claro: "F7F7FA", oscuro: "0F0F12")
    static let superficie      = adaptativo(claro: "FFFFFF", oscuro: "1C1C1F")
    static let textoPrimario   = adaptativo(claro: "1A1A1F", oscuro: "F2F2F5")
    static let textoSecundario = adaptativo(claro: "6B6B76", oscuro: "9A9AA5")
    static let borde           = adaptativo(claro: "E5E5EC", oscuro: "303036")

    // MARK: - Helpers privados

    /// Construye un color que cambia según el modo claro/oscuro del sistema.
    private static func adaptativo(claro: String, oscuro: String) -> Color {
        Color(uiColor: UIColor { rasgos in
            rasgos.userInterfaceStyle == .dark
                ? UIColor(hex: oscuro)
                : UIColor(hex: claro)
        })
    }
}

private extension UIColor {
    /// Crea un UIColor a partir de un hex de 6 dígitos, p. ej. "534AB7".
    convenience init(hex: String) {
        var valor: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&valor)
        let rojo  = Double((valor & 0xFF0000) >> 16) / 255
        let verde = Double((valor & 0x00FF00) >> 8) / 255
        let azul  = Double(valor & 0x0000FF) / 255
        self.init(red: rojo, green: verde, blue: azul, alpha: 1)
    }
}

#Preview("Paleta FantasiaShop") {
    let muestras: [(String, Color)] = [
        ("Acento", .acento), ("Acento suave", .acentoSuave),
        ("Éxito", .exito), ("Advertencia", .advertencia), ("Crítico", .critico),
        ("Fondo", .fondo), ("Superficie", .superficie),
        ("Texto primario", .textoPrimario), ("Texto secundario", .textoSecundario),
        ("Borde", .borde)
    ]
    return ScrollView {
        VStack(spacing: 12) {
            ForEach(muestras, id: \.0) { nombre, color in
                HStack(spacing: 16) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(color)
                        .frame(width: 56, height: 56)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.borde, lineWidth: 1))
                    Text(nombre).foregroundStyle(Color.textoPrimario)
                    Spacer()
                }
            }
        }
        .padding()
    }
    .background(Color.fondo)
}
