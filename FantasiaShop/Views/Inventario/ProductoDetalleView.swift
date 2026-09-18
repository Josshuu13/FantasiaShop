//
//  ProductoDetalleView.swift
//  FantasiaShop
//
//  Created by Josue Cardoso on 07/09/26.
//

import SwiftUI

/// Vista de SOLO LECTURA de un producto. La usa el empleado para consultar
/// existencias y ver el código de barras, sin poder modificar nada.
struct ProductoDetalleView: View {
    let producto: Producto
    @Environment(\.dismiss) private var dismiss
    @State private var mostrandoBarcode = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.fondo.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 20) {
                        imagenProducto
                        datos
                        botonBarcode
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Detalle del producto")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Listo") { dismiss() }
                        .foregroundStyle(Color.acento)
                }
            }
            .sheet(isPresented: $mostrandoBarcode) {
                BarcodeImageView(producto: producto)
            }
        }
    }

    @ViewBuilder
    private var imagenProducto: some View {
        if let datos = producto.fotoData, let imagen = UIImage(data: datos) {
            Image(uiImage: imagen)
                .resizable()
                .scaledToFill()
                .frame(width: 130, height: 130)
                .clipShape(RoundedRectangle(cornerRadius: 20))
        } else {
            Image(systemName: producto.categoria.icono)
                .font(.system(size: 44))
                .foregroundStyle(Color.acento)
                .frame(width: 130, height: 130)
                .background(Color.acentoSuave)
                .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }

    private var datos: some View {
        VStack(spacing: 12) {
            fila("Nombre", producto.nombre)
            fila("Categoría", producto.categoriaMostrada)
            fila("Precio", producto.precio.comoMoneda)
            fila("Stock actual", "\(producto.stock)")
            fila("Stock mínimo", "\(producto.stockMinimo)")
            filaEstadoStock
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
        .padding(.vertical, 2)
    }

    private var filaEstadoStock: some View {
        let color: Color = producto.stock == 0 ? .critico
                         : producto.stockBajo ? .advertencia : .exito
        let texto = producto.stock == 0 ? "Agotado"
                  : producto.stockBajo ? "Stock bajo" : "Disponible"
        return HStack {
            Text("Estado")
                .font(.subheadline)
                .foregroundStyle(Color.textoSecundario)
            Spacer()
            Text(texto)
                .font(.caption.weight(.semibold))
                .foregroundStyle(color)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(color.opacity(0.12))
                .clipShape(Capsule())
        }
        .padding(.vertical, 2)
    }

    private var botonBarcode: some View {
        Button {
            mostrandoBarcode = true
        } label: {
            Label("Ver código de barras", systemImage: "barcode")
                .font(.headline)
                .foregroundStyle(Color.acento)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.acentoSuave)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}

#Preview {
    let p = Producto(nombre: "Gorra Polo", categoria: .gorras, precio: 100,
                     stock: 10, stockMinimo: 3, codigoBarras: "123456789012")
    return ProductoDetalleView(producto: p)
}
