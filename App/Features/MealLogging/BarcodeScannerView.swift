//
//  BarcodeScannerView.swift
//  w-diet
//
//  Barcode scanner using AVFoundation
//

import AVFoundation
import SwiftUI

/// Barcode scanner view using device camera
struct BarcodeScannerView: View {
    @Environment(\.dismiss) private var dismiss
    var onBarcodeScanned: (String) -> Void

    @State private var isShowingPermissionDenied = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Camera preview
                BarcodeScannerRepresentable(onBarcodeScanned: { barcode in
                    onBarcodeScanned(barcode)
                    dismiss()
                })
                .ignoresSafeArea()

                // Overlay with scanning guide
                VStack {
                    Spacer()

                    // Scanning frame
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Theme.fireGold, lineWidth: 3)
                        .frame(width: 280, height: 150)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.black.opacity(0.1))
                        )

                    Text("Barcode im Rahmen positionieren")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.top, 16)
                        .shadow(radius: 2)

                    Spacer()
                }
            }
            .navigationTitle("Barcode scannen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.black.opacity(0.8), for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .alert("Kamera-Zugriff verweigert", isPresented: $isShowingPermissionDenied) {
                Button("Einstellungen öffnen") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Abbrechen", role: .cancel) {
                    dismiss()
                }
            } message: {
                Text("Bitte erlaube den Kamera-Zugriff in den Einstellungen, um Barcodes zu scannen.")
            }
            .onAppear {
                checkCameraPermission()
            }
        }
    }

    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .denied, .restricted:
            isShowingPermissionDenied = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if !granted {
                    DispatchQueue.main.async {
                        isShowingPermissionDenied = true
                    }
                }
            }
        default:
            break
        }
    }
}

// MARK: - UIKit Camera Representable

struct BarcodeScannerRepresentable: UIViewControllerRepresentable {
    var onBarcodeScanned: (String) -> Void

    func makeUIViewController(context: Context) -> BarcodeScannerViewController {
        let viewController = BarcodeScannerViewController()
        viewController.onBarcodeScanned = onBarcodeScanned
        return viewController
    }

    func updateUIViewController(_ uiViewController: BarcodeScannerViewController, context: Context) {}
}

// MARK: - AVFoundation Camera Controller

class BarcodeScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var onBarcodeScanned: ((String) -> Void)?

    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var hasScanned = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupCamera()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startScanning()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopScanning()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    private func setupCamera() {
        let captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            return
        }

        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [
                .ean8,
                .ean13,
                .upce,
                .code128,
                .code39,
                .code93,
                .itf14,
                .dataMatrix,
                .qr
            ]
        } else {
            return
        }

        self.captureSession = captureSession

        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        self.previewLayer = previewLayer
    }

    private func startScanning() {
        hasScanned = false
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession?.startRunning()
        }
    }

    private func stopScanning() {
        captureSession?.stopRunning()
    }

    // MARK: - AVCaptureMetadataOutputObjectsDelegate

    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard !hasScanned else { return }

        if let metadataObject = metadataObjects.first,
           let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
           let stringValue = readableObject.stringValue {
            hasScanned = true

            // Haptic feedback
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))

            stopScanning()
            onBarcodeScanned?(stringValue)
        }
    }
}

// MARK: - Preview

#Preview {
    BarcodeScannerView(onBarcodeScanned: { barcode in
        print("Scanned: \(barcode)")
    })
}
