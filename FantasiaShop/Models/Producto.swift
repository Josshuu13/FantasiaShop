import Foundation
import SwiftData

/// Categorías disponibles para clasificar los productos de la tienda.
/// Respaldada por String para ser compatible con SwiftData + CloudKit.
enum Categoria: String, Codable, CaseIterable, Identifiable {
    case gorras
    case bolsas
    case mochilas
    case ligas
    case otro

    var id: String { rawValue }

    /// Nombre legible para mostrar en la interfaz.
    var nombre: String {
        switch self {
        case .gorras:   return "Gorras"
        case .bolsas:   return "Bolsas"
        case .mochilas: return "Mochilas"
        case .ligas:    return "Ligas"
        case .otro:     return "Otro"
        }
    }

    /// Ícono SF Symbol genérico cuando el producto no tiene foto.
    /// (Provisionales; los afinamos en la Fase 4 junto con el diseño.)
    var icono: String {
        switch self {
        case .gorras:   return "tag"
        case .bolsas:   return "bag"
        case .mochilas: return "backpack"
        case .ligas:    return "circle.grid.cross"
        case .otro:     return "shippingbox"
        }
    }
}

@Model
final class Producto {
    var nombre: String = ""
    var categoria: Categoria = Categoria.otro
    /// Nombre libre cuando la categoría es "Otro" (ej. "Llaveros"). nil en las demás.
    var subcategoria: String?
    var precio: Double = 0
    var stock: Int = 0
    var stockMinimo: Int = 0
    /// Foto opcional solo para identificar el producto en la lista (no es catálogo).
    var fotoData: Data?
    /// Contenido del código de barras Code128 (lo generamos en el ViewModel).
    var codigoBarras: String = ""
    var fechaCreacion: Date = Date.now

    /// Líneas de venta donde aparece este producto.
    /// .nullify: conservamos el historial aunque se borre el producto.
    @Relationship(deleteRule: .nullify, inverse: \LineaVenta.producto)
    var lineas: [LineaVenta]? = []

    init(
            nombre: String,
            categoria: Categoria,
            precio: Double,
            stock: Int,
            stockMinimo: Int,
            codigoBarras: String,
            fotoData: Data? = nil,
            subcategoria: String? = nil
        ) {
            self.nombre = nombre
            self.categoria = categoria
            self.precio = precio
            self.stock = stock
            self.stockMinimo = stockMinimo
            self.codigoBarras = codigoBarras
            self.fotoData = fotoData
            self.subcategoria = subcategoria
            self.fechaCreacion = .now
        }

    /// True cuando el stock está en o por debajo del mínimo definido.
    var stockBajo: Bool { stock <= stockMinimo }
    
    
    /// Nombre de categoría a mostrar: la subcategoría si existe, si no el nombre del enum.
        var categoriaMostrada: String {
            if categoria == .otro, let sub = subcategoria, !sub.isEmpty {
                return sub
            }
            return categoria.nombre
        }
}
