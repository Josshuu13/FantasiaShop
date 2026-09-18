//
//  AsistenteView.swift
//  FantasiaShop
//
//  Created by Josue Cardoso on 02/09/26.
//

import SwiftUI
import SwiftData

/// Asistente conversacional del dueño: chips de preguntas rápidas + escritura libre.
struct AsistenteView: View {
    @Environment(\.modelContext) private var contexto
    @Environment(AppState.self) private var appState

    @State private var resumenVM = ResumenViewModel()
    @State private var asistenteVM = AsistenteViewModel()
    @State private var textoEntrada = ""

    var body: some View {
        ZStack {
            Color.fondo.ignoresSafeArea()
            VStack(spacing: 0) {
                conversacion
                chipsPreguntas
                barraEntrada
            }
        }
        .navigationTitle("Asistente")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            resumenVM.configurar(contexto: contexto, appState: appState)
            asistenteVM.configurar(resumenVM: resumenVM)
        }
    }

    // MARK: - Conversación

    private var conversacion: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(asistenteVM.mensajes) { mensaje in
                        burbuja(mensaje)
                            .id(mensaje.id)
                    }
                }
                .padding(16)
            }
            .onChange(of: asistenteVM.mensajes.count) { _, _ in
                if let ultimo = asistenteVM.mensajes.last {
                    withAnimation { proxy.scrollTo(ultimo.id, anchor: .bottom) }
                }
            }
        }
    }

    private func burbuja(_ mensaje: MensajeAsistente) -> some View {
        HStack {
            if mensaje.esDelUsuario { Spacer(minLength: 40) }
            Text(mensaje.texto)
                .font(.subheadline)
                .foregroundStyle(mensaje.esDelUsuario ? .white : Color.textoPrimario)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(mensaje.esDelUsuario ? Color.acento : Color.superficie)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(mensaje.esDelUsuario ? Color.clear : Color.borde, lineWidth: 1)
                )
            if !mensaje.esDelUsuario { Spacer(minLength: 40) }
        }
    }

    // MARK: - Chips

    private var chipsPreguntas: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(asistenteVM.preguntasRapidas) { pregunta in
                    Button {
                        asistenteVM.preguntar(pregunta)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: pregunta.icono)
                                .font(.caption)
                            Text(pregunta.titulo)
                                .font(.caption.weight(.medium))
                                .lineLimit(1)
                        }
                        .foregroundStyle(Color.acento)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.acentoSuave)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .background(Color.fondo)
    }

    // MARK: - Barra de entrada

    private var barraEntrada: some View {
        HStack(spacing: 10) {
            TextField("Escribe tu pregunta…", text: $textoEntrada)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color.superficie)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.borde, lineWidth: 1))
                .foregroundStyle(Color.textoPrimario)
                .onSubmit(enviar)

            Button(action: enviar) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(textoEntrada.isEmpty ? Color.textoSecundario : Color.acento)
            }
            .disabled(textoEntrada.isEmpty)
        }
        .padding(12)
        .background(Color.superficie)
        .overlay(Rectangle().frame(height: 1).foregroundStyle(Color.borde), alignment: .top)
    }

    private func enviar() {
        let texto = textoEntrada
        textoEntrada = ""
        asistenteVM.preguntarTexto(texto)
    }
}

#Preview {
    NavigationStack {
        AsistenteView()
            .environment(AppState())
            .modelContainer(for: [Producto.self, Venta.self, LineaVenta.self, Usuario.self, Tienda.self],
                            inMemory: true)
    }
}
