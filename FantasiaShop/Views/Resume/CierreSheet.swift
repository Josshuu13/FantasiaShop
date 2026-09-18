//
//  CierreSheet.swift
//  FantasiaShop
//
//  Created by Josue Cardoso on 31/08/26.
//

import SwiftUI

/// Cuadre de caja: compara el efectivo contado físicamente vs. lo registrado.
struct CierreSheet: View {
    let resumenVM: ResumenViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var efectivoContadoTexto = ""

    /// Lo que el sistema registró como efectivo hoy.
    private var efectivoRegistrado: Double {
        resumenVM.totalesPorMetodo[.efectivo] ?? 0
    }

    private var efectivoContado: Double { Double(efectivoContadoTexto) ?? 0 }
    private var diferencia: Double { efectivoContado - efectivoRegistrado }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.fondo.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 20) {
                        Text("Cuadre de caja")
                            .font(.title2.bold())
                            .foregroundStyle(Color.textoPrimario)
                            .padding(.top, 8)

                        filaDato(titulo: "Efectivo registrado por el sistema",
                                 valor: efectivoRegistrado.comoMoneda)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Efectivo contado en caja")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.textoSecundario)
                            TextField("$0.00", text: $efectivoContadoTexto)
                                .keyboardType(.decimalPad)
                                .font(.title2.bold())
                                .padding(14)
                                .background(Color.superficie)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.borde, lineWidth: 1))
                                .foregroundStyle(Color.textoPrimario)
                        }

                        if !efectivoContadoTexto.isEmpty {
                            resultadoCuadre
                        }

                        Spacer(minLength: 0)
                    }
                    .padding(20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Listo") { dismiss() }
                        .foregroundStyle(Color.acento)
                }
            }
        }
    }

    private func filaDato(titulo: String, valor: String) -> some View {
        HStack {
            Text(titulo)
                .font(.subheadline)
                .foregroundStyle(Color.textoSecundario)
            Spacer()
            Text(valor)
                .font(.headline)
                .foregroundStyle(Color.textoPrimario)
        }
        .padding(14)
        .background(Color.superficie)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var resultadoCuadre: some View {
        let cuadra = abs(diferencia) < 0.01
        let sobra = diferencia > 0
        let color: Color = cuadra ? .exito : (sobra ? .advertencia : .critico)
        let texto = cuadra ? "La caja cuadra perfecto"
                  : sobra ? "Sobran \(abs(diferencia).comoMoneda) en caja"
                          : "Faltan \(abs(diferencia).comoMoneda) en caja"
        return VStack(spacing: 8) {
            Image(systemName: cuadra ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                .font(.system(size: 36))
                .foregroundStyle(color)
            Text(texto)
                .font(.headline)
                .foregroundStyle(color)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    CierreSheet(resumenVM: ResumenViewModel())
}
