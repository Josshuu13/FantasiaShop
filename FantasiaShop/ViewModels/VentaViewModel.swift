//
//  VentaViewModel.swift
//  FantasiaShop
//
//  Created by Josue Cardoso on 15/06/26.
//

import Foundation
import SwiftData
import Observation

/// Línea del ticket en curso. Vive en memoria hasta que se cobra (no es un @Model todavía).
struct LineaTicket: Identifiable {
    let id = UUID()
    let producto: Producto
    var cantidad: Int

    var precioUnitario: Double { producto.precio }
    var subtotal: Double { precioUnitario * Double(cantidad) }
}

/// Lógica del modo venta: ticket activo, escaneo, cobro y descuento de stock.
@Observable
final class VentaViewModel {
    private var contexto: ModelContext?
    private var appState: AppState?

    /// Líneas del ticket actual.
    var lineas: [LineaTicket] = []

    // Datos del cobro.
    var metodoPago: MetodoPago = .efectivo
    var efectivoRecibido: Double = 0

    /// Mensaje para la UI (p. ej. "producto no encontrado").
    var mensaje: String?

    func configurar(contexto: ModelContext, appState: AppState) {
        self.contexto = contexto
        self.appState = appState
    }

    // Totales calculados del ticket.
    var total: Double { lineas.reduce(0) { $0 + $1.subtotal } }
    var piezas: Int { lineas.reduce(0) { $0 + $1.cantidad } }
    var cambio: Double { max(0, efectivoRecibido - total) }

    /// ¿Se puede cobrar? Debe haber líneas y, si es efectivo, alcanzar el dinero.
    var puedeCobrar: Bool {
        guard !lineas.isEmpty else { return false }
        if metodoPago == .efectivo { return efectivoRecibido >= total }
        return true
    }

    // MARK: - Construir el ticket

    /// Agrega un producto al ticket a partir de un código escaneado.
    func agregarPorCodigo(_ codigo: String) {
        guard let contexto else { return }
        let productos = (try? contexto.fetch(FetchDescriptor<Producto>())) ?? []
        guard let producto = productos.first(where: { $0.codigoBarras == codigo }) else {
            mensaje = "Producto no encontrado."
            return
        }
        agregarProducto(producto)
    }

    /// Agrega un producto; si ya está en el ticket, sube la cantidad.
    /// No permite pasar del stock disponible.
    func agregarProducto(_ producto: Producto) {
        if let i = lineas.firstIndex(where: { $0.producto.codigoBarras == producto.codigoBarras }) {
            // Ya está en el ticket: revisar que aún haya stock para una pieza más.
            guard lineas[i].cantidad < producto.stock else {
                mensaje = "Solo hay \(producto.stock) de \(producto.nombre) en existencia."
                return
            }
            lineas[i].cantidad += 1
        } else {
            // Nuevo en el ticket: bloquear si está agotado.
            guard producto.stock > 0 else {
                mensaje = "\(producto.nombre) está agotado."
                return
            }
            lineas.append(LineaTicket(producto: producto, cantidad: 1))
        }
        mensaje = nil
    }

    func aumentar(_ linea: LineaTicket) {
        guard let i = lineas.firstIndex(where: { $0.id == linea.id }) else { return }
        // No dejar subir la cantidad por encima del stock disponible.
        guard lineas[i].cantidad < lineas[i].producto.stock else {
            mensaje = "Solo hay \(lineas[i].producto.stock) de \(lineas[i].producto.nombre) en existencia."
            return
        }
        lineas[i].cantidad += 1
    }

    func disminuir(_ linea: LineaTicket) {
        guard let i = lineas.firstIndex(where: { $0.id == linea.id }) else { return }
        if lineas[i].cantidad > 1 { lineas[i].cantidad -= 1 }
        else { lineas.remove(at: i) }
    }

    func quitar(_ linea: LineaTicket) {
        lineas.removeAll { $0.id == linea.id }
    }

    func limpiarTicket() {
        lineas.removeAll()
        efectivoRecibido = 0
        metodoPago = .efectivo
        mensaje = nil
    }

    // MARK: - Cobrar

    /// Registra la venta, descuenta stock y avisa de stock bajo. Devuelve la venta creada.
    @discardableResult
    func cobrar() -> Venta? {
        guard let contexto, let usuario = appState?.usuarioActual, !lineas.isEmpty else { return nil }

        let venta = Venta(total: total, metodoPago: metodoPago,
                          efectivoRecibido: efectivoRecibido,
                          vendedorID: usuario.id, vendedorNombre: usuario.nombre)
        contexto.insert(venta)

        var productosTocados: [Producto] = []
        for lineaTicket in lineas {
            let producto = lineaTicket.producto
            let linea = LineaVenta(producto: producto,
                                   cantidad: lineaTicket.cantidad,
                                   precioUnitario: lineaTicket.precioUnitario,
                                   nombreProducto: producto.nombre)
            linea.venta = venta
            contexto.insert(linea)

            // Descuenta stock sin bajar de 0.
            producto.stock = max(0, producto.stock - lineaTicket.cantidad)
            productosTocados.append(producto)
        }

        try? contexto.save()

        // Notificación local de stock bajo (no necesita CloudKit).
        for producto in productosTocados where producto.stockBajo {
            NotificationManager.compartido.avisarStockBajo(
                nombreProducto: producto.nombre,
                stockActual: producto.stock
            )
        }

        let ventaCobrada = venta
        limpiarTicket()
        return ventaCobrada
    }
}
