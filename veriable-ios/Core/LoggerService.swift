import Foundation
import os.log

/// A simple logging service that uses `os.Logger`.
///
/// This service provides a structured way to log messages throughout the app.
/// It supports different log levels and categorizes logs by subsystem and category.
struct LoggerService {
    
    private let logger: Logger
    
    // MARK: - Initialization
    
    /// Creates a `LoggerService` instance.
    /// - Parameters:
    ///   - subsystem: The bundle identifier of the app.
    ///   - category: A string that identifies the area of the app the logs are coming from.
    init(subsystem: String = Bundle.main.bundleIdentifier!, category: String) {
        self.logger = Logger(subsystem: subsystem, category: category)
    }
    
    // MARK: - Public Methods
    
    func debug(_ message: String) {
        logger.debug("\(message, privacy: .public)")
    }
    
    func info(_ message: String) {
        logger.info("\(message, privacy: .public)")
    }
    
    func notice(_ message: String) {
        logger.notice("\(message, privacy: .public)")
    }
    
    func warning(_ message: String) {
        logger.warning("\(message, privacy: .public)")
    }
    
    func error(_ message: String) {
        logger.error("\(message, privacy: .public)")
    }
    
    func fault(_ message: String) {
        logger.fault("\(message, privacy: .public)")
    }
}
