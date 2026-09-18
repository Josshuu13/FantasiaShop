//
//  AsistenteViewModel.swift
//  FantasiaShop
//
//  Created by Josue Cardoso on 02/09/26.
//
import Foundation
import SwiftData
import Observation

/// Un mensaje en la conversación del asistente.
struct MensajeAsistente: Identifiable {
    let id = UUID()
    let texto: String
    let esDelUsuario: Bool
}

/// Una pregunta rápida predefinida (chip).
struct PreguntaRapida: Identifiable {
    let id = UUID()
    let icono: String
    let titulo: String
    let intencion: Intencion
}

/// Lo que el asistente sabe responder.
enum Intencion {
    case masVendido(RangoTiempo)
    case totalVendido(RangoTiempo)
    case mejorDia
    case mejorVenta(RangoTiempo)
    case stockDe(String)
    case porAgotarse
    case agotados
    case comparativa
}

/// Asistente local: interpreta preguntas y responde con datos reales de la tienda.
/// No usa IA externa; reconoce patrones por vocabulario. Preparado para IA real después.
@Observable
final class AsistenteViewModel {
    private var resumenVM: ResumenViewModel?

    var mensajes: [MensajeAsistente] = []

    let preguntasRapidas: [PreguntaRapida] = [
        .init(icono: "trophy.fill",       titulo: "Más vendido de la semana", intencion: .masVendido(.semana)),
        .init(icono: "trophy",            titulo: "Más vendido del mes",       intencion: .masVendido(.mes)),
        .init(icono: "dollarsign.circle", titulo: "Cuánto vendí esta semana",  intencion: .totalVendido(.semana)),
        .init(icono: "dollarsign.circle.fill", titulo: "Cuánto vendí este mes", intencion: .totalVendido(.mes)),
        .init(icono: "calendar",          titulo: "Mi mejor día",              intencion: .mejorDia),
        .init(icono: "star.fill",         titulo: "Mi venta más grande",       intencion: .mejorVenta(.semana)),
        .init(icono: "exclamationmark.triangle.fill", titulo: "Por agotarse",  intencion: .porAgotarse),
        .init(icono: "chart.line.uptrend.xyaxis", titulo: "¿Voy mejor que la semana pasada?", intencion: .comparativa)
    ]

    func configurar(resumenVM: ResumenViewModel) {
        self.resumenVM = resumenVM
        if mensajes.isEmpty {
            mensajes.append(MensajeAsistente(
                texto: "¡Hola! Soy tu asistente. Pregúntame por tus ventas o tu inventario. Toca una opción o escribe tu pregunta con tus palabras.",
                esDelUsuario: false
            ))
        }
    }

    func preguntar(_ pregunta: PreguntaRapida) {
        mensajes.append(MensajeAsistente(texto: pregunta.titulo, esDelUsuario: true))
        responder(a: pregunta.intencion)
    }

    func preguntarTexto(_ texto: String) {
        let limpio = texto.trimmingCharacters(in: .whitespaces)
        guard !limpio.isEmpty else { return }
        mensajes.append(MensajeAsistente(texto: limpio, esDelUsuario: true))

        if let intencion = interpretar(limpio) {
            responder(a: intencion)
        } else {
            mensajes.append(MensajeAsistente(
                texto: "No entendí bien esa pregunta 🤔. Puedes tocar una de las opciones de arriba, o preguntarme cosas como:\n• “¿cuánto vendí esta semana?”\n• “¿cuánto stock hay de gorra?”\n• “¿qué se está acabando?”\n• “¿cómo voy comparado con la semana pasada?”",
                esDelUsuario: false
            ))
        }
    }

    // MARK: - Interpretar texto libre (vocabulario amplio)

