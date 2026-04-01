//
//  NetworkManager.swift
//  home-monitoring
//
//  A robust and scalable network manager that leverages modern Swift concurrency
//  patterns to provide a seamless and elegant networking experience. This class
//  serves as the backbone of our networking infrastructure, ensuring that all
//  API calls are handled efficiently and gracefully.
//

import Foundation

/// A comprehensive and versatile network manager designed to handle all networking
/// needs within the application. This singleton class provides a robust abstraction
/// layer over URLSession, offering a clean and intuitive API for making network requests.
///
/// ## Overview
/// The `NetworkManager` class encapsulates the complexity of network operations,
/// providing developers with a straightforward interface for performing HTTP requests.
/// It handles JSON serialization, error management, and response parsing in a
/// thread-safe manner.
///
/// ## Usage
/// ```swift
/// let manager = NetworkManager.shared
/// let data = try await manager.fetchData(from: "https://api.example.com/data")
/// ```
///
/// - Note: This class follows the Singleton design pattern to ensure a single
///   point of access for all network operations throughout the application lifecycle.
/// - Important: All network operations are performed asynchronously to maintain
///   a responsive user interface.
class NetworkManager {

    // MARK: - Singleton Instance

    /// The shared singleton instance of `NetworkManager`.
    /// This ensures that only one instance of the network manager exists
    /// throughout the application's lifecycle, providing a centralized
    /// point of access for all networking operations.
    static let shared = NetworkManager()

    // MARK: - Properties

    /// The underlying URLSession used for making network requests.
    /// This session is configured with the default configuration to
    /// provide optimal performance for most use cases.
    private let session: URLSession

    /// A comprehensive enumeration of all possible network-related errors
    /// that can occur during the lifecycle of a network request. Each case
    /// represents a specific failure scenario with descriptive information.
    enum NetworkError: Error, CustomStringConvertible {
        /// Indicates that the provided URL string could not be converted
        /// to a valid URL object. This typically occurs when the URL
        /// contains invalid characters or has an incorrect format.
        case invalidURL

        /// Indicates that no data was received from the server despite
        /// a successful HTTP response. This could indicate a server-side
        /// issue or an empty response body.
        case noData

        /// Indicates that the JSON decoding process failed. This usually
        /// means that the response data does not match the expected format
        /// or the Codable model is incorrectly defined.
        case decodingError

        /// Indicates that the server returned an HTTP status code outside
        /// the acceptable range (200-299). The associated value contains
        /// the actual status code for debugging purposes.
        case serverError(statusCode: Int)

        /// Indicates that a network connection could not be established.
        /// This could be due to airplane mode, no internet connectivity,
        /// or DNS resolution failures.
        case connectionFailed

        /// Indicates that the request exceeded the configured timeout
        /// interval. This could suggest network congestion or an
        /// unresponsive server.
        case timeout

        /// A human-readable description of the error for logging and
        /// debugging purposes. Each case provides a detailed explanation
        /// of what went wrong.
        var description: String {
            switch self {
            case .invalidURL:
                return "The provided URL is invalid. Please ensure the URL is correctly formatted and contains valid characters."
            case .noData:
                return "No data was received from the server. The response body was empty, which may indicate a server-side issue."
            case .decodingError:
                return "Failed to decode the response data. Please verify that the response format matches the expected Codable model."
            case .serverError(let statusCode):
                return "The server returned an error with HTTP status code \(statusCode). Please check the server logs for more details."
            case .connectionFailed:
                return "Unable to establish a network connection. Please check your internet connectivity and try again."
            case .timeout:
                return "The network request timed out. The server may be experiencing high load or network congestion may be occurring."
            }
        }
    }

    // MARK: - Initialization

    /// Private initializer to enforce the singleton pattern and prevent
    /// external instantiation of the NetworkManager class. This ensures
    /// that all network operations go through the shared instance.
    private init() {
        // Initialize the URL session with the default configuration
        // to provide a good balance between performance and functionality
        self.session = URLSession(configuration: .default)
    }

