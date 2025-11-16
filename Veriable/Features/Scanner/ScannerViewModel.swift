import Foundation
import SwiftUI
import AVFoundation
import Combine

@MainActor
final class ScannerViewModel: ObservableObject {
    struct Detection: Identifiable {
        let id = UUID()
        let name: String
        let confidence: Double
        let boundingBox: CGRect // Normalized bounding box
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
    
    // 💡 --- THIS FUNCTION WAS MISSING --- 💡
    private func handleSampleBuffer(_ buffer: CVPixelBuffer) {
        guard !isProcessingFrame else { return }
        isProcessingFrame = true
        
        Task {
            await runDetection(on: buffer)
            isProcessingFrame = false
        }
    }
    
    private func requestPermissionsAndConfigure() async {
        authorizationStatus = await cameraService.requestAuthorizationStatus()
        guard authorizationStatus == .authorized else {
            errorMessage = "Camera access is required to scan items."
            return
        }
        do {
            if detector == nil {
                // This initializes your YOLODetector
                detector = try YOLODetector()
            }
            try cameraService.configureSession()
            cameraService.startSession()
        } catch {
            errorMessage = "Failed to start camera or load model: \(error.localizedDescription)"
        }
    }
    
    private func runDetection(on buffer: CVPixelBuffer) async {
        guard let detector else {
            // await generateFallbackDetections() // Uncomment if you want fallback
            return
        }
        do {
            let results = try await detector.detectObjects(in: buffer)
            
            let mapped = results.map { result in
                Detection(name: result.label.capitalized,
                          confidence: result.confidence,
                          boundingBox: result.boundingBox)
            }
            
            self.detections = mapped
            self.hintMessage = mapped.isEmpty ? "Align items within the frame" : "Tap a box to confirm item"
        } catch {
            // Only show detection errors briefly
            self.errorMessage = "Detection failed: \(error.localizedDescription)"
            Task {
                try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                if self.errorMessage == "Detection failed: \(error.localizedDescription)" {
                    self.errorMessage = nil
                }
            }
        }
    }
    
    // Fallback logic from your original file (optional)
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
