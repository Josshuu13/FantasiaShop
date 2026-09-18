//
//  NuevoProductoView.swift
//  FantasiaShop
//
//  Created by Josue Cardoso on 16/06/26.
//

import SwiftUI
import PhotosUI

/// Formulario para crear o editar un producto.
struct NuevoProductoView: View {
    let inventarioVM: InventarioViewModel
    /// Si viene un producto, la vista funciona en modo edición.
    var productoAEditar: Producto?

    @Environment(\.dismiss) private var dismiss

    @State private var nombre = ""
    @State private var categoria: Categoria = .gorras
    @State private var precioTexto = ""
    @State private var stockTexto = ""
    @State private var stockMinimoTexto = ""
    @State private var fotoSeleccionada: PhotosPickerItem?
    @State private var fotoData: Data?
    @State private var mostrandoBarcode = false
    @State private var subcategoriaTexto = ""
    @State private var mostrandoOpcionesFoto = false
    @State private var mostrandoCamara = false
    @State private var mostrandoGaleria = false


    private var esEdicion: Bool { productoAEditar != nil }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.fondo.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 20) {
                        selectorFoto
                        campos
                        if esEdicion {
                            botonVerBarcode
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle(esEdicion ? "Editar producto" : "Nuevo producto")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancelar") { dismiss() }
                        .foregroundStyle(Color.textoSecundario)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Guardar") { guardar() }
                        .font(.headline)
                        .foregroundStyle(formularioValido ? Color.acento : Color.textoSecundario)
                        .disabled(!formularioValido)
                }
            }
            .onAppear(perform: cargarDatosSiEdita)
            .onChange(of: fotoSeleccionada) { _, nuevo in
                Task {
                    if let datos = try? await nuevo?.loadTransferable(type: Data.self) {
                        fotoData = datos
                    }
                }
            }
            .sheet(isPresented: $mostrandoBarcode) {
                if let producto = productoAEditar {
                    BarcodeImageView(producto: producto)
                }
            }
        }
    }

    // MARK: - Foto

    // MARK: - Foto

    private var selectorFoto: some View {
        Button {
            mostrandoOpcionesFoto = true
        } label: {
            ZStack {
                if let fotoData, let imagen = UIImage(data: fotoData) {
                    Image(uiImage: imagen)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 110, height: 110)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                } else {
                    VStack(spacing: 6) {
                        Image(systemName: "camera.fill")
                            .font(.title2)
                        Text("Foto opcional")
                            .font(.caption)
                    }
                    .foregroundStyle(Color.acento)
                    .frame(width: 110, height: 110)
                    .background(Color.acentoSuave)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                }
            }
        }
        .buttonStyle(.plain)
        // Menú: cámara (si hay) + galería.
        .confirmationDialog("Foto del producto", isPresented: $mostrandoOpcionesFoto,
                            titleVisibility: .visible) {
            if CamaraPicker.disponible {
                Button("Tomar foto") { mostrandoCamara = true }
            }
            // La galería se abre con el PhotosPicker de abajo.
            Button("Elegir de galería") { mostrandoGaleria = true }
            if fotoData != nil {
                Button("Quitar foto", role: .destructive) { fotoData = nil }
            }
            Button("Cancelar", role: .cancel) { }
        }
        // Galería (PhotosUI).
        .photosPicker(isPresented: $mostrandoGaleria, selection: $fotoSeleccionada, matching: .images)
        // Cámara (UIKit).
        .fullScreenCover(isPresented: $mostrandoCamara) {
            CamaraPicker { datos in
                fotoData = datos
            }
            .ignoresSafeArea()
        }
    }

    // MARK: - Campos

    private var campos: some View {
        VStack(spacing: 14) {
            campo(titulo: "Nombre", texto: $nombre)

            // Selector de categoría.
            VStack(alignment: .leading, spacing: 8) {
                Text("Categoría")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.textoSecundario)
                    .frame(maxWidth: .infinity, alignment: .leading)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Categoria.allCases) { cat in
                            Button {
                                categoria = cat
                            } label: {
                                Text(cat.nombre)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(categoria == cat ? .white : Color.textoPrimario)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(categoria == cat ? Color.acento : Color.superficie)
                                    .clipShape(Capsule())
                                    .overlay(Capsule().stroke(categoria == cat ? Color.clear : Color.borde, lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }

            
            // Campo libre que aparece solo al elegir "Otro".
            // Cuando es "Otro": elegir una subcategoría existente o escribir una nueva.
            if categoria == .otro {
                VStack(alignment: .leading, spacing: 8) {
                    Text("¿Qué categoría es?")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.textoSecundario)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // Subcategorías ya creadas (para reusar).
                    if !inventarioVM.subcategoriasExistentes.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(inventarioVM.subcategoriasExistentes, id: \.self) { sub in
                                    Button {
                                        subcategoriaTexto = sub
                                    } label: {
                                        Text(sub)
                                            .font(.subheadline.weight(.medium))
                                            .foregroundStyle(subcategoriaTexto == sub ? .white : Color.textoPrimario)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 8)
                                            .background(subcategoriaTexto == sub ? Color.acento : Color.superficie)
                                            .clipShape(Capsule())
                                            .overlay(Capsule().stroke(subcategoriaTexto == sub ? Color.clear : Color.borde, lineWidth: 1))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }

                    // Campo para escribir una subcategoría nueva.
                    TextField("O escribe una nueva", text: $subcategoriaTexto)
                        .padding(14)
                        .background(Color.superficie)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.borde, lineWidth: 1))
                        .foregroundStyle(Color.textoPrimario)
                }
            }
            
            campo(titulo: "Precio", texto: $precioTexto, teclado: .decimalPad)
            HStack(spacing: 12) {
                campo(titulo: "Stock actual", texto: $stockTexto, teclado: .numberPad)
                campo(titulo: "Stock mínimo", texto: $stockMinimoTexto, teclado: .numberPad)
            }
        }
    }

    private func campo(titulo: String, texto: Binding<String>,
                       teclado: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(titulo)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.textoSecundario)
            TextField(titulo, text: texto)
                .keyboardType(teclado)
                .padding(14)
                .background(Color.superficie)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.borde, lineWidth: 1))
                .foregroundStyle(Color.textoPrimario)
        }
        .frame(maxWidth: .infinity)
    }

    private var botonVerBarcode: some View {
        Button {
            mostrandoBarcode = true
        } label: {
            Label("Ver código de barras", systemImage: "barcode")
                .font(.headline)
                .foregroundStyle(Color.acento)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.acentoSuave)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    // MARK: - Lógica

    private var formularioValido: Bool {
            let baseValida =
                !nombre.trimmingCharacters(in: .whitespaces).isEmpty &&
                (Double(precioTexto) ?? 0) > 0 &&
                Int(stockTexto) != nil &&
                Int(stockMinimoTexto) != nil
            // Si es "Otro", pedir que escriban la categoría.
            if categoria == .otro {
                return baseValida && !subcategoriaTexto.trimmingCharacters(in: .whitespaces).isEmpty
            }
            return baseValida
        }

    private func cargarDatosSiEdita() {
            guard let producto = productoAEditar else { return }
            nombre = producto.nombre
            categoria = producto.categoria
            precioTexto = String(producto.precio)
            stockTexto = String(producto.stock)
            stockMinimoTexto = String(producto.stockMinimo)
            fotoData = producto.fotoData
            subcategoriaTexto = producto.subcategoria ?? ""
        }

    private func guardar() {
            let precio = Double(precioTexto) ?? 0
            let stock = Int(stockTexto) ?? 0
            let stockMin = Int(stockMinimoTexto) ?? 0
            let nombreLimpio = nombre.trimmingCharacters(in: .whitespaces)

            // Solo guarda subcategoría si la categoría es "Otro" y se escribió algo.
            let sub: String? = (categoria == .otro)
                ? subcategoriaTexto.trimmingCharacters(in: .whitespaces).nilSiVacio
                : nil

            if let producto = productoAEditar {
                inventarioVM.editarProducto(producto, nombre: nombreLimpio, categoria: categoria,
                                            precio: precio, stock: stock, stockMinimo: stockMin,
                                            fotoData: fotoData, subcategoria: sub)
            } else {
                inventarioVM.agregarProducto(nombre: nombreLimpio, categoria: categoria, precio: precio,
                                             stock: stock, stockMinimo: stockMin, fotoData: fotoData,
                                             subcategoria: sub)
            }
            dismiss()
        }
}

#Preview {
    NuevoProductoView(inventarioVM: InventarioViewModel())
}
