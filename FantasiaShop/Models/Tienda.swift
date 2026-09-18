import Foundation
import SwiftData

@Model
final class Tienda {
    var id: String = UUID().uuidString
    var nombre: String = ""
    /// Código de invitación de 6 dígitos para vincular un empleado.
    var codigoInvitacion: String = ""
    /// Cuándo deja de ser válido el código (24 h después de generarlo).
    var fechaExpiracionCodigo: Date?
    var fechaCreacion: Date = Date.now

    init(nombre: String, id: String = UUID().uuidString) {
        self.id = id
        self.nombre = nombre
        self.fechaCreacion = .now
    }

    /// True si el código existe y todavía no caduca.
    var codigoVigente: Bool {
        guard !codigoInvitacion.isEmpty, let expira = fechaExpiracionCodigo else { return false }
        return expira > .now
    }
}
