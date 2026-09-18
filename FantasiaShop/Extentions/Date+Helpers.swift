//
//  Date+Helpers.swift
//  FantasiaShop
//
//  Created by Josue Cardoso on 15/06/26.
//

import Foundation

extension Date {
    /// Fecha larga en español de México: "martes, 10 de junio de 2026".
    var textoFechaLarga: String {
        formatted(Date.FormatStyle(date: .complete, time: .omitted)
            .locale(Locale(identifier: "es_MX")))
    }

    /// Solo la hora: "1:24 p.m.".
    var textoHora: String {
        formatted(Date.FormatStyle(date: .omitted, time: .shortened)
            .locale(Locale(identifier: "es_MX")))
    }

    /// Fecha corta: "10/06/2026".
    var textoFechaCorta: String {
        formatted(Date.FormatStyle(date: .numeric, time: .omitted)
            .locale(Locale(identifier: "es_MX")))
    }

    /// Inicio del día (00:00). Útil para filtrar las ventas de hoy.
    var inicioDelDia: Date {
        Calendar.current.startOfDay(for: self)
    }

    /// El mismo día de la semana pasada (para la comparativa del resumen).
    var mismoDiaSemanaPasada: Date {
        Calendar.current.date(byAdding: .day, value: -7, to: self) ?? self
    }
}
