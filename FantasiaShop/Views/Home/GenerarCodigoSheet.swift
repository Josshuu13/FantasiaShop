//
//  GenerarCodigoSheet.swift
//  FantasiaShop
//
//  Created by Josue Cardoso on 15/06/26.
//

import SwiftUI

/// Hoja para que el dueño genere y comparta el código de invitación de 6 dígitos.
struct GenerarCodigoSheet: View {
    let authVM: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var codigo: String?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.fondo.ignoresSafeArea()
                VStack(spacing: 28) {
                    Spacer()

                    Image(systemName: "person.badge.key.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(Color.acento)

                    VStack(spacing: 8) {
                        Text("Invitar empleado")
                            .font(.title2.bold())
                            .foregroundStyle(Color.textoPrimario)
                        Text("Comparte este código con tu empleado. Es válido por 24 horas.")
                            .font(.subheadline)
                            .foregroundStyle(Color.textoSecundario)
                            .multilineTextAlignment(.center)
                    }

                    if let codigo {
                        Text(codigo)
                            .font(.system(size: 44, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .tracking(8)
                            .foregroundStyle(Color.acento)
                            .padding(.vertical, 20)
                            .frame(maxWidth: .infinity)
                            .background(Color.acentoSuave)
                            .clipShape(RoundedRectangle(cornerRadius: 16))

                        ShareLink(item: "Tu código para entrar a la tienda en FantasiaShop es: \(codigo)") {
                            Label("Compartir por WhatsApp", systemImage: "square.and.arrow.up")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.acento)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    } else {
                        Button {
                            codigo = authVM.generarCodigoInvitacion()
                        } label: {
                            Text("Generar código")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.acento)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    }

                    Spacer()
                }
                .padding(24)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Listo") { dismiss() }
                        .foregroundStyle(Color.acento)
                }
            }
        }
    }
}

#Preview {
    GenerarCodigoSheet(authVM: AuthViewModel())
}
