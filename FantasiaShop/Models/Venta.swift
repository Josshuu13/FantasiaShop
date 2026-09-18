import Foundation
import SwiftData

/// Método de pago usado en una venta.
enum MetodoPago: String, Codable, CaseIterable, Identifiable {
    case efectivo
    case tarjeta
    case transferencia

    var id: String { rawValue }

    var nombre: String {
        switch self {
        case .efectivo:      return "Efectivo"
        case .tarjeta:       return "Tarjeta"
        case .transferencia: return "Transferencia"
        }
    }
}

@Model
final class Venta {
    var fecha: Date = Date.now
    var total: Double = 0
    var metodoPago: MetodoPago = MetodoPago.efectivo
    /// Efectivo recibido para calcular el cambio. 0 si no aplica.
    var efectivoRecibido: Double = 0

    /// Identifica quién hizo la venta (para que el empleado vea solo las suyas).
    var vendedorID: String = ""
    var vendedorNombre: String = ""

    /// Líneas de la venta. .cascade: si se borra la venta, se borran sus líneas.
    @Relationship(deleteRule: .cascade, inverse: \LineaVenta.venta)
    var lineas: [LineaVenta]? = []

    init(
        total: Double,
        metodoPago: MetodoPago,
        efectivoRecibido: Double,
        vendedorID: String,
        vendedorNombre: String,
        fecha: Date = .now
    ) {
        self.total = total
        self.metodoPago = metodoPago
        self.efectivoRecibido = efectivoRecibido
        self.vendedorID = vendedorID
        self.vendedorNombre = vendedorNombre
        self.fecha = fecha
    }

    /// Cambio a devolver al cliente (nunca negativo).
    var cambio: Double { max(0, efectivoRecibido - total) }

    /// Número total de piezas vendidas en la transacción.
    var piezas: Int {
        (lineas ?? []).reduce(0) { $0 + $1.cantidad }
    }
}
