# FantasiaShop Manager

A native **iPhone and iPad** app that works as an inventory and point-of-sale system for small accessory and costume shops (caps, bags, backpacks, hair ties, keychains, plush toys and seasonal products). It is designed for businesses run by **one person**, or at most two, and works **with the device alone**: the camera acts as the barcode reader, so no extra hardware is needed.

Market: Mexico. All prices are in **MXN**. The app interface is in Spanish.

---

## What it does

### Inventory
- Create, edit and delete products with name, category, price, current stock and minimum stock.
- Optional product photo, taken with the camera or picked from the photo library.
- Categories: Gorras (caps), Bolsas (bags), Mochilas (backpacks), Ligas (hair ties) and Otro (other). Under "Otro" you can type a free-form subcategory (for example "Llaveros"), which then becomes available for reuse.
- **Code128** barcode generated automatically for every product.
- Search by name, filter by category and filter by stock status (out of stock or low stock).

### Sales mode
- Barcode scanning with the camera.
- Manual product search as a fallback, useful when there is no camera or a label is damaged.
- Running ticket: adding the same product twice increases its quantity.
- Oversell protection: you cannot add more pieces than are in stock.
- Payment by cash, card or bank transfer, with change calculation.
- On checkout the sale is recorded and **stock is deducted** automatically.
- Local notification when a product reaches or falls below its minimum stock.

### Daily summary and history
- Total sold, pieces and number of transactions for the day.
- Top-selling products and comparison against the same weekday last week.
- Cash count (cash register reconciliation) and export of the daily report to **PDF** (Letter size), ready to share.
- Browsable sales history: day → that day's sales → sale details.

### Assistant
A chat for the owner that answers with real data from the shop: best-selling product, how much was sold (today, this week or this month), best day, biggest sale, stock of a given product, sold-out or running-low products, and a comparison with last week. It can be used with quick-question chips or by typing in your own words.

It **does not use any external AI**: it interprets questions by vocabulary (ignoring accents and capitalization) and computes answers from the local database, so it works offline. If it does not understand a question, it says so and suggests examples instead of making up data.

### Roles

| | Owner | Employee |
|---|---|---|
| Sales mode | Yes | Yes |
| Inventory | Create, edit and delete | Read-only |
| Summary, history and PDF | Yes | No |
| Assistant | Yes | No |
| Generate invitation code | Yes | No |
| Sales visible | All | Only their own |

On first launch the user chooses between "I'm the owner" (creates the shop and the owner user) or "I'm an employee" (enters a 6-digit invitation code that is valid for 24 hours). On the employee's home screen, the owner-only sections are shown locked with a padlock.

---

## Tech stack

| Piece | Technology |
|---|---|
| UI | SwiftUI |
| Persistence | SwiftData (local SQLite) |
| Barcode scanning | VisionKit (`DataScannerViewController`) |
| Barcode generation | Core Image (`CICode128BarcodeGenerator`) |
| Product photo | PhotosUI (library) and `UIImagePickerController` (camera) |
| Notifications | UserNotifications (local) |
| Daily report export | PDFKit |
| Architecture | MVVM with `@Observable` |

Xcode project settings: iPhone and iPad, deployment target **iOS 26.0**, Swift 5, bundle identifier `com.josue.FantasiaShop`. Because of that deployment target, **Xcode 26 or later** is required.

---

## How to run it

1. Clone the repository and open `FantasiaShop.xcodeproj` in Xcode.
2. In the **FantasiaShop** target, go to **Signing & Capabilities**, pick your team (a free Apple ID account is enough) and, if needed, change the *Bundle Identifier* to one of your own.
3. Connect an iPhone or iPad and select it as the run destination.
4. Press **Run**.

Things worth knowing:

- **The scanner needs a physical device.** `DataScannerViewController` does not work in the Simulator. There you can use manual search to add products to the ticket.
- **Permissions.** The app asks for camera access (scanning barcodes and photographing products) and photo library access. The usage descriptions are defined in the target settings (`INFOPLIST_KEY_*`).
- **Free Apple account.** Apps installed from Xcode with a free account expire after 7 days and must be reinstalled. If the app is deleted, its local database is deleted with it.

---

## How it is built

### Architecture

- **Models**: SwiftData `@Model` classes (`Producto`, `Venta`, `LineaVenta`, `Usuario`, `Tienda`). They only describe data and relationships.
- **ViewModels**: `@Observable` classes with the logic of each area (inventory, sales, summary, authentication and assistant). They receive the `ModelContext` and the `AppState` through a `configurar(...)` method.
- **Views**: SwiftUI screens. They display what the ViewModel computes and report user actions back to it. Some views use `@Environment(\.modelContext)` directly, which is common with SwiftData.
- **AppState**: global state injected with `@Environment`. It holds the active user and shop and decides what each role sees.
- **Utilities and Extentions**: UIKit wrappers (scanner, camera), barcode generator, PDF exporter, notification manager and formatting extensions (currency, dates, colors).

### Data model

