import Foundation

struct ScanRecord: Identifiable, Codable, Equatable {
    let id: Int
    let productName: String
    let confidence: Double?
    let recordedAt: Date
    let quantity: Int
    
    init(id: Int = 0, productName: String, confidence: Double?, recordedAt: Date = Date(), quantity: Int = 1) {
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
            ScanRecord(id: 1, productName: "Organic Avocado", confidence: 0.94, recordedAt: Date().addingTimeInterval(-600)),
            ScanRecord(id: 2, productName: "Cold Brew", confidence: 0.88, recordedAt: Date().addingTimeInterval(-3600)),
            ScanRecord(id: 3, productName: "Whole Milk", confidence: 0.91, recordedAt: Date().addingTimeInterval(-7200))
        ]
    }
}
#endif
