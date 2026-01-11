//
//  PlateScannerView.swift
//  w-diet
//
//  Camera-based plate scanning with Gemini AI analysis
//

import SwiftUI
import PhotosUI

// MARK: - Confidence Helpers

private enum ConfidenceHelper {
    static func icon(_ confidence: String) -> String {
        switch confidence.lowercased() {
        case "high": return "checkmark.circle.fill"
        case "medium": return "exclamationmark.circle.fill"
        default: return "questionmark.circle.fill"
        }
    }

    static func color(_ confidence: String) -> Color {
        switch confidence.lowercased() {
        case "high": return Theme.success
        case "medium": return Theme.warning
        default: return Theme.disabled
        }
    }
}

/// View for scanning a plate/meal with AI analysis
struct PlateScannerView: View {
    // MARK: - Properties

    @Environment(\.dismiss) private var dismiss
    var onFoodAnalyzed: (FoodAnalysisResponse.FoodItem) -> Void

    // MARK: - State

    @State private var selectedImage: UIImage?
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var isAnalyzing = false
    @State private var analysisResult: FoodAnalysisResponse?
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var showCamera = false

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if isAnalyzing {
                    // Loading state
                    loadingView
                } else if let result = analysisResult {
                    // Results list
                    resultsList(result)
                } else {
                    // Image selection
                    imageSelectionView
                }
            }
            .padding()
            .navigationTitle("Teller scannen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "arrow.left.circle.fill")
                            .font(.title2)
                            .foregroundColor(Theme.fireGold)
                    }
                }
            }
            .alert("Fehler", isPresented: $showError) {
                Button("OK") {}
            } message: {
                Text(errorMessage ?? "Unbekannter Fehler")
            }
            .sheet(isPresented: $showCamera, onDismiss: {
                // If camera dismissed without taking photo, close entire view
                if selectedImage == nil {
                    dismiss()
                }
            }) {
                CameraView(image: $selectedImage)
            }
            .onChange(of: selectedImage) { _, newImage in
                if newImage != nil {
                    analyzeImage()
                }
            }
            .onChange(of: selectedPhotoItem) { _, newItem in
                loadImage(from: newItem)
            }
            .onAppear {
                // Automatically open camera when view appears
                showCamera = true
            }
        }
    }

    // MARK: - Views

    private var imageSelectionView: some View {
        VStack(spacing: 24) {
            Spacer()

            // Icon
            Image(systemName: "camera.viewfinder")
                .font(.system(size: 80))
                .foregroundColor(Theme.fireGold)

            Text("Fotografiere dein Essen")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Die KI analysiert das Bild und schätzt die Nährwerte")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()

            // Camera button
            Button {
                showCamera = true
            } label: {
                HStack {
                    Image(systemName: "camera.fill")
                    Text("Foto aufnehmen")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Theme.fireGold)
                .foregroundColor(.white)
                .cornerRadius(12)
            }

            // Photo library picker
            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                HStack {
                    Image(systemName: "photo.on.rectangle")
                    Text("Aus Fotos wählen")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Theme.backgroundSecondary)
                .foregroundColor(.primary)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Theme.lightModeBorder, lineWidth: 1)
                )
            }
        }
    }

    private var loadingView: some View {
        VStack(spacing: 24) {
            Spacer()

            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 200)
                    .cornerRadius(12)
            }

            ProgressView()
                .scaleEffect(1.5)

            Text("Analysiere Mahlzeit...")
                .font(.headline)
                .foregroundStyle(.secondary)

            Spacer()
        }
    }

    private func resultsList(_ result: FoodAnalysisResponse) -> some View {
        VStack(spacing: 16) {
            // Image preview
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 150)
                    .cornerRadius(12)
            }

            // Confidence indicator
            HStack {
                Image(systemName: ConfidenceHelper.icon(result.confidence))
                    .foregroundColor(ConfidenceHelper.color(result.confidence))
                Text("Genauigkeit: \(result.confidence)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Divider()

            // Food items list
            Text("Erkannte Lebensmittel")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(result.items) { item in
                        foodItemRow(item)
                    }
                }
            }

            // Retake button
            Button {
                selectedImage = nil
                analysisResult = nil
            } label: {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Neues Foto")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Theme.backgroundSecondary)
                .foregroundColor(.primary)
                .cornerRadius(12)
            }
        }
    }

    private func foodItemRow(_ item: FoodAnalysisResponse.FoodItem) -> some View {
        Button {
            onFoodAnalyzed(item)
            dismiss()
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(item.portion)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(item.calories) kcal")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Theme.fireGold)
                    Text("E:\(Int(item.proteinG))g K:\(Int(item.carbsG))g F:\(Int(item.fatG))g")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(Theme.fireGold)
            }
            .padding()
            .background(Theme.backgroundSecondary)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Theme.lightModeBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private func loadImage(from item: PhotosPickerItem?) {
        guard let item else { return }

        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                await MainActor.run {
                    selectedImage = image
                }
            }
        }
    }

    private func analyzeImage() {
        guard let image = selectedImage else { return }

        isAnalyzing = true
        errorMessage = nil

        Task {
            do {
                let result = try await GeminiService.shared.analyzeFood(image: image)
                await MainActor.run {
                    analysisResult = result
                    isAnalyzing = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                    isAnalyzing = false
                }
            }
        }
    }
}

// MARK: - Camera View

struct CameraView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        // Ensure camera controls are visible and not cut off
        picker.modalPresentationStyle = .fullScreen
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView

        init(_ parent: CameraView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - Preview

#Preview {
    PlateScannerView { item in
        print("Selected: \(item.name)")
    }
}

// MARK: - Plate Analysis Results View (for direct camera flow)

/// Standalone results view for displaying analysis results
struct PlateAnalysisResultsView: View {
    @Environment(\.dismiss) private var dismiss
    let image: UIImage?
    let result: FoodAnalysisResponse?
    let isAnalyzing: Bool
    var onFoodSelected: (FoodAnalysisResponse.FoodItem) -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                if isAnalyzing {
                    // Loading state
                    Spacer()
                    if let img = image {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .cornerRadius(12)
                    }
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Analysiere Mahlzeit...")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Spacer()
                } else if let result = result {
                    // Results
                    if let img = image {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 150)
                            .cornerRadius(12)
                    }

                    HStack {
                        Image(systemName: ConfidenceHelper.icon(result.confidence))
                            .foregroundColor(ConfidenceHelper.color(result.confidence))
                        Text("Genauigkeit: \(result.confidence)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Divider()

                    Text("Erkannte Lebensmittel")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(result.items) { item in
                                foodItemRow(item)
                            }
                        }
                    }
                } else {
                    Spacer()
                    Text("Keine Ergebnisse")
                        .foregroundStyle(.secondary)
                    Spacer()
                }
            }
            .padding()
            .navigationTitle("Erkannte Mahlzeit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "arrow.left.circle.fill")
                            .font(.title2)
                            .foregroundColor(Theme.fireGold)
                    }
                }
            }
        }
    }

    private func foodItemRow(_ item: FoodAnalysisResponse.FoodItem) -> some View {
        Button {
            onFoodSelected(item)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(item.portion)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(item.calories) kcal")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Theme.fireGold)
                    Text("E:\(Int(item.proteinG))g K:\(Int(item.carbsG))g F:\(Int(item.fatG))g")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(Theme.fireGold)
            }
            .padding()
            .background(Theme.backgroundSecondary)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Theme.lightModeBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
