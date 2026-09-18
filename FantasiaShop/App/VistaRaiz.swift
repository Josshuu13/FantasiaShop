//
//  VistaRaiz.swift
//  FantasiaShop
//
//  Created by Josue Cardoso on 15/06/26.
//

import SwiftUI
import SwiftData

/// Vista raíz: decide entre el onboarding y la pantalla principal según haya sesión.
struct VistaRaiz: View {
    @Environment(\.modelContext) private var contexto
    @Environment(AppState.self) private var appState
    @State private var authVM = AuthViewModel()

    var body: some View {
        Group {
                    if appState.sesionIniciada {
                        HomeView(authVM: authVM)
                    } else {
                        OnboardingView(authVM: authVM)
                    }
                }
        .onAppear {
            authVM.configurar(contexto: contexto, appState: appState)
            authVM.restaurarSesion()
        }
        .task {
            await NotificationManager.compartido.solicitarPermiso()
        }
    }

    /// Placeholder temporal mientras no existe HomeView.
    private var sesionTemporal: some View {
        ZStack {
            Color.fondo.ignoresSafeArea()
            VStack(spacing: 14) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(Color.exito)
                Text("Sesión iniciada")
                    .font(.title2.bold())
                    .foregroundStyle(Color.textoPrimario)
                if let usuario = appState.usuarioActual {
                    Text("\(usuario.nombre) · \(usuario.rol.nombre)")
                        .foregroundStyle(Color.textoSecundario)
                }
                if let tienda = appState.tiendaActual {
                    Text(tienda.nombre)
                        .foregroundStyle(Color.textoSecundario)
                }
                Button {
                    authVM.cerrarSesion()
                } label: {
                    Text("Cerrar sesión")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.acento)
                        .padding(.top, 8)
                }
            }
            .padding()
        }
    }
}

#Preview {
    VistaRaiz()
        .environment(AppState())
        .modelContainer(for: [Producto.self, Venta.self, LineaVenta.self, Usuario.self, Tienda.self],
                        inMemory: true)
}
