import Foundation
import SwiftData

@Model
final class LineaVenta {
    var cantidad: Int = 1
    /// Precio del producto al momento de la venta (no cambia si luego editas el precio).
    var precioUnitario: Double = 0
    /// Copia del nombre por si el producto se llega a borrar del inventario.
    var nombreProducto: String = ""

    var producto: Producto?
    var venta: Venta?

    init(producto: Producto?, cantidad: Int, precioUnitario: Double, nombreProducto: String) {
        self.producto = producto
        self.cantidad = cantidad
        self.precioUnitario = precioUnitario
        self.nombreProducto = nombreProducto
    }

    /// Importe total de la línea (cantidad × precio unitario).
    var subtotal: Double { precioUnitario * Double(cantidad) }
}
