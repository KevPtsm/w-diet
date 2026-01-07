//
//  FoodSearchView.swift
//  w-diet
//
//  Search view for Open Food Facts database
//

import GRDB
import SwiftUI

/// Main view for adding food - search, manual entry, or scan
struct FoodSearchView: View {
    // MARK: - Properties

    @Environment(\.dismiss) private var dismiss
    var onFoodAdded: () -> Void

    // MARK: - State

    @State private var searchQuery = ""
    @State private var searchResults: [OpenFoodFactsService.FoodProduct] = []
    @State private var isSearching = false
    @State private var errorMessage: String?
    @State private var selectedProduct: OpenFoodFactsService.FoodProduct?
    @State private var servingSize: Double = 100 // grams
    @State private var searchTask: Task<Void, Never>?
    @State private var showManualEntry = false
    @State private var showBarcodeScanner = false
    @State private var isLoadingBarcode = false
    @State private var barcodeError: String?

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar at top
                searchBar

                // Content
                if isSearching {
                    loadingView
                } else if let error = errorMessage {
                    errorView(error)
                } else if searchResults.isEmpty && !searchQuery.isEmpty {
                    noResultsView
                } else if searchResults.isEmpty {
                    emptyStateView
                } else {
                    resultsList
                }

                Spacer(minLength: 0)

