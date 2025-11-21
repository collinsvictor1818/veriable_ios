import Combine
import Foundation

/// A protocol for errors that can be presented to the user.
protocol UserFacingError: LocalizedError {
  /// A title for the error, suitable for display in an alert title.
  var title: String { get }

  /// A detailed message that explains the error and suggests a course of action.
  var message: String { get }
}

/// The primary error type for the application.
///
/// Using a single, well-defined error enum helps in handling errors consistently.
/// It can be extended with more specific cases as the app grows.
enum AppError: UserFacingError {
  case network(NetworkError)
  case data(DataError)
  case unknown(Error)

  var title: String {
    switch self {
    case .network(let error): return error.title
    case .data(let error): return error.title
    case .unknown: return "An Unknown Error Occurred"
    }
  }

  var message: String {
    switch self {
    case .network(let error): return error.message
    case .data(let error): return error.message
    case .unknown(let error):
      return "Something went wrong. Please try again later. Details: \(error.localizedDescription)"
    }
  }
}

/// Errors related to network operations.
enum NetworkError: UserFacingError {
  case invalidURL
  case requestFailed(Error)
  case invalidResponse
  case serverError(statusCode: Int)
  case noData

  var title: String {
    "Network Error"
  }

  var message: String {
    switch self {
    case .invalidURL: return "The server URL is invalid."
    case .requestFailed(let error):
      return "The network request failed. \(error.localizedDescription)"
    case .invalidResponse: return "Received an invalid response from the server."
    case .serverError(let statusCode):
      return "The server returned an error with status code \(statusCode)."
    case .noData: return "No data was received from the server."
    }
  }
}

/// Errors related to data processing, such as decoding.
enum DataError: UserFacingError {
  case decodingFailed(Error)
  case encodingFailed(Error)

  var title: String {
    "Data Error"
  }

  var message: String {
    switch self {
    case .decodingFailed(let error):
      return "Failed to decode the data. \(error.localizedDescription)"
    case .encodingFailed(let error):
      return "Failed to encode the data. \(error.localizedDescription)"
    }
  }
}
