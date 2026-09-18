import Foundation
import SwiftData

/// Roles disponibles en la app.
enum RolUsuario: String, Codable, CaseIterable, Identifiable {
    case dueño
    case empleado

    var id: String { rawValue }

    var nombre: String {
        switch self {
        case .dueño:    return "Dueño"
        case .empleado: return "Empleado"
        }
    }
}

@Model
final class Usuario {
    /// ID estable para enlazar ventas con su vendedor entre dispositivos.
    var id: String = UUID().uuidString
    var nombre: String = ""
    var rol: RolUsuario = RolUsuario.dueño
    /// ID de la tienda a la que pertenece.
    var tiendaID: String = ""
    var fechaRegistro: Date = Date.now
    /// El dueño puede revocar acceso poniéndolo en false.
    var activo: Bool = true

    init(
        nombre: String,
        rol: RolUsuario,
        tiendaID: String,
        id: String = UUID().uuidString
    ) {
        self.id = id
        self.nombre = nombre
        self.rol = rol
        self.tiendaID = tiendaID
        self.fechaRegistro = .now
    }
}
