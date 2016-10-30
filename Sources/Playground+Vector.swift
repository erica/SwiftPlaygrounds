import UIKit

#if !os(OSX)
    extension CGVector: CustomPlaygroundQuickLookable {
        public var customPlaygroundQuickLook: PlaygroundQuickLook {
            func _rounded(_ value: CGFloat, _ places: Int) -> CGFloat {
                let degree = pow(10.0, CGFloat(places))
                return (value * degree).rounded() / degree
            }

            // Magnitude and normalized
            let magnitude = hypot(dx, dy)
            let (nx, ny) = (dx / magnitude, dy / magnitude)
            let angle = atan2(dy, dx) * 180 / CGFloat(Double.pi)
            
            let (fullSize, halfSize): (CGFloat, CGFloat) = (100, 50)
            let scale = halfSize * 0.9 / magnitude
            
            // Establish paths
            let (path, gridPath) = (UIBezierPath(), UIBezierPath())
            
            // Grid
            gridPath.move(to: CGPoint(x: 0, y: halfSize))
            gridPath.addLine(to: CGPoint(x: 0, y: -halfSize))
            gridPath.move(to: CGPoint(x: -halfSize, y: 0))
            gridPath.addLine(to: CGPoint(x: halfSize, y: 0))

            // Highlight origin
            let circle = UIBezierPath(ovalIn:
                CGRect(x: -2, y: -2, width: 4, height: 4))
            path.append(circle)
            
            // Vector line
            let endPoint = CGPoint(x: dx * scale, y: dy * scale)
            path.move(to: .zero)
            path.addLine(to: endPoint)
           
            // Arrowhead
            let ax = fullSize * 0.05 * (-ny - nx)
            let ay = fullSize * 0.05 * (nx - ny)
            path.move(to: endPoint)
            path.addLine(to: CGPoint(x: endPoint.x + ax, y: endPoint.y + ay))
            path.move(to: endPoint)
            path.addLine(to: CGPoint(x: endPoint.x - ay, y: endPoint.y + ax))
            
            // Flip into UIKit
            path.apply(CGAffineTransform(scaleX: 1, y: -1))
            
            // Info
            let style = NSMutableParagraphStyle()
            style.alignment = .center
            
            let attributes: [String: Any] = [
                NSParagraphStyleAttributeName: style,
                NSFontAttributeName: UIFont.systemFont(ofSize: 9),
                NSForegroundColorAttributeName: UIColor.black
            ]
            let description = NSAttributedString(string: "\(dx) dx, \(dy) dy\n\(_rounded(magnitude, 2)) pts, \(_rounded(angle, 2))°", attributes: attributes)
            
            // Establish drawing context
            let size = CGSize(width: 100, height: 150)
            UIGraphicsBeginImageContextWithOptions(size, true, 1)
            
            // Very light gray background
            UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1.0).set()
            UIRectFill(CGRect(origin: .zero, size: size))

            // dx, dy, magnitude
            description .draw(in: CGRect(x: 0, y: 5, width: 100, height: 40))
            
            // Context guaranteed
            UIGraphicsGetCurrentContext()!.translateBy(x: 50, y: 90)
            
            // Draw grid then vector
            UIColor.lightGray.set(); gridPath.stroke()
            UIColor.black.set(); path.stroke()
            
            // Image guaranteed
            let image = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            
            return .image(image)
        }
    }
#endif

