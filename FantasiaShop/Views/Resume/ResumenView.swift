//
//  ResumeView.swift
//  FantasiaShop
//
//  Created by Josue Cardoso on 31/08/26.
//

import SwiftUI
import SwiftData

/// Resumen del día: métricas, top productos, comparativa, métodos de pago y PDF.
/// Solo el dueño ve el resumen completo de la tienda.
struct ResumenView: View {
    @Environment(\.modelContext) private var contexto
    @Environment(AppState.self) private var appState

    @State private var resumenVM = ResumenViewModel()
    @State private var urlPDF: URL?
    @State private var mostrandoCierre = false

    var body: some View {
        ZStack {
            Color.fondo.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 20) {
                    tarjetaTotal
                    filaMetricas
                    if !resumenVM.totalesPorMetodo.isEmpty {
                        seccionMetodosPago
                    }
                    seccionTopProductos
                    if !resumenVM.productosStockBajo.isEmpty {
                        seccionStockBajo
                    }
                    botones
                }
                .padding(20)
                .frame(maxWidth: 600)
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("Resumen del día")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            resumenVM.configurar(contexto: contexto, appState: appState)
        }
        .sheet(isPresented: $mostrandoCierre) {
            CierreSheet(resumenVM: resumenVM)
        }
        .sheet(item: $urlPDF) { url in
            ShareSheet(url: url)
        }
    }

    // MARK: - Total + comparativa

    private var tarjetaTotal: some View {
        VStack(spacing: 10) {
            Text("Vendido hoy")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.85))
            Text(resumenVM.totalVendido.comoMoneda)
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            // Comparativa con la semana pasada.
            HStack(spacing: 6) {
                Image(systemName: resumenVM.hoyFueMejor ? "arrow.up.right" : "arrow.down.right")
                Text(comparativaTexto)
            }
            .font(.caption.weight(.medium))
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.white.opacity(0.18))
            .clipShape(Capsule())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .background(Color.acento)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var comparativaTexto: String {
        let dif = abs(resumenVM.diferenciaSemanaPasada)
        if resumenVM.totalSemanaPasada == 0 {
            return "Sin datos de la semana pasada"
        }
        return resumenVM.hoyFueMejor
            ? "\(dif.comoMoneda) más que hace una semana"
            : "\(dif.comoMoneda) menos que hace una semana"
    }

    // MARK: - Métricas

    private var filaMetricas: some View {
        HStack(spacing: 12) {
            tarjeta(valor: "\(resumenVM.piezas)", etiqueta: "Piezas")
            tarjeta(valor: "\(resumenVM.transacciones)", etiqueta: "Ventas")
            tarjeta(valor: "\(resumenVM.productosStockBajo.count)", etiqueta: "Stock bajo",
                    color: resumenVM.productosStockBajo.isEmpty ? .textoPrimario : .advertencia)
        }
    }

    private func tarjeta(valor: String, etiqueta: String,
                         color: Color = .textoPrimario) -> some View {
        VStack(spacing: 6) {
            Text(valor).font(.title2.bold()).foregroundStyle(color)
            Text(etiqueta).font(.caption).foregroundStyle(Color.textoSecundario)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.superficie)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.borde, lineWidth: 1))
    }

    // MARK: - Métodos de pago

    private var seccionMetodosPago: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Por método de pago")
                .font(.headline)
                .foregroundStyle(Color.textoPrimario)
            ForEach(MetodoPago.allCases) { metodo in
                let monto = resumenVM.totalesPorMetodo[metodo] ?? 0
                if monto > 0 {
                    HStack {
                        Image(systemName: iconoMetodo(metodo))
                            .foregroundStyle(Color.acento)
                            .frame(width: 28)
                        Text(metodo.nombre)
                            .foregroundStyle(Color.textoPrimario)
                        Spacer()
                        Text(monto.comoMoneda)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.textoPrimario)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.superficie)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.borde, lineWidth: 1))
    }

    private func iconoMetodo(_ metodo: MetodoPago) -> String {
        switch metodo {
        case .efectivo:      return "banknote"
        case .tarjeta:       return "creditcard"
        case .transferencia: return "arrow.left.arrow.right"
        }
    }

    // MARK: - Top productos

    private var seccionTopProductos: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Más vendidos hoy")
                .font(.headline)
                .foregroundStyle(Color.textoPrimario)
            if resumenVM.topProductos.isEmpty {
                Text("Aún no hay ventas hoy.")
                    .font(.subheadline)
                    .foregroundStyle(Color.textoSecundario)
            } else {
                let maximo = resumenVM.topProductos.first?.cantidad ?? 1
                ForEach(Array(resumenVM.topProductos.enumerated()), id: \.offset) { indice, producto in
                    barraProducto(posicion: indice + 1, nombre: producto.nombre,
                                  cantidad: producto.cantidad, maximo: maximo)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.superficie)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.borde, lineWidth: 1))
    }

    private func barraProducto(posicion: Int, nombre: String,
                               cantidad: Int, maximo: Int) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("\(posicion). \(nombre)")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.textoPrimario)
                    .lineLimit(1)
                Spacer()
                Text("\(cantidad) pza")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.textoSecundario)
            }
            GeometryReader { geo in
                let ancho = maximo > 0 ? CGFloat(cantidad) / CGFloat(maximo) : 0
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.acentoSuave).frame(height: 8)
                    Capsule().fill(Color.acento).frame(width: geo.size.width * ancho, height: 8)
                }
            }
            .frame(height: 8)
        }
    }

    // MARK: - Stock bajo

    private var seccionStockBajo: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Productos por resurtir", systemImage: "exclamationmark.triangle.fill")
                .font(.headline)
                .foregroundStyle(Color.advertencia)
            ForEach(resumenVM.productosStockBajo) { producto in
                HStack {
                    Text(producto.nombre)
                        .foregroundStyle(Color.textoPrimario)
                    Spacer()
                    Text(producto.stock == 0 ? "Agotado" : "Quedan \(producto.stock)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(producto.stock == 0 ? Color.critico : Color.advertencia)
                }
                .padding(.vertical, 2)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.superficie)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.advertencia.opacity(0.4), lineWidth: 1))
    }

    // MARK: - Botones

    private var botones: some View {
        VStack(spacing: 12) {
            NavigationLink {
                HistorialVentasView(resumenVM: resumenVM)
            } label: {
                Label("Historial de ventas", systemImage: "clock.arrow.circlepath")
                    .font(.headline)
                    .foregroundStyle(Color.acento)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(Color.acentoSuave)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }

            Button {
                mostrandoCierre = true
            } label: {
                Label("Cuadre de caja", systemImage: "dollarsign.circle")
                    .font(.headline)
                    .foregroundStyle(Color.acento)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(Color.acentoSuave)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }

            Button {
                urlPDF = resumenVM.exportarPDF()
            } label: {
                Label("Exportar corte en PDF", systemImage: "square.and.arrow.up")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(Color.acento)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
    }
}

#Preview {
    NavigationStack {
        ResumenView()
            .environment(AppState())
            .modelContainer(for: [Producto.self, Venta.self, LineaVenta.self, Usuario.self, Tienda.self],
                            inMemory: true)
    }
}
