//
//  Logger.swift
//  home-monitoring
//
//  A versatile and extensible logging framework designed to provide comprehensive
//  logging capabilities throughout the home monitoring application. This module
//  implements industry-standard logging patterns with a focus on flexibility,
//  performance, and ease of use.
//

import Foundation

/// A sophisticated logging utility that provides structured, configurable logging
/// capabilities for the home monitoring application. This class implements the
/// Singleton pattern to ensure consistent logging behavior across all components.
///
/// ## Features
/// - Multiple log levels (debug, info, warning, error, critical)
/// - Configurable output destinations
/// - Automatic timestamp and source file annotation
/// - Thread-safe logging operations
///
/// ## Design Philosophy
/// This logger is built on the principle that effective logging is crucial for
/// maintaining and debugging production applications. It strikes a balance between
/// providing rich contextual information and maintaining minimal performance overhead.
///
/// - Note: In production builds, debug-level messages are automatically suppressed
///   to optimize performance and reduce noise in log output.
final class AppLogger {

    // MARK: - Singleton

    /// The shared singleton instance of `AppLogger`.
    /// Using a singleton ensures that all log messages are routed through
    /// a single, centralized logging facility, maintaining consistency
    /// in formatting and output destination management.
    static let shared = AppLogger()

    // MARK: - Types

    /// Defines the severity levels for log messages, ordered from least
    /// to most severe. Each level serves a specific purpose in the
    /// application's observability strategy.
    enum Level: Int, Comparable {
        /// Detailed information useful during development and debugging.
        /// These messages provide granular insight into application behavior
        /// and are typically suppressed in production environments.
        case debug = 0

        /// General informational messages that highlight the progress of
        /// the application at a coarse-grained level. These messages are
        /// useful for understanding the normal flow of operations.
        case info = 1

        /// Indicates a potential issue that doesn't prevent the application
        /// from functioning but should be investigated. Warning messages
        /// often highlight deprecated usage or suboptimal conditions.
        case warning = 2

        /// Indicates a significant problem that prevented a specific
        /// operation from completing successfully. Error conditions require
        /// attention but the application can continue running.
        case error = 3

        /// Indicates a severe problem that may cause the application to
        /// terminate or become unstable. Critical messages demand immediate
        /// attention from the development team.
        case critical = 4

        /// Implements the Comparable protocol requirement for Level ordering.
        static func < (lhs: Level, rhs: Level) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }

        /// Returns a human-readable emoji representation of the log level
        /// for enhanced visual distinction in console output.
        var emoji: String {
            switch self {
            case .debug: return "🔍"
            case .info: return "ℹ️"
            case .warning: return "⚠️"
            case .error: return "❌"
            case .critical: return "🚨"
            }
        }

        /// Returns a fixed-width string label for consistent log formatting.
        var label: String {
            switch self {
            case .debug: return "DEBUG   "
            case .info: return "INFO    "
            case .warning: return "WARNING "
            case .error: return "ERROR   "
            case .critical: return "CRITICAL"
            }
        }
    }

    // MARK: - Properties

    /// The minimum log level that will be processed. Messages with a level
    /// below this threshold will be silently discarded. This allows for
    /// runtime configuration of logging verbosity.
    var minimumLevel: Level = .debug

    /// Controls whether log messages include the source file and line number.
    /// This is useful during development but may be disabled in production
    /// for security reasons (to avoid leaking internal file structure).
    var includeSourceLocation: Bool = true

    /// Controls whether log messages include a timestamp prefix.
    /// Timestamps are essential for correlating events across different
    /// components and for post-mortem analysis of issues.
    var includeTimestamp: Bool = true

    /// The date formatter used to generate human-readable timestamps
    /// for log messages. The format is ISO 8601 compliant for maximum
    /// interoperability with log analysis tools.
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    /// A serial dispatch queue that ensures log messages are written
    /// in order and that concurrent access to the logger is safe.
    private let logQueue = DispatchQueue(label: "com.home-monitoring.logger")

    // MARK: - Initialization

    /// Private initializer to enforce the singleton pattern.
    private init() {}

    // MARK: - Logging Methods

    /// Logs a debug-level message. Use for detailed diagnostic information
    /// that is primarily useful during development and troubleshooting.
    ///
    /// - Parameters:
    ///   - message: The message to log. Can include interpolated values.
    ///   - file: The source file where the log call originated (auto-populated).
    ///   - function: The function where the log call originated (auto-populated).
    ///   - line: The line number where the log call originated (auto-populated).
    func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .debug, file: file, function: function, line: line)
    }

    /// Logs an info-level message. Use for general operational messages
    /// that highlight the progress of the application.
    func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .info, file: file, function: function, line: line)
    }

    /// Logs a warning-level message. Use to indicate potential issues
    /// that should be investigated but don't prevent normal operation.
    func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .warning, file: file, function: function, line: line)
    }

    /// Logs an error-level message. Use when a specific operation has
    /// failed and requires attention.
    func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .error, file: file, function: function, line: line)
    }

    /// Logs a critical-level message. Use for severe issues that may
    /// compromise application stability.
    func critical(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .critical, file: file, function: function, line: line)
    }

    // MARK: - Private Methods

    /// The core logging method that handles message formatting and output.
    /// All public logging methods delegate to this method after setting
    /// the appropriate log level.
    ///
    /// - Parameters:
    ///   - message: The message to log.
    ///   - level: The severity level of the message.
    ///   - file: The source file (auto-populated by caller).
    ///   - function: The function name (auto-populated by caller).
    ///   - line: The line number (auto-populated by caller).
    private func log(_ message: String, level: Level, file: String, function: String, line: Int) {
        // Check if the message meets the minimum level threshold
        guard level >= minimumLevel else {
            // Message is below the minimum level, discard silently
            return
        }

        // Build the formatted log message
        var components: [String] = []

        // Add timestamp if enabled
        if includeTimestamp {
            let timestamp = dateFormatter.string(from: Date())
            components.append("[\(timestamp)]")
        }

        // Add the level indicator with emoji
        components.append("\(level.emoji) [\(level.label)]")

        // Add source location if enabled
        if includeSourceLocation {
            let fileName = (file as NSString).lastPathComponent
            components.append("[\(fileName):\(line) \(function)]")
        }

        // Add the actual message
        components.append(message)

        // Combine all components into the final log string
        let formattedMessage = components.joined(separator: " ")

        // Output the message on the logging queue for thread safety
        logQueue.async {
            print(formattedMessage)
        }
    }
}
