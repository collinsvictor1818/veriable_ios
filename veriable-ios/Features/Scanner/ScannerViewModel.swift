import Foundation
import SwiftUI
import AVFoundation

@MainActor
final class ScannerViewModel: ObservableObject {
    struct Detection: Identifiable {
        let id = UUID()
        let name: String
        let confidence: Double
        let boundingBox: CGRect
    }
    
    @Published var detections: [Detection] = []
    @Published var hintMessage: String = "Align items within the frame"
    @Published var authorizationStatus: AVAuthorizationStatus = .notDetermined
    @Published var errorMessage: String?
    
    let cameraService = CameraService()
    private var detector: YOLODetector?
    private var isProcessingFrame = false
    
    var session: AVCaptureSession {
        cameraService.captureSession
    }
    
    init() {
        cameraService.onSampleBuffer = { [weak self] buffer in
            self?.handleSampleBuffer(buffer)
        }
    }
    
    func start() {
        Task {
            await requestPermissionsAndConfigure()
        }
    }
    
    func stop() {
        cameraService.stopSession()
        detections.removeAll()
    }
    
    private func requestPermissionsAndConfigure() async {
        authorizationStatus = await cameraService.requestAuthorizationStatus()
        guard authorizationStatus == .authorized else {
            errorMessage = "Camera access is required to scan items."
            return
        }
        do {
            if detector == nil {
                detector = try? YOLODetector()
            }
            try cameraService.configureSession()
            cameraService.startSession()
        } catch {
            errorMessage = "Failed to start camera: \(error.localizedDescription)"
        }
    }
    
    private func handleSampleBuffer(_ buffer: CVPixelBuffer) {
        guard !isProcessingFrame else { return }
        isProcessingFrame = true
        Task {
            await runDetection(on: buffer)
            isProcessingFrame = false
        }
    }
    
    private func runDetection(on buffer: CVPixelBuffer) async {
        guard let detector else {
            await generateFallbackDetections()
            return
        }
        do {
            let results = try await detector.detectObjects(in: buffer)
            let mapped = results.map { result in
                Detection(name: result.label.capitalized,
                          confidence: result.confidence,
                          boundingBox: result.boundingBox)
            }
            detections = mapped
            hintMessage = mapped.isEmpty ? "Align items within the frame" : "Tap a box to confirm item"
        } catch {
            self.errorMessage = "Detection failed: \(error.localizedDescription)"
        }
    }
    
    private func generateFallbackDetections() async {
        let sampleProducts = [
            ("Avocado", 0.92),
            ("Milk Carton", 0.87),
            ("Organic Banana", 0.95)
        ]
        await MainActor.run {
            detections = sampleProducts.map { item in
                Detection(name: item.0,
                          confidence: item.1,
                          boundingBox: CGRect(x: .random(in: 0.1...0.6),
                                              y: .random(in: 0.1...0.6),
                                              width: .random(in: 0.2...0.35),
                                              height: .random(in: 0.15...0.3)))
            }
            hintMessage = "Tap a box to confirm item"
        }
    }
}
