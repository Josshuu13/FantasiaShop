//
//  VentaView.swift
//  FantasiaShop
//
//  Created by Josue Cardoso on 16/06/26.
//

import SwiftUI
import SwiftData

/// Modo venta: escaneo (o búsqueda manual) + ticket en vivo + cobro.
struct VentaView: View {
    @Environment(\.modelContext) private var contexto
    @Environment(AppState.self) private var appState

    @State private var ventaVM = VentaViewModel()
    @State private var mostrandoEscaner = false
    @State private var mostrandoCobro = false
    @State private var mostrandoBusqueda = false
    @State private var ventaExitosa = false

    var body: some View {
        ZStack {
            Color.fondo.ignoresSafeArea()

            VStack(spacing: 0) {
                if ventaVM.lineas.isEmpty {
                    estadoVacio
                } else {
                    listaTicket
                    barraTotal
                }
            }
        }
        .navigationTitle("Modo venta")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    abrirEntradaProductos()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(Color.acento)
                }
            }
        }
        .onAppear {
            ventaVM.configurar(contexto: contexto, appState: appState)
        }
        .sheet(isPresented: $mostrandoEscaner) {
            EscanerSheet { codigo in
                ventaVM.agregarPorCodigo(codigo)
            }
        }
        .sheet(isPresented: $mostrandoBusqueda) {
            BusquedaProductoSheet { producto in
                ventaVM.agregarProducto(producto)
            }
        }
        .sheet(isPresented: $mostrandoCobro) {
            CobrarSheet(ventaVM: ventaVM) {
                ventaExitosa = true
            }
        }
        .overlay {
            if ventaExitosa {
                avisoExito
            }
        }
        .alert("Aviso", isPresented: .constant(ventaVM.mensaje != nil)) {
            Button("OK") { ventaVM.mensaje = nil }
        } message: {
            Text(ventaVM.mensaje ?? "")
        }
    }

    /// Abre el escáner si hay cámara; si no (simulador), abre la búsqueda manual.
    private func abrirEntradaProductos() {
        if EscanerView.disponible {
            mostrandoEscaner = true
        } else {
            mostrandoBusqueda = true
        }
    }

    // MARK: - Estado vacío

    private var estadoVacio: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "barcode.viewfinder")
                .font(.system(size: 56))
                .foregroundStyle(Color.acento)
            VStack(spacing: 6) {
                Text("Ticket vacío")
                    .font(.title3.bold())
                    .foregroundStyle(Color.textoPrimario)
                Text(EscanerView.disponible
                     ? "Escanea un producto para empezar."
                     : "Agrega un producto para empezar.")
                    .font(.subheadline)
                    .foregroundStyle(Color.textoSecundario)
            }
            Button {
                abrirEntradaProductos()
            } label: {
                Label(EscanerView.disponible ? "Escanear" : "Agregar producto",
                      systemImage: EscanerView.disponible ? "barcode.viewfinder" : "plus")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 14)
                    .background(Color.acento)
                    .clipShape(Capsule())
            }
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
    }

    // MARK: - Lista del ticket

    private var listaTicket: some View {
        ScrollView {
            VStack(spacing: 10) {
                ForEach(ventaVM.lineas) { linea in
                    TicketRow(
                        linea: linea,
                        alAumentar: { ventaVM.aumentar(linea) },
                        alDisminuir: { ventaVM.disminuir(linea) },
                        alQuitar: { ventaVM.quitar(linea) }
                    )
                }
            }
            .padding(16)
        }
    }

    // MARK: - Barra de total + cobrar

    private var barraTotal: some View {
        VStack(spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(ventaVM.piezas) \(ventaVM.piezas == 1 ? "pieza" : "piezas")")
                        .font(.caption)
                        .foregroundStyle(Color.textoSecundario)
                    Text("Total")
                        .font(.headline)
                        .foregroundStyle(Color.textoPrimario)
                }
                Spacer()
                Text(ventaVM.total.comoMoneda)
                    .font(.title.bold())
                    .foregroundStyle(Color.acento)
            }

            Button {
                mostrandoCobro = true
            } label: {
                Text("Cobrar")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.acento)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
        .padding(16)
        .background(Color.superficie)
        .overlay(Rectangle().frame(height: 1).foregroundStyle(Color.borde), alignment: .top)
    }

    // MARK: - Aviso de éxito

    private var avisoExito: some View {
        ZStack {
            Color.black.opacity(0.3).ignoresSafeArea()
            VStack(spacing: 14) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(Color.exito)
                Text("Venta cobrada")
                    .font(.title3.bold())
                    .foregroundStyle(Color.textoPrimario)
            }
            .padding(36)
            .background(Color.superficie)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                ventaExitosa = false
            }
        }
    }
}

#Preview {
    NavigationStack {
        VentaView()
            .environment(AppState())
            .modelContainer(for: [Producto.self, Venta.self, LineaVenta.self, Usuario.self, Tienda.self],
                            inMemory: true)
    }
}
