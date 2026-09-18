//
//  DetalleDiaView.swift
//  FantasiaShop
//
//  Created by Josue Cardoso on 31/08/26.
//

import SwiftUI

/// Muestra todas las ventas de un día concreto.
struct DetalleDiaView: View {
    let dia: Date
    let ventas: [Venta]

    private var totalDia: Double { ventas.reduce(0) { $0 + $1.total } }

    var body: some View {
        ZStack {
            Color.fondo.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 12) {
                    resumenDia
                    ForEach(ventas) { venta in
                        NavigationLink {
                            DetalleVentaView(venta: venta)
                        } label: {
                            filaVenta(venta)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(16)
            }
        }
        .navigationTitle(dia.textoFechaCorta)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var resumenDia: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Total del día")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.85))
                Text(totalDia.comoMoneda)
                    .font(.title2.bold())
                    .foregroundStyle(.white)
            }
            Spacer()
            Text("\(ventas.count) \(ventas.count == 1 ? "venta" : "ventas")")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
        }
        .padding(18)
        .background(Color.acento)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func filaVenta(_ venta: Venta) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "receipt")
                .font(.title3)
                .foregroundStyle(Color.acento)
                .frame(width: 40, height: 40)
                .background(Color.acentoSuave)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            VStack(alignment: .leading, spacing: 3) {
                Text(venta.fecha.textoHora)
                    .font(.headline)
                    .foregroundStyle(Color.textoPrimario)
                Text("\(venta.piezas) pza · \(venta.metodoPago.nombre)")
                    .font(.caption)
                    .foregroundStyle(Color.textoSecundario)
            }
            Spacer(minLength: 8)
            Text(venta.total.comoMoneda)
                .font(.headline)
                .foregroundStyle(Color.textoPrimario)
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(Color.textoSecundario)
        }
        .padding(14)
        .background(Color.superficie)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.borde, lineWidth: 1))
    }
}

#Preview {
    NavigationStack {
        DetalleDiaView(dia: .now, ventas: [])
    }
}