    private func interpretar(_ texto: String) -> Intencion? {
        // Normaliza: minúsculas y sin acentos, para que "cuánto" y "cuanto" sean iguales.
        let t = normalizar(texto)

        // --- STOCK / EXISTENCIAS DE UN PRODUCTO ---
        // Palabras que sugieren consulta de inventario.
        let palabrasStock = ["stock", "existencia", "existencias", "queda", "quedan", "hay",
                             "tengo", "tenemos", "inventario", "disponible", "disponibles",
                             "cuantos", "cuantas", "que tanto", "cuanto hay"]
        if contieneAlguna(t, palabrasStock) {
            if let nombre = detectarProducto(en: t) {
                return .stockDe(nombre)
            }
        }

        // --- AGOTADOS ---
        let palabrasAgotado = ["agotad", "se acabo", "se acabaron", "ya no hay", "no hay",
                              "sin stock", "sin existencia", "termino", "terminaron"]
        if contieneAlguna(t, palabrasAgotado) {
            // Si menciona un producto específico, mejor tratarlo como consulta de stock.
            if let nombre = detectarProducto(en: t) { return .stockDe(nombre) }
            return .agotados
        }

        // --- POR AGOTARSE / RESURTIR ---
        let palabrasPorAgotarse = ["por agotar", "por acabar", "se esta acabando", "se estan acabando",
                                  "resurtir", "surtir", "poco stock", "bajo", "falta", "faltan",
                                  "que comprar", "que pedir"]
        if contieneAlguna(t, palabrasPorAgotarse) {
            return .porAgotarse
        }

        // --- COMPARATIVA ---
        let palabrasComparativa = ["mejor o peor", "comparad", "comparacion", "semana pasada",
                                  "como voy", "como vamos", "voy bien", "vamos bien",
                                  "voy mejor", "estoy mejor", "que la semana"]
        if contieneAlguna(t, palabrasComparativa) {
            return .comparativa
        }

        // --- MEJOR DÍA ---
        let palabrasMejorDia = ["mejor dia", "que dia vendi mas", "que dia se vendio mas",
                               "dia con mas ventas", "el dia que mas"]
        if contieneAlguna(t, palabrasMejorDia) {
            return .mejorDia
        }

        // --- VENTA MÁS GRANDE ---
        let palabrasMejorVenta = ["venta mas grande", "mejor venta", "venta mayor",
                                 "la venta mas alta", "ticket mas grande", "venta mas alta"]
        if contieneAlguna(t, palabrasMejorVenta) {
            return .mejorVenta(rango(en: t, porDefecto: .semana))
        }

        // --- MÁS VENDIDO ---
        let palabrasMasVendido = ["mas vendido", "mas vendida", "mas se vende", "mas sale",
                                 "lo que mas sale", "producto estrella", "top", "mas popular",
                                 "mejor producto", "que se vende mas", "el que mas se vende"]
        if contieneAlguna(t, palabrasMasVendido) {
            return .masVendido(rango(en: t, porDefecto: .semana))
        }

        // --- CUÁNTO VENDÍ / TOTAL ---
        let palabrasTotal = ["cuanto vendi", "cuanto he vendido", "cuanto llevo", "cuanto gane",
                            "cuanto he ganado", "mis ventas", "las ventas", "cuanto entro",
                            "cuanto facture", "total de ventas", "total vendido", "cuanto cayo",
                            "cuanto hice", "ingresos", "ganancia del", "vendi"]
        if contieneAlguna(t, palabrasTotal) {
            return .totalVendido(rango(en: t, porDefecto: .dia))
        }

        return nil
    }

    // MARK: - Utilidades de texto

    /// Pasa a minúsculas y quita acentos para comparar sin problemas.
    /// Pasa a minúsculas y quita acentos, PERO conserva la ñ.
    private func normalizar(_ texto: String) -> String {
        // Protegemos la ñ antes de quitar acentos, y la restauramos después.
        let protegido = texto.lowercased()
            .replacingOccurrences(of: "ñ", with: "\u{0001}")   // marcador temporal
        let sinAcentos = protegido
            .folding(options: .diacriticInsensitive, locale: Locale(identifier: "es_MX"))
        return sinAcentos
            .replacingOccurrences(of: "\u{0001}", with: "ñ")   // restauramos la ñ
    }

    /// True si el texto contiene alguna de las palabras/frases dadas.
    private func contieneAlguna(_ texto: String, _ palabras: [String]) -> Bool {
        palabras.contains { texto.contains(normalizar($0)) }
    }

    /// Detecta el rango de tiempo mencionado.
    private func rango(en texto: String, porDefecto: RangoTiempo) -> RangoTiempo {
        if texto.contains("mes") { return .mes }
        if texto.contains("semana") { return .semana }
        if texto.contains("hoy") || texto.contains("dia de hoy") { return .dia }
        return porDefecto
    }

    /// Detecta a qué producto se refiere la pregunta, comparando con el inventario real.
    /// Primero intenta emparejar por nombre real; si no, toma lo que va después de "de".
    private func detectarProducto(en texto: String) -> String? {
        guard let vm = resumenVM else { return nil }

        // 1) Comparar contra los nombres reales del inventario (lo más confiable).
        let todos = vm.buscarProductos(nombre: "") // "" trae todos
        for producto in todos {
            let nombreNorm = normalizar(producto.nombre)
            // Coincidencia por nombre completo o por alguna palabra distintiva del nombre.
            if texto.contains(nombreNorm) { return producto.nombre }
            for palabra in nombreNorm.split(separator: " ") where palabra.count >= 4 {
                if texto.contains(palabra) { return producto.nombre }
            }
        }

        // 2) Respaldo: tomar lo que viene después de "de".
        if let rango = texto.range(of: " de ") {
            let resto = String(texto[rango.upperBound...]).trimmingCharacters(in: .whitespaces)
            return resto.isEmpty ? nil : resto
        }
        return nil
    }

