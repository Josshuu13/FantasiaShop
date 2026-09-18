//
//  HomeView.swift
//  FantasiaShop
//
//  Created by Josue Cardoso on 15/06/26.
//

import SwiftUI
import SwiftData

/// Pantalla de inicio. Bifurca la experiencia según el rol del usuario.
struct HomeView: View {
    let authVM: AuthViewModel

    @Environment(\.modelContext) private var contexto
    @Environment(AppState.self) private var appState

    @State private var resumenVM = ResumenViewModel()
    @State private var mostrandoCodigoInvitacion = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.fondo.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 24) {
                        encabezado
                        if appState.esDueño {
                            metricasDelDia
                        }
                        botonesPrincipales
                        if appState.esDueño {
                            seccionDueño
                        } else {
                            seccionEmpleadoBloqueada
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: 520)
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        authVM.cerrarSesion()
                    } label: {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .foregroundStyle(Color.textoSecundario)
                    }
                }
            }
            .onAppear {
                resumenVM.configurar(contexto: contexto, appState: appState)
            }
            .sheet(isPresented: $mostrandoCodigoInvitacion) {
                GenerarCodigoSheet(authVM: authVM)
            }
        }
    }

    // MARK: - Encabezado

    private var encabezado: some View {
        VStack(alignment: .leading, spacing: 6) {
            if appState.esEmpleado {
                HStack(spacing: 6) {
                    Image(systemName: "person.fill")
                        .font(.caption2)
                    Text("Empleado · \(appState.tiendaActual?.nombre ?? "")")
                        .font(.caption.weight(.semibold))
                }
                .foregroundStyle(Color.acento)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.acentoSuave)
                .clipShape(Capsule())
            }

            Text(saludo)
                .font(.title3)
                .foregroundStyle(Color.textoSecundario)
            Text(appState.usuarioActual?.nombre ?? "")
                .font(.largeTitle.bold())
                .foregroundStyle(Color.textoPrimario)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var saludo: String {
        let hora = Calendar.current.component(.hour, from: .now)
        switch hora {
        case 5..<12:  return "Buenos días,"
        case 12..<19: return "Buenas tardes,"
        default:      return "Buenas noches,"
        }
    }

    // MARK: - Métricas (solo dueño)

    private var metricasDelDia: some View {
        HStack(spacing: 12) {
            tarjetaMetrica(valor: resumenVM.totalVendido.comoMoneda,
                           etiqueta: "Vendido hoy", destacar: true)
            tarjetaMetrica(valor: "\(resumenVM.piezas)", etiqueta: "Piezas")
            tarjetaMetrica(valor: "\(resumenVM.transacciones)", etiqueta: "Ventas")
        }
    }

    private func tarjetaMetrica(valor: String, etiqueta: String,
                                destacar: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(valor)
                .font(.title3.bold())
                .foregroundStyle(destacar ? Color.acento : Color.textoPrimario)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(etiqueta)
                .font(.caption)
                .foregroundStyle(Color.textoSecundario)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.superficie)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.borde, lineWidth: 1))
    }

    // MARK: - Botones principales

    private var botonesPrincipales: some View {
        VStack(spacing: 14) {
            // Venta: botón primario en morado, para ambos roles.
            NavigationLink {
                VentaView()
            } label: {
                botonGrande(icono: "barcode.viewfinder",
                            titulo: "Modo venta",
                            subtitulo: "Escanea y cobra",
                            primario: true)
            }
            .buttonStyle(.plain)

            // Inventario: botón secundario en blanco.
            NavigationLink {
                InventarioView()
            } label: {
                botonGrande(icono: "shippingbox.fill",
                            titulo: appState.esDueño ? "Inventario" : "Ver inventario",
                            subtitulo: appState.esDueño ? "Administra tus productos"
                                                        : "Consulta existencias",
                            primario: false)
            }
            .buttonStyle(.plain)
        }
    }

    private func botonGrande(icono: String, titulo: String, subtitulo: String,
                             primario: Bool) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icono)
                .font(.title)
                .foregroundStyle(primario ? Color.white : Color.acento)
                .frame(width: 56, height: 56)
                .background(primario ? Color.white.opacity(0.18) : Color.acentoSuave)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            VStack(alignment: .leading, spacing: 3) {
                Text(titulo)
                    .font(.title3.bold())
                    .foregroundStyle(primario ? Color.white : Color.textoPrimario)
                Text(subtitulo)
                    .font(.subheadline)
                    .foregroundStyle(primario ? Color.white.opacity(0.85) : Color.textoSecundario)
            }
            Spacer(minLength: 0)
        }
        .padding(20)
        .background(primario ? Color.acento : Color.superficie)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(primario ? Color.clear : Color.borde, lineWidth: 1)
        )
    }

    // MARK: - Sección dueño (Resumen + gestión)

    private var seccionDueño: some View {
        VStack(spacing: 14) {
            
            NavigationLink {
                AsistenteView()
            } label: {
                filaSeccion(icono: "sparkles",
                            titulo: "Asistente",
                            subtitulo: "Pregunta por tus ventas e inventario",
                            bloqueada: false)
            }
            .buttonStyle(.plain)
            
            
            NavigationLink {
                ResumenView()
            } label: {
                filaSeccion(icono: "chart.bar.fill",
                            titulo: "Resumen del día",
                            subtitulo: "Métricas, top productos y PDF",
                            bloqueada: false)
            }
            .buttonStyle(.plain)

            Button {
                mostrandoCodigoInvitacion = true
            } label: {
                filaSeccion(icono: "person.badge.plus",
                            titulo: "Invitar empleado",
                            subtitulo: "Genera un código de acceso",
                            bloqueada: false)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Sección empleado (bloqueada, visible con candado)

    private var seccionEmpleadoBloqueada: some View {
        VStack(spacing: 14) {
            filaSeccion(icono: "chart.bar.fill",
                        titulo: "Resumen del día",
                        subtitulo: "Solo disponible para el dueño",
                        bloqueada: true)
        }
    }

    private func filaSeccion(icono: String, titulo: String, subtitulo: String,
                             bloqueada: Bool) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icono)
                .font(.title3)
                .foregroundStyle(bloqueada ? Color.textoSecundario : Color.acento)
                .frame(width: 44, height: 44)
                .background(bloqueada ? Color.borde.opacity(0.4) : Color.acentoSuave)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 2) {
                Text(titulo)
                    .font(.headline)
                    .foregroundStyle(bloqueada ? Color.textoSecundario : Color.textoPrimario)
                Text(subtitulo)
                    .font(.caption)
                    .foregroundStyle(Color.textoSecundario)
            }
            Spacer(minLength: 0)
            Image(systemName: bloqueada ? "lock.fill" : "chevron.right")
                .font(.subheadline)
                .foregroundStyle(Color.textoSecundario)
        }
        .padding(16)
        .background(Color.superficie)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.borde, lineWidth: 1))
    }
}



#Preview {
    HomeView(authVM: AuthViewModel())
        .environment(AppState())
        .modelContainer(for: [Producto.self, Venta.self, LineaVenta.self, Usuario.self, Tienda.self],
                        inMemory: true)
}