                // Bottom action area (thumb zone)
                VStack(spacing: 0) {
                    // Manual entry button
                    Button {
                        showManualEntry = true
                    } label: {
                        HStack {
                            Image(systemName: "pencil.line")
                            Text("Manuell eingeben")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.fireGold)
                    .padding(.horizontal)
                    .padding(.bottom, 20)

                    // Scan options
                    scanOptionsBar
                }
            }
            .navigationTitle("Essen hinzufügen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
            }
            .sheet(item: $selectedProduct) { product in
                ProductDetailSheet(
                    product: product,
                    servingSize: $servingSize,
                    onConfirm: {
                        saveFoodFromSearch(product: product, servings: servingSize)
                    }
                )
            }
            .sheet(isPresented: $showManualEntry) {
                ManualEntryView(onSave: { meal in
                    saveMeal(meal)
                })
            }
            .sheet(isPresented: $showBarcodeScanner) {
                BarcodeScannerView(onBarcodeScanned: { barcode in
                    lookupBarcode(barcode)
                })
            }
            .alert("Produkt nicht gefunden", isPresented: .constant(barcodeError != nil)) {
                Button("OK") {
                    barcodeError = nil
                }
            } message: {
                if let error = barcodeError {
                    Text(error)
                }
            }
            .overlay {
                if isLoadingBarcode {
                    ZStack {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                        VStack(spacing: 12) {
                            ProgressView()
                                .scaleEffect(1.2)
                            Text("Produkt wird gesucht...")
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                        .padding(24)
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                    }
                }
            }
        }
    }

    // MARK: - Components

    private var scanOptionsBar: some View {
        HStack(spacing: 0) {
            // Plate Scan Button (Coming Soon)
            Button {
                // Coming soon - AI plate recognition
            } label: {
                VStack(spacing: 6) {
                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 28))
                        .foregroundColor(Theme.fireGold)
                    Text("Teller")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    Text("Soon")
                        .font(.system(size: 9))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1)
                        .background(Theme.gray400)
                        .cornerRadius(3)
                }
                .frame(maxWidth: .infinity)
            }
            .disabled(true)

            // Nutrition Label Scan Button (Coming Soon)
            Button {
                // Coming soon - OCR nutrition label
            } label: {
                VStack(spacing: 6) {
                    Image(systemName: "doc.viewfinder")
                        .font(.system(size: 28))
                        .foregroundColor(Theme.fireGold)
                    Text("Nährwerte")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    Text("Soon")
                        .font(.system(size: 9))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1)
                        .background(Theme.gray400)
                        .cornerRadius(3)
                }
                .frame(maxWidth: .infinity)
            }
            .disabled(true)

            // Barcode Scan Button
            Button {
                showBarcodeScanner = true
            } label: {
                VStack(spacing: 6) {
                    Image(systemName: "barcode.viewfinder")
                        .font(.system(size: 28))
                        .foregroundColor(Theme.fireGold)
                    Text("Barcode")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Theme.backgroundSecondary)
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("Lebensmittel suchen...", text: $searchQuery)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
                .onChange(of: searchQuery) { _, newValue in
                    // Cancel previous search task
                    searchTask?.cancel()

                    // Debounce: wait 400ms before searching
                    searchTask = Task {
                        try? await Task.sleep(nanoseconds: 400_000_000)
                        guard !Task.isCancelled else { return }
                        await performSearch()
                    }
                }
                .onSubmit {
                    // Immediate search on Enter
                    searchTask?.cancel()
                    Task { await performSearch() }
                }

            if !searchQuery.isEmpty {
                Button {
                    searchQuery = ""
                    searchResults = []
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(Theme.backgroundSecondary)
        .cornerRadius(10)
        .padding(.horizontal)
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
            Text("Suche...")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(Theme.error)

            Text(message)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("Erneut versuchen") {
                Task { await performSearch() }
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var noResultsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.largeTitle)
                .foregroundStyle(.secondary)

            Text("Keine Ergebnisse")
                .font(.headline)

            Text("Versuche einen anderen Suchbegriff.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "text.magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("Lebensmittel suchen")
                .font(.headline)

            Text("Gib den Namen eines Lebensmittels ein um in der Datenbank zu suchen.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var resultsList: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(searchResults) { product in
                    productRow(product)
                }
            }
            .padding()
        }
    }

    private func productRow(_ product: OpenFoodFactsService.FoodProduct) -> some View {
        Button {
            selectedProduct = product
            servingSize = 100 // Reset to default
        } label: {
            HStack(spacing: 12) {
                // Product image or placeholder
                AsyncImage(url: product.imageURL.flatMap { URL(string: $0) }) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Image(systemName: "fork.knife")
                        .foregroundStyle(.secondary)
                }
                .frame(width: 50, height: 50)
                .background(Theme.gray100)
                .cornerRadius(8)

                // Product info
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    if let brand = product.brand {
                        Text(brand)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }

                    if let calories = product.caloriesKcal {
                        Text("\(calories) kcal / 100g")
                            .font(.caption)
                            .foregroundColor(Theme.fireGold)
                    }
                }

                Spacer()

                // Chevron
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Theme.backgroundSecondary)
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Actions

    private func performSearch() async {
        guard !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        isSearching = true
        errorMessage = nil

        do {
            let result = try await OpenFoodFactsService.shared.search(query: searchQuery)
            searchResults = result.products
        } catch {
            errorMessage = "Suche fehlgeschlagen. Bitte überprüfe deine Internetverbindung."
        }

        isSearching = false
    }

    private func lookupBarcode(_ barcode: String) {
        Task {
            isLoadingBarcode = true
            barcodeError = nil

            do {
                if let product = try await OpenFoodFactsService.shared.getProduct(barcode: barcode) {
                    // Product found - show detail sheet
                    servingSize = 100
                    selectedProduct = product
                } else {
                    // Product not in database
                    barcodeError = "Dieses Produkt wurde nicht in der Datenbank gefunden. Versuche es mit der Suche oder gib die Daten manuell ein."
                }
            } catch {
                barcodeError = "Fehler beim Abrufen der Produktdaten. Bitte überprüfe deine Internetverbindung."
            }

            isLoadingBarcode = false
        }
    }

    private func saveFoodFromSearch(product: OpenFoodFactsService.FoodProduct, servings: Double) {
        let meal = MealLog(
            userId: "mock-user-id",
            mealName: product.brand != nil ? "\(product.name) (\(product.brand!))" : product.name,
            caloriesKcal: Int(Double(product.caloriesKcal ?? 0) * servings / 100),
            proteinG: (product.proteinG ?? 0) * servings / 100,
            carbsG: (product.carbsG ?? 0) * servings / 100,
            fatG: (product.fatG ?? 0) * servings / 100
        )
        saveMeal(meal)
    }

    private func saveMeal(_ meal: MealLog) {
        Task {
            let mutableMeal = meal
            do {
                try await GRDBManager.shared.write { db in
                    var m = mutableMeal
                    try m.insert(db)
                }
                onFoodAdded()
                dismiss()
            } catch {
                AppError.databaseWriteFailed(operation: "insert_meal", underlying: error).report()
            }
        }
    }
}

