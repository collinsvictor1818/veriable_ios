import CoreML
import Vision
import os.log

struct YOLODetection: Identifiable {
    let id = UUID()
    let label: String
    let confidence: Double
    let boundingBox: CGRect
}

enum YOLODetectorError: Error {
    case modelNotFound
    case predictionFailed(Error)
}

actor YOLODetector {
    private let model: VNCoreMLModel
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "Veriable",
                                category: "YOLODetector")

    init(modelName: String = "veriable_trained_model") throws {
        // Load compiled Core ML model from the app bundle (.mlmodelc)
        guard let url = Bundle.main.url(forResource: modelName, withExtension: "mlmodelc") else {
            throw YOLODetectorError.modelNotFound
        }
        let core = try MLModel(contentsOf: url)
        let visionModel = try YOLODetector.makeVisionModel(from: core)
        self.model = visionModel
    }

    /// Convenience initializer to load a model directly from a file URL (e.g., a .mlmodelc folder on disk).
    /// Note: On device, prefer bundling the model with the app. This is primarily useful for simulator/dev.
    init(fileURL: URL) throws {
        let core = try MLModel(contentsOf: fileURL)
        let visionModel = try YOLODetector.makeVisionModel(from: core)
        self.model = visionModel
    }

    /// Creates a VNCoreMLModel and configures its input image feature name if needed.
    private static func makeVisionModel(from core: MLModel) throws -> VNCoreMLModel {
        let visionModel = try VNCoreMLModel(for: core)
        // Attempt to set the expected input image feature name based on the model description.
        let inputNames = core.modelDescription.inputDescriptionsByName.keys
        if inputNames.contains("images") {
            visionModel.inputImageFeatureName = "images"
        } else if inputNames.contains("image") {
            visionModel.inputImageFeatureName = "image"
        }
        return visionModel
    }

    func detectObjects(in buffer: CVPixelBuffer) async throws -> [YOLODetection] {
        try await withCheckedThrowingContinuation { cont in

            let request = VNCoreMLRequest(model: model) { req, error in
                if let error { return cont.resume(throwing: error) }

                let results = (req.results as? [VNRecognizedObjectObservation]) ?? []
                let mapped = results.map { obs -> YOLODetection in
                    let label = obs.labels.first?.identifier ?? "Unknown"
                    let conf = obs.labels.first?.confidence ?? 0
                    return YOLODetection(label: label,
                                         confidence: Double(conf),
                                         boundingBox: obs.boundingBox)
                }
                cont.resume(returning: mapped)
            }

            let handler = VNImageRequestHandler(cvPixelBuffer: buffer)
            do { try handler.perform([request]) }
            catch {
                logger.error("Vision failed: \(error.localizedDescription)")
                cont.resume(throwing: YOLODetectorError.predictionFailed(error))
            }
        }
    }
}
