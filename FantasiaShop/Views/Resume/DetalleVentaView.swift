//
//  DetalleVentaView.swift
//  FantasiaShop
//
//  Created by Josue Cardoso on 31/08/26.
//

import SwiftUI

/// Detalle completo de una venta: productos, cantidades, método, vendedor y cambio.
struct DetalleVentaView: View {
    let venta: Venta

    private var lineas: [LineaVenta] { venta.lineas ?? [] }

    var body: some View {
        ZStack {
            Color.fondo.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 16) {
                    encabezado
                    listaProductos
                    detallesPago
                }
                .padding(16)
            }
        }
        .navigationTitle("Detalle de venta")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var encabezado: some View {
        VStack(spacing: 6) {
            Text(venta.total.comoMoneda)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text("\(venta.fecha.textoFechaCorta) · \(venta.fecha.textoHora)")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.85))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color.acento)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }

    private var listaProductos: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Productos")
                .font(.headline)
                .foregroundStyle(Color.textoPrimario)
            ForEach(lineas) { linea in
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(linea.nombreProducto)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Color.textoPrimario)
                        Text("\(linea.cantidad) × \(linea.precioUnitario.comoMoneda)")
                            .font(.caption)
                            .foregroundStyle(Color.textoSecundario)
                    }
                    Spacer()
                    Text(linea.subtotal.comoMoneda)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.textoPrimario)
                }
                .padding(.vertical, 4)
                if linea.id != lineas.last?.id {
                    Divider()
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.superficie)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.borde, lineWidth: 1))
    }

    private var detallesPago: some View {
        VStack(spacing: 10) {
            fila("Método de pago", venta.metodoPago.nombre)
            if venta.metodoPago == .efectivo && venta.efectivoRecibido > 0 {
                fila("Efectivo recibido", venta.efectivoRecibido.comoMoneda)
                fila("Cambio", venta.cambio.comoMoneda)
            }
            fila("Vendedor", venta.vendedorNombre)
        }
        .padding(16)
        .background(Color.superficie)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.borde, lineWidth: 1))
    }

    private func fila(_ titulo: String, _ valor: String) -> some View {
        HStack {
            Text(titulo)
                .font(.subheadline)
                .foregroundStyle(Color.textoSecundario)
            Spacer()
            Text(valor)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.textoPrimario)
        }
    }
}

#Preview {
    NavigationStack {
        DetalleVentaView(venta: Venta(total: 360, metodoPago: .efectivo,
                                      efectivoRecibido: 500, vendedorID: "1",
                                      vendedorNombre: "Josué"))
    }
}
