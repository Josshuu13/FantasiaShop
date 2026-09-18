//
//  EscanerSheet.swift
//  FantasiaShop
//
//  Created by Josue Cardoso on 16/06/26.
//

import SwiftUI

/// Presenta el escáner a pantalla completa con su botón de cerrar.
struct EscanerSheet: View {
    let alEscanear: (String) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                EscanerView { codigo in
                    alEscanear(codigo)
                    // Cierra al primer escaneo válido; reabrir para el siguiente producto.
                    dismiss()
                }
                .ignoresSafeArea()

                // Marco guía visual.
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.85), lineWidth: 3)
                    .frame(width: 260, height: 160)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cerrar") { dismiss() }
                        .foregroundStyle(.white)
                }
                ToolbarItem(placement: .principal) {
                    Text("Escanea el código")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
            }
        }
    }
}
