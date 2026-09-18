//
//  HistorialVentasView.swift
//  FantasiaShop
//
//  Created by Josue Cardoso on 31/08/26.
//

import SwiftUI

/// Lista de días con ventas; al tocar un día se ven sus ventas.
struct HistorialVentasView: View {
    let resumenVM: ResumenViewModel

    private var dias: [(dia: Date, ventas: [Venta])] {
        resumenVM.ventasPorDia()
    }

    var body: some View {
        ZStack {
            Color.fondo.ignoresSafeArea()
            if dias.isEmpty {
                estadoVacio
            } else {
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(dias, id: \.dia) { grupo in
                            NavigationLink {
                                DetalleDiaView(dia: grupo.dia, ventas: grupo.ventas)
                            } label: {
                                filaDia(dia: grupo.dia, ventas: grupo.ventas)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(16)
                }
            }
        }
        .navigationTitle("Historial de ventas")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func filaDia(dia: Date, ventas: [Venta]) -> some View {
        let total = ventas.reduce(0) { $0 + $1.total }
        let piezas = ventas.reduce(0) { $0 + $1.piezas }
        return HStack(spacing: 14) {
            Image(systemName: "calendar")
                .font(.title3)
                .foregroundStyle(Color.acento)
                .frame(width: 44, height: 44)
                .background(Color.acentoSuave)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 3) {
                Text(dia.textoFechaLarga.capitalized)
                    .font(.headline)
                    .foregroundStyle(Color.textoPrimario)
                    .lineLimit(1)
                Text("\(ventas.count) \(ventas.count == 1 ? "venta" : "ventas") · \(piezas) pza")
                    .font(.caption)
                    .foregroundStyle(Color.textoSecundario)
            }
            Spacer(minLength: 8)
            VStack(alignment: .trailing, spacing: 2) {
                Text(total.comoMoneda)
                    .font(.headline)
                    .foregroundStyle(Color.textoPrimario)
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(Color.textoSecundario)
            }
        }
        .padding(14)
        .background(Color.superficie)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.borde, lineWidth: 1))
    }

    private var estadoVacio: some View {
        VStack(spacing: 12) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 48))
                .foregroundStyle(Color.textoSecundario)
            Text("Sin ventas registradas")
                .font(.title3.bold())
                .foregroundStyle(Color.textoPrimario)
            Text("Aquí aparecerá el historial cuando empieces a vender.")
                .font(.subheadline)
                .foregroundStyle(Color.textoSecundario)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview {
    NavigationStack {
        HistorialVentasView(resumenVM: ResumenViewModel())
    }
}
