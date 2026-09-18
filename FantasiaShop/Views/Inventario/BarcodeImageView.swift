//
//  BarcodeImageView.swift
//  FantasiaShop
//
//  Created by Josue Cardoso on 16/06/26.
//

import SwiftUI

/// Muestra el código de barras Code128 del producto, listo para imprimir o guardar.
struct BarcodeImageView: View {
    let producto: Producto
    @Environment(\.dismiss) private var dismiss

    private var imagenBarcode: UIImage? {
        BarcodeGenerator.generar(desde: producto.codigoBarras)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.fondo.ignoresSafeArea()
                VStack(spacing: 24) {
                    Spacer()

                    Text(producto.nombre)
                        .font(.title3.bold())
                        .foregroundStyle(Color.textoPrimario)

                    if let imagen = imagenBarcode {
                        VStack(spacing: 10) {
                            Image(uiImage: imagen)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 140)
                            Text(producto.codigoBarras)
                                .font(.subheadline.monospaced())
                                .foregroundStyle(Color.textoSecundario)
                        }
                        .padding(24)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.borde, lineWidth: 1))
                    } else {
                        Text("No se pudo generar el código.")
                            .foregroundStyle(Color.critico)
                    }

                    Text("Imprime, recorta y pega esta etiqueta en el producto o el estante.")
                        .font(.caption)
                        .foregroundStyle(Color.textoSecundario)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Spacer()

                    if let imagen = imagenBarcode {
                        HStack(spacing: 12) {
                            Button {
                                imprimir(imagen)
                            } label: {
                                Label("Imprimir", systemImage: "printer.fill")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color.acento)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                            }

                            ShareLink(item: Image(uiImage: imagen),
                                      preview: SharePreview(producto.nombre, image: Image(uiImage: imagen))) {
                                Label("Guardar", systemImage: "square.and.arrow.down")
                                    .font(.headline)
                                    .foregroundStyle(Color.acento)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color.acentoSuave)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                        }
                    }
                }
                .padding(20)
            }
            .navigationTitle("Código de barras")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Listo") { dismiss() }
                        .foregroundStyle(Color.acento)
                }
            }
        }
    }

    /// Lanza el diálogo de impresión de iOS (AirPrint).
    private func imprimir(_ imagen: UIImage) {
        let info = UIPrintInfo(dictionary: nil)
        info.outputType = .general
        info.jobName = "Etiqueta - \(producto.nombre)"

        let controlador = UIPrintInteractionController.shared
        controlador.printInfo = info
        controlador.printingItem = imagen
        controlador.present(animated: true)
    }
}

#Preview {
    let p = Producto(nombre: "Gorra roja", categoria: .gorras, precio: 180,
                     stock: 8, stockMinimo: 3, codigoBarras: "123456789012")
    return BarcodeImageView(producto: p)
}