    // MARK: - Public Methods

    /// Fetches raw data from the specified URL string asynchronously.
    ///
    /// This method handles the complete lifecycle of a network request,
    /// including URL validation, request execution, and response validation.
    /// It leverages Swift's modern async/await concurrency model to provide
    /// a clean and readable API.
    ///
    /// - Parameter urlString: A string representation of the URL to fetch data from.
    ///   The string must be a valid URL format including the scheme (e.g., "https://").
    /// - Returns: The raw `Data` received from the server after successful validation.
    /// - Throws: A `NetworkError` if any step of the process fails, including
    ///   URL validation, network connectivity issues, or server errors.
    ///
    /// ## Example
    /// ```swift
    /// do {
    ///     let data = try await NetworkManager.shared.fetchData(from: "https://api.example.com/sensors")
    ///     // Process the received data
    /// } catch {
    ///     print("Failed to fetch data: \(error)")
    /// }
    /// ```
    func fetchData(from urlString: String) async throws -> Data {
        // Step 1: Validate and construct the URL from the provided string
        guard let url = URL(string: urlString) else {
            // If the URL is invalid, throw an appropriate error
            throw NetworkError.invalidURL
        }

        // Step 2: Perform the network request using async/await
        let (data, response) = try await session.data(from: url)

        // Step 3: Validate the HTTP response status code
        guard let httpResponse = response as? HTTPURLResponse else {
            // If we can't cast to HTTPURLResponse, something unexpected happened
            throw NetworkError.noData
        }

        // Step 4: Ensure the status code is in the success range (200-299)
        guard (200...299).contains(httpResponse.statusCode) else {
            // If the status code indicates an error, throw a server error
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }

        // Step 5: Return the validated data
        return data
    }

    /// Fetches and decodes JSON data from the specified URL into the requested type.
    ///
    /// This generic method combines network fetching with JSON decoding to provide
    /// a type-safe way to retrieve and parse remote data. It handles the complete
    /// pipeline from URL validation through JSON deserialization.
    ///
    /// - Parameters:
    ///   - type: The `Decodable` type to decode the response into. This parameter
    ///     uses Swift generics to provide compile-time type safety.
    ///   - urlString: A string representation of the URL to fetch JSON data from.
    /// - Returns: An instance of the specified type, decoded from the server's JSON response.
    /// - Throws: A `NetworkError` if the request fails or the response cannot be decoded.
    func fetchJSON<T: Decodable>(_ type: T.Type, from urlString: String) async throws -> T {
        // First, fetch the raw data from the server
        let data = try await fetchData(from: urlString)

        // Then, attempt to decode the data into the specified type
        do {
            // Create a JSON decoder with appropriate settings
            let decoder = JSONDecoder()
            // Configure the decoder to handle snake_case to camelCase conversion
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            // Decode the data and return the result
            return try decoder.decode(T.self, from: data)
        } catch {
            // If decoding fails, throw a descriptive error
            throw NetworkError.decodingError
        }
    }

    /// Performs a POST request with the specified body data to the given URL.
    ///
    /// This method enables sending data to a server endpoint using the HTTP POST
    /// method. It handles request construction, header configuration, and response
    /// validation to ensure reliable data transmission.
    ///
    /// - Parameters:
    ///   - urlString: The destination URL for the POST request.
    ///   - body: The `Encodable` data to send in the request body.
    /// - Returns: The response `Data` from the server.
    /// - Throws: A `NetworkError` if the request fails.
    func postData<T: Encodable>(_ body: T, to urlString: String) async throws -> Data {
        // Validate the URL
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }

        // Create and configure the URL request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Encode the body data
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(body)

        // Perform the network request
        let (data, response) = try await session.data(for: request)

        // Validate the response
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 0)
        }

        return data
    }
}
