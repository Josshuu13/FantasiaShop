import SwiftUI
import SwiftData

@main
struct FantasiaShopApp: App {
    /// Estado global de la app (usuario y tienda activos).
    @State private var appState = AppState()

    /// Contenedor de SwiftData. CloudKit queda apagado por ahora.
    let container: ModelContainer

    init() {
        let schema = Schema([
            Producto.self,
            Venta.self,
            LineaVenta.self,
            Usuario.self,
            Tienda.self
        ])

        let configuracion = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .none   // ← SwiftData 100% local, sin cuenta de paga
        )

        do {
            container = try ModelContainer(for: schema, configurations: [configuracion])
        } catch {
            fatalError("No se pudo crear el ModelContainer: \(error)")
        }
    }

    var body: some Scene {
            WindowGroup {
                VistaRaiz()
                    .environment(appState)
            }
            .modelContainer(container)
        }
}
