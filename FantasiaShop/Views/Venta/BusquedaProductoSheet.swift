//
//  BusquedaProductoSheet.swift
//  FantasiaShop
//
//  Created by Josue Cardoso on 16/06/26.
//

import SwiftUI
import SwiftData

/// Búsqueda manual de productos para agregar al ticket.
/// Sirve cuando no hay cámara (simulador) o para vender sin escanear.
struct BusquedaProductoSheet: View {
    let alSeleccionar: (Producto) -> Void

    @Environment(\.modelContext) private var contexto
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Producto.nombre) private var productos: [Producto]
    @State private var texto = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.fondo.ignoresSafeArea()
                Group {
                    if productosFiltrados.isEmpty {
                        estadoVacio
                    } else {
                        lista
                    }
                }
            }
            .navigationTitle("Agregar producto")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $texto, prompt: "Buscar por nombre")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Listo") { dismiss() }
                        .foregroundStyle(Color.acento)
                }
            }
        }
    }

    private var productosFiltrados: [Producto] {
        texto.isEmpty
            ? productos
            : productos.filter { $0.nombre.localizedCaseInsensitiveContains(texto) }
    }

    private var lista: some View {
        ScrollView {
            VStack(spacing: 10) {
                ForEach(productosFiltrados) { producto in
                    Button {
                        alSeleccionar(producto)
                        dismiss()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: producto.categoria.icono)
                                .font(.title3)
                                .foregroundStyle(Color.acento)
                                .frame(width: 40, height: 40)
                                .background(Color.acentoSuave)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(producto.nombre)
                                    .font(.headline)
                                    .foregroundStyle(Color.textoPrimario)
                                Text("Stock: \(producto.stock)")
                                    .font(.caption)
                                    .foregroundStyle(producto.stockBajo ? Color.advertencia : Color.textoSecundario)
                            }
                            Spacer(minLength: 0)
                            Text(producto.precio.comoMoneda)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.textoPrimario)
                        }
                        .padding(14)
                        .background(Color.superficie)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.borde, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)
        }
    }

    private var estadoVacio: some View {
        VStack(spacing: 12) {
            Image(systemName: "shippingbox")
                .font(.system(size: 44))
                .foregroundStyle(Color.textoSecundario)
            Text(productos.isEmpty ? "No hay productos en el inventario." : "Sin resultados.")
                .font(.subheadline)
                .foregroundStyle(Color.textoSecundario)
        }
        .padding()
    }
}

#Preview {
    BusquedaProductoSheet { _ in }
        .modelContainer(for: [Producto.self, Venta.self, LineaVenta.self, Usuario.self, Tienda.self],
                        inMemory: true)
}
