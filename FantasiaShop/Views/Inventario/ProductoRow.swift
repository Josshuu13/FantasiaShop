//
//  ProductoRow.swift
//  FantasiaShop
//
//  Created by Josue Cardoso on 16/06/26.
//

import SwiftUI

/// Fila de producto en la lista de inventario, con badge de stock.
struct ProductoRow: View {
    let producto: Producto

    var body: some View {
        HStack(spacing: 14) {
            // Foto o ícono genérico por categoría.
            grupoImagen

            VStack(alignment: .leading, spacing: 4) {
                Text(producto.nombre)
                    .font(.headline)
                    .foregroundStyle(Color.textoPrimario)
                    .lineLimit(1)
                Text(producto.categoriaMostrada)
                    .font(.caption)
                    .foregroundStyle(Color.textoSecundario)
                badgeStock
            }

            Spacer(minLength: 8)

            Text(producto.precio.comoMoneda)
                .font(.headline)
                .foregroundStyle(Color.textoPrimario)
        }
        .padding(14)
        .background(Color.superficie)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.borde, lineWidth: 1))
    }

    @ViewBuilder
    private var grupoImagen: some View {
        if let datos = producto.fotoData, let imagen = UIImage(data: datos) {
            Image(uiImage: imagen)
                .resizable()
                .scaledToFill()
                .frame(width: 52, height: 52)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        } else {
            Image(systemName: producto.categoria.icono)
                .font(.title2)
                .foregroundStyle(Color.acento)
                .frame(width: 52, height: 52)
                .background(Color.acentoSuave)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var badgeStock: some View {
        let color: Color = producto.stock == 0 ? .critico
                         : producto.stockBajo ? .advertencia : .exito
        let texto = producto.stock == 0 ? "Agotado" : "Stock: \(producto.stock)"
        return Text(texto)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }
}

#Preview {
    let p = Producto(nombre: "Mochila escolar azul", categoria: .mochilas, precio: 450,
                     stock: 2, stockMinimo: 5, codigoBarras: "123456789012")
    return ProductoRow(producto: p)
        .padding()
        .background(Color.fondo)
}
