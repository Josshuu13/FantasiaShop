//
//  AppState.swift
//  FantasiaShop
//
//  Created by Josue Cardoso on 10/06/26.
//

import Foundation
import SwiftData

/// Estado global de la app: quién tiene la sesión activa y a qué tienda pertenece.
/// La lógica para iniciar sesión / validar códigos vive en AuthViewModel (Fase 3).
@Observable
final class AppState {
    /// Usuario con la sesión activa. nil = aún no se completa el onboarding.
    var usuarioActual: Usuario?
    /// Tienda vinculada a la sesión activa.
    var tiendaActual: Tienda?

    /// True cuando ya hay un usuario y una tienda cargados.
    var sesionIniciada: Bool {
        usuarioActual != nil && tiendaActual != nil
    }

    var esDueño: Bool { usuarioActual?.rol == .dueño }
    var esEmpleado: Bool { usuarioActual?.rol == .empleado }

    /// Cierra la sesión local (no borra datos de SwiftData/CloudKit).
    func cerrarSesion() {
        usuarioActual = nil
        tiendaActual = nil
    }
}
