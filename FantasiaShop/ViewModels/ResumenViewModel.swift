//
//  ResumenViewModel.swift
//  FantasiaShop
//
//  Created by Josue Cardoso on 15/06/26.
//
import Foundation
import SwiftData
import Observation

/// Rango de tiempo para las métricas.
enum RangoTiempo: String, CaseIterable, Identifiable {
    case dia = "Hoy"
    case semana = "Semana"
    case mes = "Mes"

    var id: String { rawValue }
}

/// Calcula métricas del negocio: día, semana, mes, top productos, comparativa,
/// desglose por método de pago y consultas de stock. Base del resumen y del asistente.
@Observable
final class ResumenViewModel {
    private var contexto: ModelContext?
    private var appState: AppState?

    // Métricas del día (para la pantalla principal).
    var totalVendido: Double = 0
    var piezas: Int = 0
    var transacciones: Int = 0
    var topProductos: [(nombre: String, cantidad: Int)] = []
    var productosStockBajo: [Producto] = []

    /// Total del mismo día de la semana pasada (comparativa).
    var totalSemanaPasada: Double = 0

    /// Desglose del día por método de pago.
    var totalesPorMetodo: [MetodoPago: Double] = [:]

    func configurar(contexto: ModelContext, appState: AppState) {
        self.contexto = contexto
        self.appState = appState
        calcular()
    }

    // MARK: - Ventas visibles según rol

    /// Todas las ventas que este usuario puede ver (empleado: solo las suyas).
    private func ventasVisibles() -> [Venta] {
        guard let contexto, let appState else { return [] }
        let todas = (try? contexto.fetch(FetchDescriptor<Venta>())) ?? []
        if appState.esEmpleado, let id = appState.usuarioActual?.id {
            return todas.filter { $0.vendedorID == id }
        }
        return todas
    }

    /// Ventas dentro de un rango de tiempo (desde el inicio del periodo hasta ahora).
    private func ventas(en rango: RangoTiempo) -> [Venta] {
        let calendario = Calendar.current
        let ahora = Date.now
        let inicio: Date
        switch rango {
        case .dia:
            inicio = ahora.inicioDelDia
        case .semana:
            inicio = calendario.date(byAdding: .day, value: -7, to: ahora) ?? ahora
        case .mes:
            inicio = calendario.date(byAdding: .month, value: -1, to: ahora) ?? ahora
        }
        return ventasVisibles().filter { $0.fecha >= inicio }
    }

    // MARK: - Cálculo principal (día)

    /// Recalcula las métricas del día. Llamar al entrar al resumen y tras cobrar.
    func calcular() {
        guard let contexto else { return }

        let ventasHoy = ventas(en: .dia)
        totalVendido  = ventasHoy.reduce(0) { $0 + $1.total }
        transacciones = ventasHoy.count
        piezas        = ventasHoy.reduce(0) { $0 + $1.piezas }
        topProductos  = topProductos(de: ventasHoy, limite: 3)

        // Desglose por método de pago (hoy).
        var porMetodo: [MetodoPago: Double] = [:]
        for venta in ventasHoy {
            porMetodo[venta.metodoPago, default: 0] += venta.total
        }
        totalesPorMetodo = porMetodo

        // Comparativa: el mismo día de la semana pasada.
        let inicioSP = Date.now.mismoDiaSemanaPasada.inicioDelDia
        let finSP = Calendar.current.date(byAdding: .day, value: 1, to: inicioSP) ?? inicioSP
        totalSemanaPasada = ventasVisibles()
            .filter { $0.fecha >= inicioSP && $0.fecha < finSP }
            .reduce(0) { $0 + $1.total }

        let productos = (try? contexto.fetch(FetchDescriptor<Producto>())) ?? []
        productosStockBajo = productos.filter { $0.stockBajo }
    }

    // MARK: - Helpers reutilizables (los usa también el asistente)

    /// Top productos (por cantidad) de una lista de ventas.
    private func topProductos(de ventas: [Venta], limite: Int) -> [(nombre: String, cantidad: Int)] {
        var conteo: [String: Int] = [:]
        for venta in ventas {
            for linea in venta.lineas ?? [] {
                conteo[linea.nombreProducto, default: 0] += linea.cantidad
            }
        }
        return conteo
            .sorted { $0.value > $1.value }
            .prefix(limite)
            .map { (nombre: $0.key, cantidad: $0.value) }
    }

    /// Producto más vendido en un rango (nombre y cantidad), o nil si no hubo ventas.
    func productoMasVendido(en rango: RangoTiempo) -> (nombre: String, cantidad: Int)? {
        topProductos(de: ventas(en: rango), limite: 1).first
    }

    /// Total vendido en un rango.
    func totalVendido(en rango: RangoTiempo) -> Double {
        ventas(en: rango).reduce(0) { $0 + $1.total }
    }

    /// Número de piezas vendidas en un rango.
    func piezasVendidas(en rango: RangoTiempo) -> Int {
        ventas(en: rango).reduce(0) { $0 + $1.piezas }
    }

    /// La venta de mayor monto dentro de un rango.
    func mejorVenta(en rango: RangoTiempo) -> Venta? {
        ventas(en: rango).max { $0.total < $1.total }
    }

    /// El día con más ventas (total) en la última semana: fecha y total.
    func mejorDiaSemana() -> (fecha: Date, total: Double)? {
        let calendario = Calendar.current
        var porDia: [Date: Double] = [:]
        for venta in ventas(en: .semana) {
            let dia = calendario.startOfDay(for: venta.fecha)
            porDia[dia, default: 0] += venta.total
        }
        guard let mejor = porDia.max(by: { $0.value < $1.value }) else { return nil }
        return (fecha: mejor.key, total: mejor.value)
    }

    /// Busca productos por nombre (para consultar existencias).
    func buscarProductos(nombre: String) -> [Producto] {
        guard let contexto else { return [] }
        let todos = (try? contexto.fetch(FetchDescriptor<Producto>())) ?? []
        return todos.filter { $0.nombre.localizedCaseInsensitiveContains(nombre) }
    }
    /// Todas las ventas visibles, agrupadas por día (más reciente primero).
    /// Devuelve pares (día, ventas de ese día) para el historial.
    func ventasPorDia() -> [(dia: Date, ventas: [Venta])] {
        let calendario = Calendar.current
        let agrupado = Dictionary(grouping: ventasVisibles()) { venta in
            calendario.startOfDay(for: venta.fecha)
        }
        return agrupado
            .map { (dia: $0.key, ventas: $0.value.sorted { $0.fecha > $1.fecha }) }
            .sorted { $0.dia > $1.dia }
    }

    // MARK: - Comparativa

    var diferenciaSemanaPasada: Double { totalVendido - totalSemanaPasada }
    var hoyFueMejor: Bool { totalVendido >= totalSemanaPasada }

    // MARK: - Exportar PDF

    func exportarPDF() -> URL? {
        guard let tienda = appState?.tiendaActual else { return nil }
        let datos = DatosCorte(
            nombreTienda: tienda.nombre,
            fecha: .now,
            totalVendido: totalVendido,
            piezas: piezas,
            transacciones: transacciones,
            topProductos: topProductos
        )
        return PDFExporter.generarCorte(datos)
    }
}
