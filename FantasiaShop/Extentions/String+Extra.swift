//
//  String+Extra.swift
//  FantasiaShop
//
//  Created by Josue Cardoso on 17/06/26.
//

import Foundation

extension String {
    /// Devuelve nil si la cadena está vacía; si no, la cadena misma.
    var nilSiVacio: String? {
        isEmpty ? nil : self
    }
}
