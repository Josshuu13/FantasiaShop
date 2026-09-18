//
//  InventarioView.swift
//  FantasiaShop
//
//  Created by Josue Cardoso on 16/06/26.
//

import SwiftUI
import SwiftData

/// Lista de inventario con filtros, búsqueda y CRUD (según rol).
struct InventarioView: View {
    @Environment(\.modelContext) private var contexto
    @Environment(AppState.self) private var appState

    @State private var inventarioVM = InventarioViewModel()
    @State private var mostrandoNuevo = false
    @State private var productoAEditar: Producto?
    @State private var productoAVer: Producto?
    
    var body: some View {
        ZStack {
            Color.fondo.ignoresSafeArea()
            VStack(spacing: 0) {
                filtrosCategoria
                if inventarioVM.productosFiltrados.isEmpty {
                    estadoVacio
                } else {
                    lista
                }
            }
        }
        .navigationTitle("Inventario")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $inventarioVM.textoBusqueda, prompt: "Buscar producto")
        .toolbar {
            // Menú de filtro por estado de stock (para todos los roles).
            ToolbarItem(placement: .topBarLeading) {
                Menu {
                    ForEach(FiltroStock.allCases) { filtro in
                        Button {
                            inventarioVM.filtroStock = filtro
                        } label: {
                            Label(filtro.rawValue,
                                  systemImage: inventarioVM.filtroStock == filtro ? "checkmark" : "")
                        }
                    }
                } label: {
                    Image(systemName: inventarioVM.filtroStock == .todos
                          ? "line.3.horizontal.decrease.circle"
                          : "line.3.horizontal.decrease.circle.fill")
                        .foregroundStyle(Color.acento)
                }
            }
            // Solo el dueño puede agregar productos.
            if appState.esDueño {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        mostrandoNuevo = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(Color.acento)
                    }
                }
            }
        }
        .onAppear {
            inventarioVM.configurar(contexto: contexto)
        }
        .sheet(isPresented: $mostrandoNuevo, onDismiss: { inventarioVM.cargarProductos() }) {
            NuevoProductoView(inventarioVM: inventarioVM)
        }
        .sheet(item: $productoAEditar, onDismiss: { inventarioVM.cargarProductos() }) { producto in
            NuevoProductoView(inventarioVM: inventarioVM, productoAEditar: producto)
        }
        .sheet(item: $productoAVer) { producto in
            ProductoDetalleView(producto: producto)
        }
    }

    // MARK: - Filtros por categoría

    private var filtrosCategoria: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // "Todas" limpia todos los filtros de categoría.
                chipFiltro(titulo: "Todas",
                           activo: inventarioVM.categoriaFiltro == nil && inventarioVM.subcategoriaFiltro == nil) {
                    inventarioVM.categoriaFiltro = nil
                    inventarioVM.subcategoriaFiltro = nil
                }

                // Categorías fijas EXCEPTO "Otro" (esa va como menú).
                ForEach(Categoria.allCases.filter { $0 != .otro }) { categoria in
                    chipFiltro(titulo: categoria.nombre,
                               activo: inventarioVM.categoriaFiltro == categoria && inventarioVM.subcategoriaFiltro == nil) {
                        inventarioVM.categoriaFiltro = categoria
                        inventarioVM.subcategoriaFiltro = nil
                    }
                }

                // "Otro" como menú desplegable con sus subcategorías.
                chipMenuOtro
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }

    /// Chip "Otro" que despliega un menú con las subcategorías existentes.
    private var chipMenuOtro: some View {
        // Está activo si se filtró por "Otro" o por alguna de sus subcategorías.
        let activo = inventarioVM.categoriaFiltro == .otro || inventarioVM.subcategoriaFiltro != nil
        // Muestra la subcategoría seleccionada, o "Otro" si no hay ninguna.
        let titulo = inventarioVM.subcategoriaFiltro ?? "Otro"

        return Menu {
            // Ver todos los productos de tipo "Otro" (sin subcategoría específica).
            Button {
                inventarioVM.categoriaFiltro = .otro
                inventarioVM.subcategoriaFiltro = nil
            } label: {
                Label("Todos los de Otro",
                      systemImage: inventarioVM.categoriaFiltro == .otro && inventarioVM.subcategoriaFiltro == nil
                      ? "checkmark" : "")
            }

            if !inventarioVM.subcategoriasExistentes.isEmpty {
                Divider()
                ForEach(inventarioVM.subcategoriasExistentes, id: \.self) { sub in
                    Button {
                        inventarioVM.subcategoriaFiltro = sub
                        inventarioVM.categoriaFiltro = nil
                    } label: {
                        Label(sub, systemImage: inventarioVM.subcategoriaFiltro == sub ? "checkmark" : "")
                    }
                }
            }
        } label: {
            HStack(spacing: 4) {
                Text(titulo)
                    .font(.subheadline.weight(.medium))
                Image(systemName: "chevron.down")
                    .font(.caption2)
            }
            .foregroundStyle(activo ? .white : Color.textoPrimario)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(activo ? Color.acento : Color.superficie)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(activo ? Color.clear : Color.borde, lineWidth: 1))
        }
    }

    private func chipFiltro(titulo: String, activo: Bool, accion: @escaping () -> Void) -> some View {
        Button(action: accion) {
            Text(titulo)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(activo ? .white : Color.textoPrimario)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(activo ? Color.acento : Color.superficie)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(activo ? Color.clear : Color.borde, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Lista

    private var lista: some View {
        ScrollView {
            VStack(spacing: 10) {
                ForEach(inventarioVM.productosFiltrados) { producto in
                    ProductoRow(producto: producto)
                        .onTapGesture {
                            if appState.esDueño {
                                productoAEditar = producto      // dueño: editar
                            } else {
                                productoAVer = producto         // empleado: solo ver
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            if appState.esDueño {
                                Button(role: .destructive) {
                                    inventarioVM.eliminarProducto(producto)
                                } label: {
                                    Label("Eliminar", systemImage: "trash")
                                }
                            }
                        }
                }
            }
            .padding(16)
        }
    }

    // MARK: - Estado vacío

    private var estadoVacio: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "shippingbox")
                .font(.system(size: 52))
                .foregroundStyle(Color.textoSecundario)
            Text(hayProductos ? "Sin resultados" : "Inventario vacío")
                .font(.title3.bold())
                .foregroundStyle(Color.textoPrimario)
            Text(mensajeVacio)
                .font(.subheadline)
                .foregroundStyle(Color.textoSecundario)
                .multilineTextAlignment(.center)
            if appState.esDueño && !hayProductos {
                Button {
                    mostrandoNuevo = true
                } label: {
                    Label("Agregar producto", systemImage: "plus")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.acento)
                        .clipShape(Capsule())
                }
            }
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
    }

    private var hayProductos: Bool { !inventarioVM.productos.isEmpty }

    private var mensajeVacio: String {
        if hayProductos {
            return "Prueba con otra categoría o búsqueda."
        }
        return appState.esDueño
            ? "Agrega tu primer producto para empezar."
            : "El dueño aún no ha agregado productos."
    }
}

#Preview {
    NavigationStack {
        InventarioView()
            .environment(AppState())
            .modelContainer(for: [Producto.self, Venta.self, LineaVenta.self, Usuario.self, Tienda.self],
                            inMemory: true)
    }
}
