//
//  ShareSheet.swift
//  FantasiaShop
//
//  Created by Josue Cardoso on 31/08/26.
//
import SwiftUI
import UIKit

/// Envuelve UIActivityViewController para compartir/guardar/imprimir el PDF.
struct ShareSheet: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [url], applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

extension URL: @retroactive Identifiable {
    public var id: String { absoluteString }
}
