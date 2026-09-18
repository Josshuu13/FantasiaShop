//
//  TicketRow.swift
//  FantasiaShop
//
//  Created by Josue Cardoso on 16/06/26.
//

import SwiftUI

/// Fila individual del ticket: nombre, precio, controles de cantidad y subtotal.
struct TicketRow: View {
    let linea: LineaTicket
    let alAumentar: () -> Void
    let alDisminuir: () -> Void
    let alQuitar: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(linea.producto.nombre)
                    .font(.headline)
                    .foregroundStyle(Color.textoPrimario)
                    .lineLimit(1)
                Text(linea.precioUnitario.comoMoneda)
                    .font(.subheadline)
                    .foregroundStyle(Color.textoSecundario)
            }

            Spacer(minLength: 8)

            // Controles de cantidad.
            HStack(spacing: 14) {
                Button(action: alDisminuir) {
                    Image(systemName: "minus")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color.acento)
                        .frame(width: 30, height: 30)
                        .background(Color.acentoSuave)
                        .clipShape(Circle())
                }
                Text("\(linea.cantidad)")
                    .font(.headline.monospacedDigit())
                    .foregroundStyle(Color.textoPrimario)
                    .frame(minWidth: 22)
                Button(action: alAumentar) {
                    Image(systemName: "plus")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(Color.acento)
                        .frame(width: 30, height: 30)
                        .background(Color.acentoSuave)
                        .clipShape(Circle())
                }
            }

            // Subtotal de la línea.
            Text(linea.subtotal.comoMoneda)
                .font(.headline)
                .foregroundStyle(Color.textoPrimario)
                .frame(minWidth: 72, alignment: .trailing)
        }
        .padding(14)
        .background(Color.superficie)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.borde, lineWidth: 1))
        .swipeActions(edge: .trailing) {
            Button(role: .destructive, action: alQuitar) {
                Label("Quitar", systemImage: "trash")
            }
        }
    }
}

#Preview {
    // Producto de ejemplo solo para el preview.
    let producto = Producto(nombre: "Gorra negra", categoria: .gorras, precio: 180,
                            stock: 10, stockMinimo: 3, codigoBarras: "123456789012")
    return TicketRow(linea: LineaTicket(producto: producto, cantidad: 2),
                     alAumentar: {}, alDisminuir: {}, alQuitar: {})
        .padding()
        .background(Color.fondo)
}
