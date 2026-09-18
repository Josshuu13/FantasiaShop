//
//  CobrarSheet.swift
//  FantasiaShop
//
//  Created by Josue Cardoso on 16/06/26.
//

import SwiftUI

/// Hoja de cobro: método de pago, efectivo recibido y cálculo de cambio.
struct CobrarSheet: View {
    let ventaVM: VentaViewModel
    /// Se llama cuando la venta se cobró con éxito.
    let alCobrar: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var textoEfectivo = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.fondo.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 24) {
                        totalGrande
                        selectorMetodo
                        if ventaVM.metodoPago == .efectivo {
                            seccionEfectivo
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Cobrar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") { dismiss() }
                        .foregroundStyle(Color.textoSecundario)
                }
            }
            .safeAreaInset(edge: .bottom) {
                botonConfirmar
            }
        }
    }

    // MARK: - Total

    private var totalGrande: some View {
        VStack(spacing: 4) {
            Text("Total a cobrar")
                .font(.subheadline)
                .foregroundStyle(Color.textoSecundario)
            Text(ventaVM.total.comoMoneda)
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .foregroundStyle(Color.acento)
        }
        .padding(.top, 12)
    }

    // MARK: - Método de pago

    private var selectorMetodo: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Método de pago")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.textoSecundario)
            HStack(spacing: 10) {
                ForEach(MetodoPago.allCases) { metodo in
                    Button {
                        ventaVM.metodoPago = metodo
                    } label: {
                        Text(metodo.nombre)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(ventaVM.metodoPago == metodo ? .white : Color.textoPrimario)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(ventaVM.metodoPago == metodo ? Color.acento : Color.superficie)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12)
                                .stroke(ventaVM.metodoPago == metodo ? Color.clear : Color.borde, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Efectivo y cambio

    private var seccionEfectivo: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Efectivo recibido")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.textoSecundario)

            TextField("$0.00", text: $textoEfectivo)
                .keyboardType(.decimalPad)
                .font(.title2.bold())
                .padding(14)
                .background(Color.superficie)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.borde, lineWidth: 1))
                .foregroundStyle(Color.textoPrimario)
                .onChange(of: textoEfectivo) { _, nuevo in
                    ventaVM.efectivoRecibido = Double(nuevo) ?? 0
                }

            // Botones rápidos de billetes comunes.
            HStack(spacing: 8) {
                ForEach(billetesSugeridos, id: \.self) { monto in
                    Button {
                        textoEfectivo = String(format: "%.0f", monto)
                        ventaVM.efectivoRecibido = monto
                    } label: {
                        Text(monto.comoMoneda)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.acento)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.acentoSuave)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                }
            }

            // Cambio a devolver.
            if ventaVM.efectivoRecibido > 0 {
                HStack {
                    Text("Cambio")
                        .font(.headline)
                        .foregroundStyle(Color.textoPrimario)
                    Spacer()
                    Text(ventaVM.cambio.comoMoneda)
                        .font(.title3.bold())
                        .foregroundStyle(ventaVM.efectivoRecibido >= ventaVM.total
                                         ? Color.exito : Color.critico)
                }
                .padding(14)
                .background(Color.superficie)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                if ventaVM.efectivoRecibido < ventaVM.total {
                    Text("El efectivo no alcanza para cubrir el total.")
                        .font(.caption)
                        .foregroundStyle(Color.critico)
                }
            }
        }
    }

    /// Sugerencias de billetes mexicanos por encima del total.
    private var billetesSugeridos: [Double] {
        let comunes: [Double] = [50, 100, 200, 500, 1000]
        return comunes.filter { $0 >= ventaVM.total }.prefix(4).map { $0 }
    }

    // MARK: - Confirmar

    private var botonConfirmar: some View {
        Button {
            if ventaVM.cobrar() != nil {
                alCobrar()
                dismiss()
            }
        } label: {
            Text("Confirmar venta")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(ventaVM.puedeCobrar ? Color.acento : Color.acento.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(!ventaVM.puedeCobrar)
        .padding(16)
        .background(.ultraThinMaterial)
    }
}

#Preview {
    let vm = VentaViewModel()
    return CobrarSheet(ventaVM: vm, alCobrar: {})
}
