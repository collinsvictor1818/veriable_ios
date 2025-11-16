import CoreML
import Vision
import os.log
import UIKit // Need this for CGRect

// This struct is defined by your detector
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

    /// - Parameter modelName: The compiled `.mlmodelc` resource bundled with the app (default `yolo11n`).
    init(modelName: String = "yolo11n") throws {
        // Prefer compiled model (.mlmodelc)
        let compiledURL = Bundle.main.url(forResource: modelName, withExtension: "mlmodelc")
        // Fallback to raw model (.mlmodel) if needed
        let rawURL = Bundle.main.url(forResource: modelName, withExtension: "mlmodel")

        guard let modelURL = compiledURL ?? rawURL else {
            logger.error("Model file not found: \(modelName).mlmodelc or .mlmodel")
            throw YOLODetectorError.modelNotFound
        }

        let config = MLModelConfiguration()
        config.computeUnits = .all
        let coreMLModel = try MLModel(contentsOf: modelURL, configuration: config)
        let vnModel = try VNCoreMLModel(for: coreMLModel)

        // If available, set the expected input image feature name used by YOLOv11 exported models (usually "images").
        // This is a no-op on older SDKs where the property may not exist.
        #if compiler(>=6.0)
        vnModel.inputImageFeatureName = "images"
        #endif

        self.model = vnModel
    }

    func detectObjects(in pixelBuffer: CVPixelBuffer, orientation: CGImagePropertyOrientation = .up) async throws -> [YOLODetection] {
        try await withCheckedThrowingContinuation { continuation in
            let request = VNCoreMLRequest(model: model) { request, error in
                if let error {
                    continuation.resume(throwing: YOLODetectorError.predictionFailed(error))
                    return
                }

                guard let results = request.results as? [VNRecognizedObjectObservation] else {
                    // If your model does not include NMS and returns feature values, add post-processing here.
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

            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: orientation, options: [:])
            do {
                try handler.perform([request])
            } catch {
                logger.error("Vision request failed: \(error.localizedDescription)")
                continuation.resume(throwing: YOLODetectorError.predictionFailed(error))
            }
        }
    }

    // Convenience method maintaining the previous signature
    func detectObjects(in pixelBuffer: CVPixelBuffer) async throws -> [YOLODetection] {
        try await detectObjects(in: pixelBuffer, orientation: .up)
    }
}
