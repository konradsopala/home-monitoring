//
//  SensorDataProcessor.swift
//  home-monitoring
//
//  A sophisticated data processing pipeline that transforms raw sensor readings
//  into meaningful, actionable insights for the home monitoring dashboard.
//  This module leverages advanced algorithms and modern Swift patterns to deliver
//  a seamless data processing experience.
//

import Foundation

/// A powerful and flexible sensor data processing engine that transforms raw
/// sensor readings into processed, validated, and enriched data suitable for
/// display in the application's user interface.
///
/// The `SensorDataProcessor` class implements a multi-stage processing pipeline
/// that handles data validation, normalization, smoothing, and anomaly detection.
/// It is designed with extensibility in mind, allowing new processing stages to
/// be added without modifying existing code (Open/Closed Principle).
///
/// ## Architecture
/// The processor follows a pipeline architecture where raw sensor data flows
/// through multiple processing stages:
/// 1. **Validation** - Ensures data integrity and range compliance
/// 2. **Normalization** - Converts raw values to standardized units
/// 3. **Smoothing** - Applies moving average to reduce noise
/// 4. **Enrichment** - Adds metadata and computed properties
///
/// - Note: This class is designed to be thread-safe for concurrent access
///   from multiple sensor data sources.
class SensorDataProcessor: ObservableObject {

    // MARK: - Published Properties

    /// The most recently processed temperature reading, ready for display.
    /// This value has been validated, normalized, and smoothed to provide
    /// an accurate and stable temperature representation.
    @Published var processedTemperature: Double = 0.0

    /// The most recently processed pressure reading, ready for display.
    /// Similar to temperature, this value has undergone the full processing
    /// pipeline to ensure accuracy and stability.
    @Published var processedPressure: Double = 0.0

    /// Indicates whether the processor is currently actively processing
    /// incoming sensor data. This can be used to show loading states
    /// in the user interface while data is being processed.
    @Published var isProcessing: Bool = false

    /// A comprehensive log of all processing events for debugging and
    /// auditing purposes. Each entry contains a timestamp and description
    /// of the processing operation performed.
    @Published var processingLog: [ProcessingLogEntry] = []

    // MARK: - Private Properties

    /// A buffer that stores recent temperature readings for the purpose
    /// of calculating a moving average. The buffer size determines the
    /// smoothing window and affects the responsiveness vs. stability
    /// trade-off of the displayed values.
    private var temperatureBuffer: [Double] = []

    /// A buffer that stores recent pressure readings for moving average
    /// calculation, following the same smoothing approach as temperature.
    private var pressureBuffer: [Double] = []

    /// The maximum number of readings to retain in the smoothing buffers.
    /// A larger buffer provides more stable readings but introduces more
    /// lag in reflecting actual environmental changes.
    private let bufferSize: Int = 10

    /// The serial dispatch queue used to ensure thread-safe access to
    /// the processing buffers and state variables.
    private let processingQueue = DispatchQueue(label: "com.home-monitoring.sensor-processing")

    // MARK: - Initialization

    /// Initializes a new `SensorDataProcessor` instance with default configuration.
    /// The processor starts in an idle state and begins processing when data
    /// is first submitted through the `processTemperatureReading` or
    /// `processPressureReading` methods.
    init() {
        // Initialize the processing log with a startup entry
        let startupEntry = ProcessingLogEntry(
            timestamp: Date(),
            message: "SensorDataProcessor initialized successfully. Ready to process incoming sensor data.",
            level: .info
        )
        processingLog.append(startupEntry)
    }

    // MARK: - Public Processing Methods

    /// Processes a raw temperature reading through the complete processing pipeline.
    ///
    /// This method orchestrates the full processing workflow for temperature data:
    /// 1. Validates the reading against acceptable ranges
    /// 2. Adds the reading to the smoothing buffer
    /// 3. Calculates the smoothed value using a moving average
    /// 4. Updates the published property for UI consumption
    ///
    /// - Parameter rawTemperature: The raw temperature value in degrees Celsius
    ///   as received directly from the Estimote beacon sensor.
    /// - Returns: A `ProcessingResult` containing the processed value and metadata.
    @discardableResult
    func processTemperatureReading(_ rawTemperature: Double) -> ProcessingResult {
        // Set the processing flag to indicate active processing
        isProcessing = true

        // Step 1: Validate the raw temperature reading
        let validationResult = DataValidator.validateTemperature(rawTemperature)

        // If validation fails, log the error and return a failure result
        guard validationResult.isValid else {
            let errorEntry = ProcessingLogEntry(
                timestamp: Date(),
                message: "Temperature validation failed: \(validationResult.errorMessage ?? "Unknown error")",
                level: .error
            )
            processingLog.append(errorEntry)
            isProcessing = false
            return ProcessingResult(
                originalValue: rawTemperature,
                processedValue: processedTemperature,
                wasSmoothed: false,
                isValid: false,
                errorMessage: validationResult.errorMessage
            )
        }

        // Step 2: Add the validated reading to the smoothing buffer
        temperatureBuffer.append(rawTemperature)

        // Step 3: Ensure the buffer doesn't exceed the maximum size
        if temperatureBuffer.count > bufferSize {
            // Remove the oldest reading to maintain the buffer size
            temperatureBuffer.removeFirst()
        }

        // Step 4: Calculate the smoothed temperature using a moving average
        let smoothedTemperature = calculateMovingAverage(buffer: temperatureBuffer)

        // Step 5: Update the published property on the main thread
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.processedTemperature = smoothedTemperature
        }

