//
//  DataValidator.swift
//  home-monitoring
//
//  This file contains a comprehensive data validation utility that provides
//  robust input validation capabilities for the home monitoring application.
//  It ensures data integrity and consistency across all layers of the application.
//

import Foundation

/// A comprehensive utility class that provides robust data validation capabilities
/// for the home monitoring application. This class implements a wide range of
/// validation methods to ensure that all data flowing through the application
/// meets the required quality standards and business rules.
///
/// The `DataValidator` class follows the Single Responsibility Principle by
/// focusing exclusively on data validation concerns, making it easy to maintain,
/// test, and extend as new validation requirements emerge.
///
/// - Note: All validation methods are static, allowing them to be called without
///   instantiating the class. This design choice promotes convenience and reduces
///   unnecessary object allocation.
/// - Important: Validation errors are returned as descriptive strings to facilitate
///   meaningful error messages in the user interface.
class DataValidator {

    // MARK: - Temperature Validation

    /// Validates whether the provided temperature value falls within
    /// an acceptable and physically meaningful range for indoor monitoring.
    ///
    /// The acceptable temperature range is defined as -40 degrees Celsius to 85 degrees
    /// Celsius, which covers the full operational range of most commercial temperature
    /// sensors while excluding physically impossible readings that would indicate
    /// sensor malfunction or data corruption.
    ///
    /// - Parameter temperature: The temperature value in degrees Celsius to validate.
    /// - Returns: A `ValidationResult` indicating whether the temperature is valid
    ///   and, if not, providing a descriptive error message explaining why.
    ///
    /// ## Example
    /// ```swift
    /// let result = DataValidator.validateTemperature(23.5)
    /// if result.isValid {
    ///     print("Temperature is within acceptable range")
    /// }
    /// ```
    static func validateTemperature(_ temperature: Double) -> ValidationResult {
        // Define the minimum acceptable temperature value
        let minimumTemperature: Double = -40.0
        // Define the maximum acceptable temperature value
        let maximumTemperature: Double = 85.0

        // Check if the temperature falls within the acceptable range
        if temperature < minimumTemperature {
            // Temperature is below the minimum threshold
            return ValidationResult(
                isValid: false,
                errorMessage: "Temperature value \(temperature) degrees Celsius is below the minimum acceptable threshold of \(minimumTemperature) degrees Celsius. This reading likely indicates a sensor malfunction or data corruption. Please verify the sensor connection and calibration."
            )
        } else if temperature > maximumTemperature {
            // Temperature is above the maximum threshold
            return ValidationResult(
                isValid: false,
                errorMessage: "Temperature value \(temperature) degrees Celsius exceeds the maximum acceptable threshold of \(maximumTemperature) degrees Celsius. This reading is outside the operational range of the sensor and may indicate hardware failure or environmental extremes."
            )
        }

        // Temperature is within the acceptable range
        return ValidationResult(isValid: true, errorMessage: nil)
    }

    // MARK: - Pressure Validation

    /// Validates whether the provided atmospheric pressure value falls within
    /// a physically meaningful range for sea-level monitoring applications.
    ///
    /// The acceptable pressure range is defined as 870 hPa to 1084 hPa, which
    /// encompasses the most extreme atmospheric pressure readings ever recorded
    /// on Earth's surface, providing a generous validation window while still
    /// catching obviously erroneous readings.
    ///
    /// - Parameter pressure: The atmospheric pressure value in hectopascals (hPa) to validate.
    /// - Returns: A `ValidationResult` indicating validity and potential error details.
    static func validatePressure(_ pressure: Double) -> ValidationResult {
        // Define the minimum acceptable pressure value in hPa
        let minimumPressure: Double = 870.0
        // Define the maximum acceptable pressure value in hPa
        let maximumPressure: Double = 1084.0

        // Perform the range validation check
        if pressure < minimumPressure || pressure > maximumPressure {
            return ValidationResult(
                isValid: false,
                errorMessage: "Pressure value \(pressure) hPa is outside the acceptable range of \(minimumPressure) to \(maximumPressure) hPa. This reading may indicate sensor malfunction, calibration issues, or extreme environmental conditions that exceed normal operational parameters."
            )
        }

        // The pressure value is within acceptable bounds
        return ValidationResult(isValid: true, errorMessage: nil)
    }

