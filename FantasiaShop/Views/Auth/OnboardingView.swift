//
//  OnboardingView.swift
//  FantasiaShop
//
//  Created by Josue Cardoso on 15/06/26.
//

import SwiftUI

/// Primer inicio de la app: el usuario elige si es dueño o empleado.
struct OnboardingView: View {
    /// ViewModel de autenticación, compartido desde VistaRaiz.
    let authVM: AuthViewModel

    @State private var mostrandoFormDueño = false
    @State private var nombreTienda = ""
    @State private var nombreDueño = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.fondo.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 36) {
                        encabezado
                        if mostrandoFormDueño {
                            formularioDueño
                        } else {
                            opciones
                        }
                    }
                    .padding(24)
                    .frame(maxWidth: 480)
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }

    // MARK: - Encabezado

    private var encabezado: some View {
        VStack(spacing: 14) {
            Image(systemName: "bag.fill")
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 76, height: 76)
                .background(Color.acento)
                .clipShape(RoundedRectangle(cornerRadius: 20))

            Text("FantasiaShop")
                .font(.largeTitle.bold())
                .foregroundStyle(Color.textoPrimario)

            Text("Tu inventario y tus ventas, en un solo lugar.")
                .font(.subheadline)
                .foregroundStyle(Color.textoSecundario)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 40)
    }

    // MARK: - Opciones de rol

    private var opciones: some View {
            VStack(spacing: 16) {
                // Si ya existe un dueño en este dispositivo, ofrecer reconectarlo.
                if authVM.existeDueño {
                    Button {
                        authVM.reconectarDueño()
                    } label: {
                        tarjetaOpcion(icono: "crown.fill",
                                      titulo: "Entrar como dueño",
                                      subtitulo: "Vuelve a tu tienda ya creada",
                                      primaria: true)
                    }
                    .buttonStyle(.plain)
                }

                // Crear una tienda nueva como dueño.
                Button {
                    withAnimation { mostrandoFormDueño = true }
                } label: {
                    tarjetaOpcion(icono: "crown.fill",
                                  titulo: authVM.existeDueño ? "Crear otra tienda" : "Soy el dueño",
                                  subtitulo: "Configura una tienda desde cero",
                                  primaria: !authVM.existeDueño)
                }
                .buttonStyle(.plain)

                // Empleado: navega a ingresar código.
                NavigationLink {
                    CodigoInvitacionView(authVM: authVM)
                } label: {
                    tarjetaOpcion(icono: "person.fill",
                                  titulo: "Soy empleado",
                                  subtitulo: "Tengo un código de invitación",
                                  primaria: false)
                }
                .buttonStyle(.plain)
            }
        }
    
    

    private func tarjetaOpcion(icono: String, titulo: String, subtitulo: String,
                               primaria: Bool) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icono)
                .font(.title2)
                .foregroundStyle(primaria ? Color.white : Color.acento)
                .frame(width: 44, height: 44)
                .background(primaria ? Color.white.opacity(0.18) : Color.acentoSuave)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 3) {
                Text(titulo)
                    .font(.headline)
                    .foregroundStyle(primaria ? Color.white : Color.textoPrimario)
                Text(subtitulo)
                    .font(.subheadline)
                    .foregroundStyle(primaria ? Color.white.opacity(0.85) : Color.textoSecundario)
                    .multilineTextAlignment(.leading)
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(primaria ? Color.white.opacity(0.85) : Color.textoSecundario)
        }
        .padding(18)
        .background(primaria ? Color.acento : Color.superficie)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(primaria ? Color.clear : Color.borde, lineWidth: 1)
        )
    }

    // MARK: - Formulario del dueño

    private var formularioDueño: some View {
        VStack(spacing: 20) {
            VStack(spacing: 14) {
                campoTexto(titulo: "Nombre de la tienda", texto: $nombreTienda)
                campoTexto(titulo: "Tu nombre", texto: $nombreDueño)
            }

            Button {
                authVM.registrarDueño(
                    nombreTienda: nombreTienda.trimmingCharacters(in: .whitespaces),
                    nombreDueño: nombreDueño.trimmingCharacters(in: .whitespaces)
                )
            } label: {
                Text("Crear mi tienda")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(formularioValido ? Color.acento : Color.acento.opacity(0.4))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .disabled(!formularioValido)

            Button {
                withAnimation { mostrandoFormDueño = false }
            } label: {
                Text("Regresar")
                    .font(.subheadline)
                    .foregroundStyle(Color.textoSecundario)
            }
        }
    }

    private var formularioValido: Bool {
        !nombreTienda.trimmingCharacters(in: .whitespaces).isEmpty &&
        !nombreDueño.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func campoTexto(titulo: String, texto: Binding<String>) -> some View {
        TextField(titulo, text: texto)
            .padding(14)
            .background(Color.superficie)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.borde, lineWidth: 1))
            .foregroundStyle(Color.textoPrimario)
    }
}

#Preview {
    OnboardingView(authVM: AuthViewModel())
}
