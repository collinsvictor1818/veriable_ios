import CoreML
import Vision
import XCTest

@testable import VeriableLib

final class YOLODetectorTests: XCTestCase {

  func testYOLODetectionInitialization() {
    let box = CGRect(x: 0.1, y: 0.1, width: 0.2, height: 0.2)
    let detection = YOLODetection(label: "Test", confidence: 0.9, boundingBox: box)

    XCTAssertEqual(detection.label, "Test")
    XCTAssertEqual(detection.confidence, 0.9)
    XCTAssertEqual(detection.boundingBox, box)
  }

  // Note: Testing the actual model loading and prediction requires the .mlmodelc to be present
  // and accessible by the test bundle, which can be tricky with SPM without resources.
  // For now, we test the data structure.
}