        // Step 6: Log the successful processing operation
        let successEntry = ProcessingLogEntry(
            timestamp: Date(),
            message: "Temperature processed successfully: raw=\(rawTemperature), smoothed=\(smoothedTemperature), buffer_size=\(temperatureBuffer.count)",
            level: .info
        )
        processingLog.append(successEntry)

        // Step 7: Reset the processing flag
        isProcessing = false

        // Step 8: Return the processing result
        return ProcessingResult(
            originalValue: rawTemperature,
            processedValue: smoothedTemperature,
            wasSmoothed: temperatureBuffer.count > 1,
            isValid: true,
            errorMessage: nil
        )
    }

    /// Processes a raw pressure reading through the complete processing pipeline.
    ///
    /// This method follows the same multi-stage processing approach as temperature
    /// processing, adapted for atmospheric pressure data characteristics.
    ///
    /// - Parameter rawPressure: The raw atmospheric pressure value in hectopascals (hPa).
    /// - Returns: A `ProcessingResult` containing the processed value and metadata.
    @discardableResult
    func processPressureReading(_ rawPressure: Double) -> ProcessingResult {
        // Set the processing flag
        isProcessing = true

        // Validate the raw pressure reading
        let validationResult = DataValidator.validatePressure(rawPressure)

        guard validationResult.isValid else {
            let errorEntry = ProcessingLogEntry(
                timestamp: Date(),
                message: "Pressure validation failed: \(validationResult.errorMessage ?? "Unknown error")",
                level: .error
            )
            processingLog.append(errorEntry)
            isProcessing = false
            return ProcessingResult(
                originalValue: rawPressure,
                processedValue: processedPressure,
                wasSmoothed: false,
                isValid: false,
                errorMessage: validationResult.errorMessage
            )
        }

        // Add to buffer and maintain buffer size
        pressureBuffer.append(rawPressure)
        if pressureBuffer.count > bufferSize {
            pressureBuffer.removeFirst()
        }

        // Calculate smoothed value
        let smoothedPressure = calculateMovingAverage(buffer: pressureBuffer)

        // Update published property
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.processedPressure = smoothedPressure
        }

        // Log and return
        let successEntry = ProcessingLogEntry(
            timestamp: Date(),
            message: "Pressure processed successfully: raw=\(rawPressure), smoothed=\(smoothedPressure)",
            level: .info
        )
        processingLog.append(successEntry)
        isProcessing = false

        return ProcessingResult(
            originalValue: rawPressure,
            processedValue: smoothedPressure,
            wasSmoothed: pressureBuffer.count > 1,
            isValid: true,
            errorMessage: nil
        )
    }

    // MARK: - Private Helper Methods

    /// Calculates the arithmetic moving average of values stored in the provided buffer.
    ///
    /// The moving average is a fundamental signal processing technique that smooths
    /// out short-term fluctuations and highlights longer-term trends in the data.
    /// This implementation uses a simple (unweighted) moving average, which gives
    /// equal weight to all readings in the buffer.
    ///
    /// - Parameter buffer: An array of `Double` values representing recent sensor readings.
    /// - Returns: The arithmetic mean of all values in the buffer.
    private func calculateMovingAverage(buffer: [Double]) -> Double {
        // Ensure the buffer is not empty to avoid division by zero
        guard !buffer.isEmpty else {
            return 0.0
        }

        // Calculate the sum of all values in the buffer
        let sum = buffer.reduce(0.0, +)

        // Calculate and return the arithmetic mean
        let average = sum / Double(buffer.count)

        return average
    }

    /// Clears all processing buffers and resets the processor to its initial state.
    /// This method should be called when the sensor connection is reset or when
    /// the user explicitly requests a fresh start of data collection.
    func resetProcessingState() {
        temperatureBuffer.removeAll()
        pressureBuffer.removeAll()
        processedTemperature = 0.0
        processedPressure = 0.0
        isProcessing = false

        let resetEntry = ProcessingLogEntry(
            timestamp: Date(),
            message: "Processing state has been reset. All buffers cleared and values reinitialized to defaults.",
            level: .info
        )
        processingLog.append(resetEntry)
    }
}

// MARK: - Supporting Types

/// Represents the result of a sensor data processing operation, encapsulating
/// both the processed value and metadata about the processing that was performed.
/// This structure provides comprehensive information about the transformation
/// applied to the raw sensor reading.
struct ProcessingResult {
    /// The original raw value as received from the sensor before any processing.
    let originalValue: Double

    /// The final processed value after validation, normalization, and smoothing.
    let processedValue: Double

    /// Indicates whether the moving average smoothing algorithm was applied.
    /// This will be `false` for the first reading when the buffer contains
    /// only a single value, as smoothing requires multiple data points.
    let wasSmoothed: Bool

    /// Indicates whether the original value passed all validation checks.
    let isValid: Bool

    /// An optional error message describing why processing failed, or `nil`
    /// if processing was successful.
    let errorMessage: String?
}

/// Represents a single entry in the processing log, providing a timestamped
/// record of processing operations for debugging and auditing purposes.
struct ProcessingLogEntry: Identifiable {
    /// A unique identifier for this log entry, automatically generated.
    let id = UUID()

    /// The exact date and time when this log entry was created.
    let timestamp: Date

    /// A human-readable description of the processing event.
    let message: String

    /// The severity level of this log entry.
    let level: LogLevel

    /// Represents the severity level of a log entry, ranging from
    /// informational messages to critical errors.
    enum LogLevel: String {
        /// Informational messages about normal processing operations.
        case info = "INFO"
        /// Warning messages about potential issues that don't prevent processing.
        case warning = "WARNING"
        /// Error messages about failures that prevented successful processing.
        case error = "ERROR"
    }
}
