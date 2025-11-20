import Foundation
import CoreML
import Vision
import UIKit

struct Prediction {
    let boundingBox: CGRect
    let label: String
    let confidence: Float
}

class ObjectDetector {
    private var model: VNCoreMLModel?

    init() {
        loadModel()
    }

    private func loadModel() {
        do {
            // Replace "YOLOv11" with your actual model name if different
            let coreMLModel = try YOLOv11(configuration: MLModelConfiguration()).model
            model = try VNCoreMLModel(for: coreMLModel)
        } catch {
            print("Failed to load CoreML model: \(error)")
        }
    }

    func performDetection(on pixelBuffer: CVPixelBuffer, orientation: CGImagePropertyOrientation, completion: @escaping ([Prediction]) -> Void) {
        guard let model = model else {
            completion([])
            return
        }

        let request = VNCoreMLRequest(model: model) { (request, error) in
            if let error = error {
                print("CoreML request failed: \(error)")
                completion([])
                return
            }

            guard let results = request.results as? [VNRecognizedObjectObservation] else {
                completion([])
                return
            }

            let predictions = results.map { observation in
                Prediction(
                    boundingBox: observation.boundingBox,
                    label: observation.labels.first?.identifier ?? "Unknown",
                    confidence: observation.labels.first?.confidence ?? 0
                )
            }
            completion(predictions)
        }

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: orientation, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print("Failed to perform detection: \(error)")
            completion([])
        }
    }
}
