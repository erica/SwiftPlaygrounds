import Foundation
import PlaygroundSupport

/// Convenience
public let fileManager = FileManager.default

/// Controls and informs the playground's state
public enum PlaygroundState {
    /// Shared data folder, typically ~/Shared\ Playground\ Data
    public static var sharedDataURL = playgroundSharedDataDirectory
    
    /// Returns the `PlaygroundPage` instance representing the current page in the playground.
    public static var page: PlaygroundPage {
        return PlaygroundSupport.PlaygroundPage.current
    }
    
    /// Indicates whether the playground page needs to execute indefinitely.
    /// The default value of this property is `false`, but playground pages with live views will automatically set this to `true`.
    public static var runsForever: Bool {
        get { return page.needsIndefiniteExecution }
        set { page.needsIndefiniteExecution = newValue }
    }
    
    /// Establishes that the playground page needs to execute indefinitely
    public static func runForever() { page.needsIndefiniteExecution = true }
    
    /// Instructs Xcode that the playground page has finished execution.
    public static func stop() { page.finishExecution() }
    
    /// The live view currently being displayed by Xcode on behalf
    /// of the playground page, or nil if there is no live view.
    public static var liveView: PlaygroundLiveViewable? {
        get { return page.liveView }
        set { page.liveView = newValue }
    }
    
    /// The playground's process information dictionary
    public static var processInfo: ProcessInfo {
        return ProcessInfo.processInfo
    }
    
    /// The playground's environmental variables
    public static var processEnvironment: [String: String] {
        return processInfo.environment
    }
    
    /// The Xcode-defined name of the playground process
    public static var processName: String {
        return processInfo.processName as String
    }
    
    #if !os(OSX)
    /// The file name of the current playground
    public static var playgroundName: String {
    return processEnvironment["PLAYGROUND_NAME"] ?? "Playground"
    }
    
    public static var myDocsFolder: URL
    {
    let folderURL = sharedDataURL.appendingPathComponent(playgroundName)
    if !fileManager.fileExists(atPath: folderURL.path) {
    do {
    try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)
    } catch { print("Unable to establish folder at", folderURL) }
    }
    return folderURL
    }
    
    /// Simulator's device family
    public static var deviceFamily: String {
    return processEnvironment["IPHONE_SIMULATOR_DEVICE"] ?? "Unknown Device Family"
    }
    
    /// Simulator's device name
    public static var deviceName: String {
    return processEnvironment["SIMULATOR_DEVICE_NAME"] ?? "Unknown Device Name"
    }
    
    /// Simulator's firmware version
    public static var runtimeVersion: String {
    return processEnvironment["SIMULATOR_RUNTIME_VERSION"] ?? "Unknown Runtime Version"
    }
    
    /// Simulator's main screen dimensions
    public static var mainscreenDimensions: (width: Double, height: Double) {
    let width = Double(processEnvironment["SIMULATOR_MAINSCREEN_WIDTH"] ?? "nan") ?? Double.nan
    let height = Double(processEnvironment["SIMULATOR_MAINSCREEN_HEIGHT"] ?? "nan") ?? Double.nan
    return (width, height)
    }
    
    /// Simulator's main screen scale
    public static var mainscreenScale: Double {
    return Double(processEnvironment["SIMULATOR_MAINSCREEN_SCALE"] ?? "nan") ?? Double.nan
    }
    
    /// Simulator's logging root
    public static var logRoot: URL? {
    guard let path = processEnvironment["SIMULATOR_LOG_ROOT"] else { return nil }
    return URL(fileURLWithPath: path)
    }
    #endif
    
    /// The playground's sandbox container
    public static var containerURL: URL? {
        guard let containerPath = self.processEnvironment["PLAYGROUND_SANDBOX_CONTAINER_PATH"] else {
            return nil
        }
        return URL(fileURLWithPath: containerPath)
    }
}