    // MARK: - Responder

    private func responder(a intencion: Intencion) {
        guard let vm = resumenVM else { return }
        let respuesta: String

        switch intencion {
        case .masVendido(let rango):
            if let top = vm.productoMasVendido(en: rango) {
                respuesta = "🏆 Tu producto más vendido (\(rango.rawValue.lowercased())) es \(top.nombre) con \(top.cantidad) \(top.cantidad == 1 ? "pieza" : "piezas") vendidas."
            } else {
                respuesta = "No registré ventas en ese periodo todavía."
            }

        case .totalVendido(let rango):
            let total = vm.totalVendido(en: rango)
            let piezas = vm.piezasVendidas(en: rango)
            respuesta = total > 0
                ? "💰 En \(etiqueta(rango)) llevas \(total.comoMoneda) vendidos, en \(piezas) \(piezas == 1 ? "pieza" : "piezas")."
                : "Aún no hay ventas en \(etiqueta(rango))."

        case .mejorDia:
            if let mejor = vm.mejorDiaSemana() {
                respuesta = "📅 Tu mejor día de la última semana fue el \(mejor.fecha.textoFechaLarga.capitalized), con \(mejor.total.comoMoneda) vendidos."
            } else {
                respuesta = "No hay ventas en la última semana para comparar."
            }

        case .mejorVenta(let rango):
            if let venta = vm.mejorVenta(en: rango) {
                respuesta = "⭐ Tu venta más grande (\(rango.rawValue.lowercased())) fue de \(venta.total.comoMoneda), el \(venta.fecha.textoFechaCorta) a las \(venta.fecha.textoHora), con \(venta.piezas) \(venta.piezas == 1 ? "pieza" : "piezas")."
            } else {
                respuesta = "No registré ventas en ese periodo."
            }

        case .stockDe(let nombre):
            let encontrados = vm.buscarProductos(nombre: nombre)
            if encontrados.isEmpty {
                respuesta = "No encontré ningún producto que se llame “\(nombre)”. Revisa el nombre e intenta de nuevo."
            } else if encontrados.count == 1, let p = encontrados.first {
                let estado = p.stock == 0 ? "está agotado 🔴"
                           : p.stockBajo ? "está por agotarse ⚠️"
                           : "tiene buen nivel ✅"
                respuesta = "📦 De \(p.nombre) tienes \(p.stock) \(p.stock == 1 ? "pieza" : "piezas"). \(estado.prefix(1).uppercased() + estado.dropFirst())"
            } else {
                let lista = encontrados.map { "• \($0.nombre): \($0.stock) pza" }.joined(separator: "\n")
                respuesta = "📦 Encontré varios productos:\n\(lista)"
            }

        case .porAgotarse:
            let bajos = vm.productosStockBajo.filter { $0.stock > 0 }
            respuesta = bajos.isEmpty
                ? "✅ Ningún producto está por agotarse. Todo tiene buen nivel de stock."
                : "⚠️ Estos productos están por agotarse:\n" + bajos.map { "• \($0.nombre): quedan \($0.stock)" }.joined(separator: "\n")

        case .agotados:
            let agotados = vm.productosStockBajo.filter { $0.stock == 0 }
            respuesta = agotados.isEmpty
                ? "✅ No tienes productos agotados."
                : "🔴 Estos productos están agotados:\n" + agotados.map { "• \($0.nombre)" }.joined(separator: "\n")

        case .comparativa:
            vm.calcular()
            if vm.totalSemanaPasada == 0 {
                respuesta = "Todavía no tengo datos del mismo día la semana pasada para comparar."
            } else {
                let dif = abs(vm.diferenciaSemanaPasada)
                respuesta = vm.hoyFueMejor
                    ? "📈 ¡Vas mejor! Hoy llevas \(dif.comoMoneda) más que el mismo día de la semana pasada."
                    : "📉 Hoy llevas \(dif.comoMoneda) menos que el mismo día de la semana pasada. ¡Aún puedes remontar!"
            }
        }

        mensajes.append(MensajeAsistente(texto: respuesta, esDelUsuario: false))
    }

    private func etiqueta(_ rango: RangoTiempo) -> String {
        switch rango {
        case .dia:    return "el día de hoy"
        case .semana: return "la última semana"
        case .mes:    return "el último mes"
        }
    }
}
