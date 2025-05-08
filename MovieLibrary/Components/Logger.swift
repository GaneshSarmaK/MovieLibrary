//
//  Logger.swift
//  MovieLibrary
//
//  Created by NVR4GET on 6/12/2025.

//  Unified logging system using os.Logger for structured logging.
//  Provides categorized loggers and environment integration.

import os
import Foundation
import SwiftUI

/// Environment key for accessing AppLogger in SwiftUI views
private struct AppLoggerKey: EnvironmentKey {
    static let defaultValue: AppLogger = .shared
}

extension EnvironmentValues {
    /// Access to the app logger through environment values
    var appLogger: AppLogger {
        get { self[AppLoggerKey.self] }
        set { self[AppLoggerKey.self] = newValue }
    }
}

/// Centralized logging system using os.Logger
/// Provides categorized loggers for different parts of the app
final class AppLogger {
    /// General purpose logger
    nonisolated static let shared = AppLogger("general")
    
    /// Logger for data store operations
    nonisolated static let dataStore = AppLogger("dataStore")
    
    /// Logger for main app operations
    nonisolated static let main = AppLogger("main")
    
    /// Logger for component-level operations
    nonisolated static let component = AppLogger("component")
    
    /// Underlying os.Logger instance
    private let log: os.Logger
    
    /// Private initializer to create a logger with a specific category
    /// - Parameter category: Category name for the logger
    private init(_ category: String) {
        let subsystem = Bundle.main.bundleIdentifier ?? "com.sellergize.zifup"
        self.log = os.Logger(subsystem: subsystem, category: category)
    }
    
    /// Logs a debug message (only in DEBUG builds)
    /// - Parameter message: Debug message to log
    nonisolated func debugLog(_ message: String) {
#if DEBUG
        log.debug("\(message, privacy: .sensitive)")
#endif
    }
    
    /// Logs an informational message
    /// - Parameter message: Info message to log
    nonisolated func info(_ message: String) {
        log.info("\(message, privacy: .private)")
    }
    
    /// Logs an error message
    /// - Parameter message: Error message to log
    nonisolated func error(_ message: String) {
        log.error("\(message, privacy: .private)")
    }
    
    /// Logs a warning message
    /// - Parameter message: Warning message to log
    nonisolated func warning(_ message: String) {
        log.warning("\(message, privacy: .private)")
    }
    
    /// Logs a notice message
    /// - Parameter message: Notice message to log
    nonisolated func notice(_ message: String) {
        log.notice("\(message, privacy: .private)")
    }
    
    /// Logs a fault message (system-level issues)
    /// - Parameter message: Fault message to log
    nonisolated func fault(_ message: String) {
        log.fault("\(message, privacy: .private)")
    }
    
    /// Logs a trace message (detailed debugging)
    /// - Parameter message: Trace message to log
    nonisolated func trace(_ message: String) {
        log.trace("\(message, privacy: .private)")
    }
    
    /// Logs a critical message (highest priority)
    /// - Parameter message: Critical message to log
    nonisolated func critical(_ message: String) {
        log.critical("\(message, privacy: .sensitive)")
    }
}