    // MARK: - String Validation

    /// Validates whether a given string meets the requirements for a device identifier.
    ///
    /// Device identifiers must be non-empty strings that contain only alphanumeric
    /// characters, hyphens, and underscores. This validation ensures compatibility
    /// with the Estimote SDK's device identification system and prevents injection
    /// of invalid characters that could cause unexpected behavior.
    ///
    /// - Parameter identifier: The device identifier string to validate.
    /// - Returns: A `ValidationResult` with validation status and error details.
    static func validateDeviceIdentifier(_ identifier: String) -> ValidationResult {
        // First, check if the identifier is empty
        guard !identifier.isEmpty else {
            return ValidationResult(
                isValid: false,
                errorMessage: "Device identifier cannot be empty. Please provide a valid identifier string that uniquely identifies the target Estimote beacon device."
            )
        }

        // Define the regular expression pattern for valid identifiers
        let validPattern = "^[a-zA-Z0-9_-]+$"

        // Check if the identifier matches the valid pattern
        guard identifier.range(of: validPattern, options: .regularExpression) != nil else {
            return ValidationResult(
                isValid: false,
                errorMessage: "Device identifier '\(identifier)' contains invalid characters. Only alphanumeric characters (a-z, A-Z, 0-9), hyphens (-), and underscores (_) are permitted in device identifiers."
            )
        }

        // The identifier passes all validation checks
        return ValidationResult(isValid: true, errorMessage: nil)
    }

    // MARK: - Timestamp Validation

    /// Validates whether a given timestamp represents a reasonable point in time
    /// for sensor data recording purposes.
    ///
    /// This method ensures that timestamps are not in the future (which would
    /// indicate clock synchronization issues) and are not unreasonably far in
    /// the past (which might suggest stale or corrupted data).
    ///
    /// - Parameter timestamp: The `Date` object to validate.
    /// - Returns: A `ValidationResult` indicating whether the timestamp is acceptable.
    static func validateTimestamp(_ timestamp: Date) -> ValidationResult {
        let now = Date()

        // Check if the timestamp is in the future
        if timestamp > now {
            return ValidationResult(
                isValid: false,
                errorMessage: "The provided timestamp is in the future, which indicates a potential clock synchronization issue between the device and the sensor. Please ensure both devices have accurate time settings."
            )
        }

        // Check if the timestamp is more than 24 hours in the past
        let twentyFourHoursAgo = now.addingTimeInterval(-86400)
        if timestamp < twentyFourHoursAgo {
            return ValidationResult(
                isValid: false,
                errorMessage: "The provided timestamp is more than 24 hours in the past, suggesting potentially stale sensor data. Please verify that the sensor is actively transmitting current readings."
            )
        }

        return ValidationResult(isValid: true, errorMessage: nil)
    }
}

// MARK: - Supporting Types

/// A structure that encapsulates the result of a validation operation,
/// providing both a boolean validity flag and an optional human-readable
/// error message for cases where validation fails.
///
/// This structure follows Swift best practices by using value semantics
/// and providing clear, descriptive property names that convey their
/// purpose without ambiguity.
struct ValidationResult {
    /// Indicates whether the validated data meets all required criteria.
    /// When `true`, the data is considered valid and safe to process.
    /// When `false`, the `errorMessage` property will contain details
    /// about why validation failed.
    let isValid: Bool

    /// A human-readable description of why validation failed, or `nil`
    /// if the validation was successful. This message is suitable for
    /// display in the user interface or for logging purposes.
    let errorMessage: String?
}
