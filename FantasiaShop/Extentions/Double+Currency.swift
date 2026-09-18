//
//  Double+Currency.swift
//  FantasiaShop
//
//  Created by Josue Cardoso on 15/06/26.
//

import Foundation

extension Double {
    /// Formatea el número como precio en pesos mexicanos: 1240 → "$1,240.00".
    var comoMoneda: String {
        let formateador = NumberFormatter()
        formateador.numberStyle = .currency
        formateador.locale = Locale(identifier: "es_MX")
        formateador.currencySymbol = "$"
        return formateador.string(from: NSNumber(value: self)) ?? "$0.00"
    }

    /// Igual que comoMoneda pero con sufijo " MXN": "$1,240.00 MXN".
    var comoMonedaMXN: String { "\(comoMoneda) MXN" }
}
