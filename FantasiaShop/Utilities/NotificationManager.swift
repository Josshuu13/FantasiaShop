//
//  Untitled.swift
//  FantasiaShop
//
//  Created by Josue Cardoso on 15/06/26.
//

import Foundation
import UserNotifications
import Observation

/// Gestiona las notificaciones LOCALES de la app (funcionan sin cuenta de paga).
/// Por ahora: alerta de stock bajo tras una venta.
/// La notificación remota al dueño (CloudKit) queda lista para cuando se active CloudKit.
@Observable
final class NotificationManager {

    /// Instancia compartida para usar desde cualquier parte de la app.
    static let compartido = NotificationManager()

    /// Si el usuario ya concedió permiso para notificaciones.
    private(set) var permisoConcedido = false

    private init() {}

    /// Pide permiso al usuario. Llamar una vez al iniciar la app.
    func solicitarPermiso() async {
        let centro = UNUserNotificationCenter.current()
        centro.delegate = NotificationDelegate.compartido   // ← NUEVO: mostrar en primer plano
        do {
            let concedido = try await centro.requestAuthorization(options: [.alert, .sound, .badge])
            await MainActor.run { self.permisoConcedido = concedido }
        } catch {
            await MainActor.run { self.permisoConcedido = false }
        }
    }

    /// Programa una notificación local avisando que un producto llegó a su stock mínimo.
    func avisarStockBajo(nombreProducto: String, stockActual: Int) {
        guard permisoConcedido else { return }

        let contenido = UNMutableNotificationContent()
        contenido.title = "Stock bajo"
        contenido.body = "\(nombreProducto): quedan \(stockActual). Conviene resurtir."
        contenido.sound = .default

        // Se dispara unos segundos después, para no interrumpir el cobro.
        let disparador = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let solicitud = UNNotificationRequest(
            identifier: "stockBajo-\(nombreProducto)-\(UUID().uuidString)",
            content: contenido,
            trigger: disparador
        )
        UNUserNotificationCenter.current().add(solicitud)
    }
}

/// Permite que las notificaciones locales se muestren aunque la app esté abierta.
final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let compartido = NotificationDelegate()

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async
        -> UNNotificationPresentationOptions {
        [.banner, .sound]   // mostrar banner + sonido aunque la app esté en primer plano
    }
}
