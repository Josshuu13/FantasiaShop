//
//  AuthViewModel.swift
//  FantasiaShop
//
//  Created by Josue Cardoso on 15/06/26.
//

import Foundation
import SwiftData
import Observation

/// Maneja la sesión: crear tienda/usuario, roles, código de invitación y recordar la sesión.
@Observable
final class AuthViewModel {
    private var contexto: ModelContext?
    private var appState: AppState?

    /// Mensaje de error para mostrar en la UI (p. ej. código inválido).
    var mensajeError: String?

    // Claves para recordar en ESTE dispositivo quién inició sesión.
    private let claveUsuarioID = "fantasiashop.usuarioActualID"
    private let claveTiendaID  = "fantasiashop.tiendaActualID"

    /// La vista llama esto al aparecer, para inyectar el contexto y el estado global.
    func configurar(contexto: ModelContext, appState: AppState) {
        self.contexto = contexto
        self.appState = appState
    }

    /// Restaura la sesión guardada al abrir la app (si existe).
    func restaurarSesion() {
        guard let contexto, let appState else { return }
        let defaults = UserDefaults.standard
        guard let usuarioID = defaults.string(forKey: claveUsuarioID),
              let tiendaID  = defaults.string(forKey: claveTiendaID) else { return }

        let usuarios = (try? contexto.fetch(FetchDescriptor<Usuario>())) ?? []
        let tiendas  = (try? contexto.fetch(FetchDescriptor<Tienda>())) ?? []

        appState.usuarioActual = usuarios.first { $0.id == usuarioID && $0.activo }
        appState.tiendaActual  = tiendas.first { $0.id == tiendaID }
    }
    
    
    /// Reconecta automáticamente al dueño existente en este dispositivo (si lo hay).
        /// Útil tras cerrar sesión: en un solo dispositivo el dueño no debe perderse.
        @discardableResult
        func reconectarDueño() -> Bool {
            guard let contexto, let appState else { return false }
            let usuarios = (try? contexto.fetch(FetchDescriptor<Usuario>())) ?? []
            guard let dueño = usuarios.first(where: { $0.rol == .dueño }) else { return false }

            let tiendas = (try? contexto.fetch(FetchDescriptor<Tienda>())) ?? []
            guard let tienda = tiendas.first(where: { $0.id == dueño.tiendaID }) else { return false }

            guardarSesion(usuario: dueño, tienda: tienda)
            appState.usuarioActual = dueño
            appState.tiendaActual = tienda
            return true
        }

        /// True si ya existe un dueño registrado en este dispositivo.
        var existeDueño: Bool {
            guard let contexto else { return false }
            let usuarios = (try? contexto.fetch(FetchDescriptor<Usuario>())) ?? []
            return usuarios.contains { $0.rol == .dueño }
        }

    /// Primer inicio como dueño: crea la tienda y el usuario dueño.
    func registrarDueño(nombreTienda: String, nombreDueño: String) {
        guard let contexto, let appState else { return }
        let tienda = Tienda(nombre: nombreTienda)
        let dueño  = Usuario(nombre: nombreDueño, rol: .dueño, tiendaID: tienda.id)
        contexto.insert(tienda)
        contexto.insert(dueño)
        try? contexto.save()

        guardarSesion(usuario: dueño, tienda: tienda)
        appState.usuarioActual = dueño
        appState.tiendaActual  = tienda
    }

    /// Genera un código de 6 dígitos válido por 24 h y lo guarda en la tienda.
    @discardableResult
    func generarCodigoInvitacion() -> String? {
        guard let contexto, let tienda = appState?.tiendaActual else { return nil }
        let codigo = String(format: "%06d", Int.random(in: 0...999_999))
        tienda.codigoInvitacion = codigo
        tienda.fechaExpiracionCodigo = Calendar.current.date(byAdding: .hour, value: 24, to: .now)
        try? contexto.save()
        return codigo
    }

    /// Valida el código e inicia sesión como empleado.
    func ingresarComoEmpleado(codigo: String, nombreEmpleado: String) -> Bool {
        guard let contexto, let appState else { return false }
        let tiendas = (try? contexto.fetch(FetchDescriptor<Tienda>())) ?? []

        guard let tienda = tiendas.first(where: { $0.codigoInvitacion == codigo && $0.codigoVigente }) else {
            mensajeError = "Código inválido o expirado."
            return false
        }

        let empleado = Usuario(nombre: nombreEmpleado, rol: .empleado, tiendaID: tienda.id)
        contexto.insert(empleado)
        try? contexto.save()

        guardarSesion(usuario: empleado, tienda: tienda)
        appState.usuarioActual = empleado
        appState.tiendaActual  = tienda
        mensajeError = nil
        return true
    }

    /// Empleados (activos o no) de la tienda actual, para que el dueño los gestione.
    func empleados() -> [Usuario] {
        guard let contexto, let tienda = appState?.tiendaActual else { return [] }
        let usuarios = (try? contexto.fetch(FetchDescriptor<Usuario>())) ?? []
        return usuarios.filter { $0.tiendaID == tienda.id && $0.rol == .empleado }
    }

    /// Revoca el acceso de un empleado sin borrar su historial (solo lo desactiva).
    func revocarAcceso(_ empleado: Usuario) {
        guard let contexto else { return }
        empleado.activo = false
        try? contexto.save()
    }

    /// Cierra la sesión local (no borra datos).
    func cerrarSesion() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: claveUsuarioID)
        defaults.removeObject(forKey: claveTiendaID)
        appState?.cerrarSesion()
    }

    private func guardarSesion(usuario: Usuario, tienda: Tienda) {
        let defaults = UserDefaults.standard
        defaults.set(usuario.id, forKey: claveUsuarioID)
        defaults.set(tienda.id, forKey: claveTiendaID)
    }
}
