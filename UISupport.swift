import UIKit
import PlaygroundSupport

public let currentPage = PlaygroundPage.current

extension PlaygroundPage {
    public func run() { currentPage.needsIndefiniteExecution = true }
    public func stop() { currentPage.finishExecution() }
}

#if !os(OSX)
    public extension UIView {
        public convenience init(
            _ w: CGFloat,
            _ h: CGFloat,
            position: CGPoint = .zero,
            backgroundColor: UIColor = .white,
            translucency alpha: CGFloat = 1.0,
            borderWidth: CGFloat = 0.0,
            borderColor: UIColor = .black,
            cornerRadius: CGFloat = 0.0
            ){
            
            self.init(frame: CGRect(x: position.x, y: position.y, width: w, height: h))
            self.backgroundColor = backgroundColor.withAlphaComponent(alpha)
            self.layer.borderWidth = borderWidth
            self.layer.borderColor = borderColor.cgColor
            self.layer.cornerRadius = cornerRadius
            
            self.translatesAutoresizingMaskIntoConstraints = false
            self.contentMode = .scaleAspectFit
            self.clipsToBounds = true
        }
    }
    
    public extension UIViewController {
        public convenience init(_ backgroundColor: UIColor) {
            self.init()
            view.backgroundColor = backgroundColor
        }
    }
#endif