- **Producto**: name, category, optional subcategory, price, stock, minimum stock, optional photo, barcode and creation date. Deleting a product keeps the sales history (`.nullify`).
- **Venta**: date, total, payment method, cash received, seller and its lines. Deleting a sale deletes its lines (`.cascade`). Change and piece count are computed.
- **LineaVenta**: quantity, unit price and product name **at the time of sale**, so changing a price later does not alter the history.
- **Usuario**: name, role (owner or employee), shop and whether the user is active.
- **Tienda**: name, 6-digit invitation code and its expiration date.

### Key business rules

- The ticket in progress lives **in memory only**. It becomes a `Venta` and its `LineaVenta` records only at checkout, so cancelling a sale leaves nothing behind in the database.
- Stock never goes below 0 and you cannot add more to the ticket than what is in stock.
- Employees never see the shop-wide total, only their own sales.
- "Otro" subcategories have no table of their own: they are derived from the existing products.
- The session is remembered between launches (the active user and shop are stored in `UserDefaults`). If an owner already exists on the device, onboarding lets you reconnect them without creating a new shop.

### Project structure

```
FantasiaShop/
├── FantasiaShop.xcodeproj/
└── FantasiaShop/
    ├── App/
    │   ├── FantasiaShopApp.swift        # Entry point and SwiftData container
    │   ├── AppState.swift               # Active session: user, shop and role
    │   └── VistaRaiz.swift              # Chooses between onboarding and home screen
    │
    ├── Models/
    │   ├── Producto.swift
    │   ├── Venta.swift
    │   ├── LineaVenta.swift
    │   ├── Usuario.swift
    │   └── Tienda.swift
    │
    ├── ViewModels/
    │   ├── InventarioViewModel.swift    # Filters, search and product create/edit
    │   ├── VentaViewModel.swift         # Ticket, scanning, checkout and stock deduction
    │   ├── ResumenViewModel.swift       # Metrics, comparison, history and PDF
    │   ├── AuthViewModel.swift          # Onboarding, roles, invitation code and session
    │   └── AsistenteViewModel.swift     # Question interpretation and answers
    │
    ├── Views/
    │   ├── Home/
    │   │   ├── HomeView.swift
    │   │   └── GenerarCodigoSheet.swift
    │   ├── Auth/
    │   │   ├── OnboardingView.swift
    │   │   └── CodigoInvitacionView.swift
    │   ├── Venta/
    │   │   ├── VentaView.swift
    │   │   ├── TicketRow.swift
    │   │   ├── CobrarSheet.swift
    │   │   ├── BusquedaProductoSheet.swift
    │   │   └── EscanerSheet.swift
    │   ├── Inventario/
    │   │   ├── InventarioView.swift
    │   │   ├── ProductoRow.swift
    │   │   ├── ProductoDetalleView.swift
    │   │   ├── NuevoProductoView.swift
    │   │   └── BarcodeImageView.swift
    │   ├── Resume/                      # Daily summary and history
    │   │   ├── ResumenView.swift
    │   │   ├── CierreSheet.swift
    │   │   ├── HistorialVentasView.swift
    │   │   ├── DetalleDiaView.swift
    │   │   ├── DetalleVentaView.swift
    │   │   └── ShareSheet.swift
    │   └── Asistente/
    │       └── AsistenteView.swift
    │
    ├── Utilities/
    │   ├── BarcodeGenerator.swift       # Code128 with Core Image
    │   ├── ScannerViewController.swift  # DataScannerViewController wrapper
    │   ├── CamaraPicker.swift           # Camera wrapper for photos
    │   ├── NotificationManager.swift    # Local low-stock notifications
    │   └── PDFExporter.swift            # Daily report PDF
    │
    ├── Extentions/
    │   ├── Color+App.swift              # Color palette
    │   ├── Date+Helpers.swift
    │   ├── Double+Currency.swift        # MXN currency formatting
    │   └── String+Extra.swift
    │
    └── Assets.xcassets/
```

---

## Current status and roadmap

The app is feature-complete for single-device use and has been tested on a physical device.

- **Multi-device sync (CloudKit) is not active yet.** The SwiftData container is created with `cloudKitDatabase: .none`, so data lives only on the device. For that reason the employee invitation code only works within a single device; linking two separate devices requires enabling CloudKit, which in turn needs a paid Apple Developer Program account.
- **Notifying the owner when an employee makes a sale:** pending, depends on CloudKit.
- **Revoking an employee's access:** the logic already exists in `AuthViewModel` (`empleados()` and `revocarAcceso(_:)`, which deactivates the user without deleting their history), but no screen uses it yet.
- **Data backup:** there is no export or automatic backup. With CloudKit off, data exists only on the device.
- **Polish pending:** a custom app icon, and number formatting when editing a product (sometimes it shows "180.0" instead of "180").
- **Employee commissions:** a paused idea; how they are calculated is still to be defined.
- **Assistant with real AI:** the code is structured so it can be connected later without rebuilding the screen.

---

## Author

Josue Cardoso