// MARK: - Product Detail Sheet

struct ProductDetailSheet: View {
    let product: OpenFoodFactsService.FoodProduct
    @Binding var servingSize: Double
    var onConfirm: () -> Void

    @Environment(\.dismiss) private var dismiss

    private var calculatedCalories: Int {
        Int(Double(product.caloriesKcal ?? 0) * servingSize / 100)
    }

    private var calculatedProtein: Double {
        (product.proteinG ?? 0) * servingSize / 100
    }

    private var calculatedCarbs: Double {
        (product.carbsG ?? 0) * servingSize / 100
    }

    private var calculatedFat: Double {
        (product.fatG ?? 0) * servingSize / 100
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Product header
                    VStack(spacing: 8) {
                        AsyncImage(url: product.imageURL.flatMap { URL(string: $0) }) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            Image(systemName: "fork.knife")
                                .font(.system(size: 40))
                                .foregroundStyle(.secondary)
                        }
                        .frame(height: 120)

                        Text(product.name)
                            .font(.headline)
                            .multilineTextAlignment(.center)

                        if let brand = product.brand {
                            Text(brand)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Divider()

                    // Serving size input
                    VStack(spacing: 8) {
                        Text("Menge (Gramm)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        HStack {
                            TextField("Gramm", value: $servingSize, format: .number.grouping(.never).precision(.fractionLength(0)))
                                .keyboardType(.numberPad)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 100)
                                .multilineTextAlignment(.center)
                                .onChange(of: servingSize) { _, newValue in
                                    // Ensure integer between 0 and 9999
                                    let clamped = min(max(0, newValue), 9999)
                                    let rounded = clamped.rounded()
                                    if servingSize != rounded {
                                        servingSize = rounded
                                    }
                                }

                            Text("g")
                                .foregroundStyle(.secondary)
                        }

                        // Quick size buttons
                        HStack(spacing: 12) {
                            ForEach([50, 100, 150, 200], id: \.self) { size in
                                Button("\(size)g") {
                                    servingSize = Double(size)
                                }
                                .buttonStyle(.bordered)
                                .tint(servingSize == Double(size) ? Theme.fireGold : .gray)
                            }
                        }
                    }

                    Divider()

                    // Calculated nutrition
                    VStack(spacing: 16) {
                        Text("Nährwerte für \(Int(servingSize))g")
                            .font(.headline)

                        nutritionRow(label: "Kalorien", value: "\(calculatedCalories) kcal", color: Theme.fireGold)
                        nutritionRow(label: "Eiweiß", value: String(format: "%.1fg", calculatedProtein), color: Theme.macroProtein)
                        nutritionRow(label: "Kohlenhydrate", value: String(format: "%.1fg", calculatedCarbs), color: Theme.warning)
                        nutritionRow(label: "Fett", value: String(format: "%.1fg", calculatedFat), color: Theme.macroFat)
                    }

                    // Add button
                    Button {
                        onConfirm()
                    } label: {
                        Text("Hinzufügen")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 4)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.fireGold)
                }
                .padding()
            }
            .navigationTitle("Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func nutritionRow(label: String, value: String, color: Color) -> some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
    }
}

// MARK: - Preview

#Preview {
    FoodSearchView(onFoodAdded: {})
}
