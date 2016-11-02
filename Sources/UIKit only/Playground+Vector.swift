import UIKit

extension CGVector {
    public func asPath(size fullSize: CGFloat) -> UIBezierPath {
        // Magnitude and normalized
        let magnitude = hypot(dx, dy)
        let (nx, ny) = (dx / magnitude, dy / magnitude)
        
        let halfSize = fullSize / 2
        let scale = halfSize * 0.9 / magnitude
        
        // Vector line
        let endPoint = CGPoint(x: dx * scale, y: dy * scale)
        let path = UIBezierPath()
        path.move(to: .zero); path.addLine(to: endPoint)
        
        // Arrowhead
        let ax = fullSize * 0.05 * (-ny - nx)
        let ay = fullSize * 0.05 * (nx - ny)
        path.move(to: endPoint)
        path.addLine(to: CGPoint(x: endPoint.x + ax, y: endPoint.y + ay))
        path.move(to: endPoint)
        path.addLine(to: CGPoint(x: endPoint.x - ay, y: endPoint.y + ax))
        
        // Flip into UIKit
        path.apply(CGAffineTransform(scaleX: 1, y: -1))
        return path
    }
    
    public func asGraph(size side: CGFloat) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: side, height: side))
        return renderer.image { context in
            Grapher(size: side).grid().draw(at: .zero)
            context.cgContext.translateBy(x: side / 2, y: side / 2)
            Grapher.playgroundBlue.set()
            let path = self.asPath(size: side); path.lineWidth = 1.75
            path.stroke()
        }
    }
}

extension CGVector: CustomPlaygroundQuickLookable {
    public func info() -> String {
        func _rounded(_ value: CGFloat, _ places: Int) -> CGFloat {
            let degree = pow(10.0, CGFloat(places))
            return (value * degree).rounded() / degree
        }
        let magnitude = hypot(dx, dy)
        let angle = atan2(dy, dx) * 180 / CGFloat(Double.pi)
        return "\(dx) dx, \(dy) dy\n\(_rounded(magnitude, 2)) pts, \(_rounded(angle, 2))°"
    }
    
    public func attributedInfo() -> NSAttributedString {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        
        let attributes: [String: Any] = [
            NSParagraphStyleAttributeName: style,
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 12),
            NSForegroundColorAttributeName: UIColor.black
        ]
        return NSAttributedString(string: self.info(), attributes: attributes)
    }
    
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        // Establish drawing context
        let size = CGSize(width: 180, height: 240)
        let image = UIGraphicsImageRenderer(size: size).image { context in
            Grapher.playgroundGray.set()
            context.fill(context.format.bounds)
            self.asGraph(size: 180).draw(at: CGPoint(x: 0, y: 10))
            attributedInfo().draw(in: CGRect(x: 0, y: 190, width: 180, height: 50))
        }
        return .image(image)
    }
}
