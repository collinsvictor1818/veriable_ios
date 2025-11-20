import CoreML
import Vision
import os.log

struct YOLODetection: Identifiable {
    let id = UUID()
    let label: String
    let confidence: Double
    /// Normalized bounding box (0-1) with origin at top-left.
    let boundingBox: CGRect
}

enum YOLODetectorError: Error {
    case modelNotFound
    case predictionFailed(Error)
}

/// Wrapper responsible for running YOLO11 Core ML models via Vision.
actor YOLODetector {
    private let model: VNCoreMLModel
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "Veriable", category: "YOLODetector")
    
    /// - Parameter modelName: The compiled `.mlmodelc` resource bundled with the app (default `YOLO11n`).
    init(modelName: String = "YOLO11n") throws {
        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "mlmodelc") else {
            throw YOLODetectorError.modelNotFound
        }
        let coreMLModel = try MLModel(contentsOf: modelURL)
        self.model = try VNCoreMLModel(for: coreMLModel)
        self.model.inputImageFeatureName = "images"
    }
    
    func detectObjects(in pixelBuffer: CVPixelBuffer) async throws -> [YOLODetection] {
        try await withCheckedThrowingContinuation { continuation in
            let request = VNCoreMLRequest(model: model) { request, error in
                if let error {
                    continuation.resume(throwing: YOLODetectorError.predictionFailed(error))
                    return
                }
                guard let results = request.results as? [VNRecognizedObjectObservation] else {
                    continuation.resume(returning: [])
                    return
                }
                let detections = results.map { observation -> YOLODetection in
                    let topLabel = observation.labels.first
                    return YOLODetection(label: topLabel?.identifier ?? "Unknown",
                                         confidence: Double(topLabel?.confidence ?? 0),
                                         boundingBox: observation.boundingBox)
                }
                continuation.resume(returning: detections)
            }
            request.imageCropAndScaleOption = .scaleFill
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
            do {
                try handler.perform([request])
            } catch {
                logger.error("Vision request failed: \(error.localizedDescription)")
                continuation.resume(throwing: YOLODetectorError.predictionFailed(error))
            }
        }
    }
}
