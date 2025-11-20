import Foundation

enum ScanRecordAPI: Endpoint {
    case uploadScanRecord(userId: Int, productName: String, confidence: Double?, quantity: Int)
    
    var baseURL: String {
        return Config.apiBaseURL
    }
    
    var path: String {
        return "/items/scan_records"
    }
    
    var method: String {
        return "POST"
    }
    
    var url: URL? {
        return URL(string: baseURL + path)
    }
    
    var body: Data? {
        switch self {
        case .uploadScanRecord(let userId, let productName, let confidence, let quantity):
            let data: [String: Any] = [
                "user": userId,
                "product_name": productName,
                "confidence": confidence as Any,
                "quantity": quantity,
                "recorded_at": ISO8601DateFormatter().string(from: Date())
            ]
            return try? JSONSerialization.data(withJSONObject: data)
        }
    }
}

// Response model
struct ScanRecordResponse: Codable {
    let id: Int
    let user: Int
    let productName: String
    let confidence: Double?
    let recordedAt: String
    let quantity: Int
}
