import Foundation

struct ScanRecord: Identifiable, Codable, Equatable {
    let id: UUID
    let productName: String
    let confidence: Double?
    let recordedAt: Date
    let quantity: Int
    
    init(id: UUID = UUID(), productName: String, confidence: Double?, recordedAt: Date = Date(), quantity: Int = 1) {
        self.id = id
        self.productName = productName
        self.confidence = confidence
        self.recordedAt = recordedAt
        self.quantity = quantity
    }
}

#if DEBUG
extension ScanRecord {
    static var mockHistory: [ScanRecord] {
        [
            ScanRecord(productName: "Organic Avocado", confidence: 0.94, recordedAt: Date().addingTimeInterval(-600)),
            ScanRecord(productName: "Cold Brew", confidence: 0.88, recordedAt: Date().addingTimeInterval(-3600)),
            ScanRecord(productName: "Whole Milk", confidence: 0.91, recordedAt: Date().addingTimeInterval(-7200))
        ]
    }
}
#endif
