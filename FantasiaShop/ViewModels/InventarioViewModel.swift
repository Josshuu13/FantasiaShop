//
//  InventarioViewModel.swift
//  FantasiaShop
//
//  Created by Josue Cardoso on 15/06/26.
//

import Foundation
import SwiftData
import Observation



/// Filtro por estado de stock en el inventario.
enum FiltroStock: String, CaseIterable, Identifiable {
    case todos = "Todos"
    case agotados = "Agotados"
    case stockBajo = "Stock bajo"

    var id: String { rawValue }
}

/// Lógica del inventario: CRUD de productos, filtros, búsqueda y surtido en lote.
@Observable
final class InventarioViewModel {
    private var contexto: ModelContext?

    /// Lista cargada desde SwiftData.
    var productos: [Producto] = []

    // Filtros de la lista.
    var textoBusqueda = ""
    var categoriaFiltro: Categoria?   // nil = todas las categorías

    /// Productos capturados en el modo "surtido en lote", aún sin guardar.
    var productosEnLote: [Producto] = []
    /// Subcategoría seleccionada (para productos de tipo "Otro"). nil = ninguna.
    var subcategoriaFiltro: String?
    /// Filtro por estado de stock.
    var filtroStock: FiltroStock = .todos
    

    func configurar(contexto: ModelContext) {
        self.contexto = contexto
        cargarProductos()
    }

    /// Recarga la lista desde la base de datos.
    func cargarProductos() {
        guard let contexto else { return }
        let descriptor = FetchDescriptor<Producto>(sortBy: [SortDescriptor(\.nombre)])
        productos = (try? contexto.fetch(descriptor)) ?? []
    }

    /// Productos tras aplicar categoría + búsqueda.
    /// Productos tras aplicar categoría, subcategoría, estado de stock y búsqueda.
    var productosFiltrados: [Producto] {
        productos.filter { producto in
            // Categoría principal.
            let coincideCategoria = categoriaFiltro == nil || producto.categoria == categoriaFiltro
            // Subcategoría (solo si hay una seleccionada).
            let coincideSubcategoria = subcategoriaFiltro == nil || producto.subcategoria == subcategoriaFiltro
            // Estado de stock.
            let coincideStock: Bool
            switch filtroStock {
            case .todos:     coincideStock = true
            case .agotados:  coincideStock = producto.stock == 0
            case .stockBajo: coincideStock = producto.stockBajo && producto.stock > 0
            }
            // Búsqueda por nombre.
            let coincideBusqueda = textoBusqueda.isEmpty ||
                producto.nombre.localizedCaseInsensitiveContains(textoBusqueda)

            return coincideCategoria && coincideSubcategoria && coincideStock && coincideBusqueda
        }
    }

    /// Productos en o por debajo del stock mínimo.
    var productosStockBajo: [Producto] {
        productos.filter { $0.stockBajo }
    }
    /// Lista de subcategorías únicas que existen en los productos (ordenadas).
    var subcategoriasExistentes: [String] {
        let subs = productos.compactMap { producto -> String? in
            guard producto.categoria == .otro,
                  let sub = producto.subcategoria, !sub.isEmpty else { return nil }
            return sub
        }
        return Array(Set(subs)).sorted()
    }

    // MARK: - CRUD

    /// Crea un producto generando su código de barras único automáticamente.
    @discardableResult
        func agregarProducto(nombre: String, categoria: Categoria, precio: Double,
                             stock: Int, stockMinimo: Int, fotoData: Data? = nil,
                             subcategoria: String? = nil) -> Producto? {
            guard let contexto else { return nil }
            let producto = Producto(nombre: nombre, categoria: categoria, precio: precio,
                                    stock: stock, stockMinimo: stockMinimo,
                                    codigoBarras: generarCodigoUnico(), fotoData: fotoData,
                                    subcategoria: subcategoria)
            contexto.insert(producto)
            try? contexto.save()
            cargarProductos()
            return producto
        }

    func editarProducto(_ producto: Producto, nombre: String, categoria: Categoria,
                            precio: Double, stock: Int, stockMinimo: Int, fotoData: Data?,
                            subcategoria: String? = nil) {
            guard let contexto else { return }
            producto.nombre       = nombre
            producto.categoria    = categoria
            producto.precio       = precio
            producto.stock        = stock
            producto.stockMinimo  = stockMinimo
            producto.fotoData     = fotoData
            producto.subcategoria = subcategoria
            try? contexto.save()
            cargarProductos()
        }

    func eliminarProducto(_ producto: Producto) {
        guard let contexto else { return }
        contexto.delete(producto)
        try? contexto.save()
        cargarProductos()
    }

    // MARK: - Surtido en lote

    /// Agrega un producto al lote (en memoria, todavía sin guardar).
    func agregarAlLote(nombre: String, categoria: Categoria, precio: Double,
                       stock: Int, stockMinimo: Int, fotoData: Data? = nil) {
        let producto = Producto(nombre: nombre, categoria: categoria, precio: precio,
                                stock: stock, stockMinimo: stockMinimo,
                                codigoBarras: generarCodigoUnico(), fotoData: fotoData)
        productosEnLote.append(producto)
    }

    func quitarDelLote(_ producto: Producto) {
        productosEnLote.removeAll { $0.codigoBarras == producto.codigoBarras }
    }

    /// Inserta todos los productos del lote de una sola vez.
    func confirmarLote() {
        guard let contexto else { return }
        productosEnLote.forEach { contexto.insert($0) }
        try? contexto.save()
        productosEnLote.removeAll()
        cargarProductos()
    }

    // MARK: - Código de barras

    /// Genera un código numérico de 12 dígitos que no choque con los ya existentes.
    private func generarCodigoUnico() -> String {
        let usados = Set(productos.map(\.codigoBarras))
            .union(productosEnLote.map(\.codigoBarras))
        var codigo: String
        repeat {
            codigo = (0..<12).map { _ in String(Int.random(in: 0...9)) }.joined()
        } while usados.contains(codigo)
        return codigo
    }
}
