import Foundation

/// Configuration for the app, reading from environment variables or Info.plist
enum Config {
    /// Base URL for the API
    static var apiBaseURL: String {
        // Try environment variable first
        if let envURL = ProcessInfo.processInfo.environment["API_BASE_URL"], !envURL.isEmpty {
            return envURL
        }
        
        // Fall back to Info.plist
        if let url = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String, !url.isEmpty {
            return url
        }
        
        // Default fallback
        return "https://veriable.sliplane.app"
    }
    
    /// API authentication token
    static var apiToken: String {
        // Try environment variable first
        if let envToken = ProcessInfo.processInfo.environment["API_TOKEN"], !envToken.isEmpty {
            return envToken
        }
        
        // Fall back to Info.plist
        if let token = Bundle.main.object(forInfoDictionaryKey: "API_TOKEN") as? String, !token.isEmpty {
            return token
        }
        
        // Default fallback (for development only)
        return "vKY_PGlTu4aR1-dsKcuCQO2r_u2dGgts"
    }
}
