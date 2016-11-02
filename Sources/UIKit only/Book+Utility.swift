import UIKit
import PlaygroundSupport

extension UIImage {
    public func saveImage() {
        #if arch(x86_64) || arch(i386)
            guard let data = UIImagePNGRepresentation(self) else { return }
            let sharedFolderURL = playgroundSharedDataDirectory.appendingPathComponent("Drawing")
            let _ = try? FileManager.default.createDirectory(at: sharedFolderURL, withIntermediateDirectories: true, attributes: nil)
            let destinationURL = sharedFolderURL.appendingPathComponent("Image.png")
            guard let _ = try? data.write(to: destinationURL) else {
                print("Failed to write data"); return
            }
            print(destinationURL.path)
            print("cp '\(destinationURL.path)' /Users/ericasadun/drawing/writing/images/C02/New.png")
        #endif
    }
}

extension Data {
    public func savePDFData() {
        #if arch(x86_64) || arch(i386)
            let sharedFolderURL = playgroundSharedDataDirectory.appendingPathComponent("Drawing")
            let _ = try? FileManager.default.createDirectory(at: sharedFolderURL, withIntermediateDirectories: true, attributes: nil)
            let destinationURL = sharedFolderURL.appendingPathComponent("Sample.pdf")
            guard let _ = try? self.write(to: destinationURL) else {
                print("Failed to write data"); return
            }
            print(destinationURL.path)
        #endif
    }
    
}
