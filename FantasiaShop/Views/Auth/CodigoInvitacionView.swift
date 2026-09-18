//
//  CodigoInvitacionView.swift
//  FantasiaShop
//
//  Created by Josue Cardoso on 15/06/26.
//

import SwiftUI

/// El empleado ingresa su nombre y el código de 6 dígitos para vincularse a la tienda.
struct CodigoInvitacionView: View {
    let authVM: AuthViewModel

    @State private var nombreEmpleado = ""
    @State private var codigo = ""

    var body: some View {
        ZStack {
            Color.fondo.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 28) {
                    encabezado
                    campos
                    if let error = authVM.mensajeError {
                        Text(error)
                            .font(.subheadline)
                            .foregroundStyle(Color.critico)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    botonEntrar
                    Spacer(minLength: 0)
                }
                .padding(24)
                .frame(maxWidth: 480)
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("Ingresar código")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var encabezado: some View {
        VStack(spacing: 12) {
            Image(systemName: "key.fill")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(Color.acento)
                .frame(width: 64, height: 64)
                .background(Color.acentoSuave)
                .clipShape(RoundedRectangle(cornerRadius: 18))
            Text("Únete a la tienda")
                .font(.title2.bold())
                .foregroundStyle(Color.textoPrimario)
            Text("Pide al dueño el código de 6 dígitos que aparece en su app.")
                .font(.subheadline)
                .foregroundStyle(Color.textoSecundario)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 24)
    }

    private var campos: some View {
        VStack(spacing: 14) {
            TextField("Tu nombre", text: $nombreEmpleado)
                .padding(14)
                .background(Color.superficie)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.borde, lineWidth: 1))
                .foregroundStyle(Color.textoPrimario)

            TextField("Código de 6 dígitos", text: $codigo)
                .keyboardType(.numberPad)
                .font(.title3.monospacedDigit())
                .multilineTextAlignment(.center)
                .padding(14)
                .background(Color.superficie)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.borde, lineWidth: 1))
                .foregroundStyle(Color.textoPrimario)
                .onChange(of: codigo) { _, nuevo in
                    // Solo dígitos, máximo 6.
                    let filtrado = nuevo.filter(\.isNumber)
                    codigo = String(filtrado.prefix(6))
                }
        }
    }

    private var botonEntrar: some View {
        Button {
            _ = authVM.ingresarComoEmpleado(
                codigo: codigo,
                nombreEmpleado: nombreEmpleado.trimmingCharacters(in: .whitespaces)
            )
        } label: {
            Text("Entrar")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(formularioValido ? Color.acento : Color.acento.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(!formularioValido)
    }

    private var formularioValido: Bool {
        codigo.count == 6 && !nombreEmpleado.trimmingCharacters(in: .whitespaces).isEmpty
    }
}

#Preview {
    NavigationStack {
        CodigoInvitacionView(authVM: AuthViewModel())
    }
}
