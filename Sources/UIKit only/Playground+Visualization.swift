#if !os(OSX)
    import UIKit
    
    public struct Grapher {
        public static let playgroundGray = #colorLiteral(red: 0.97, green: 0.97, blue: 0.97, alpha: 1.0)
        public static let playgroundBlue = #colorLiteral(red: 0.2192041874, green: 0.5106022954, blue: 1, alpha: 1)
        let size: CGFloat, halfSize: CGFloat
        
        public init(size: CGFloat) {
            (self.size, self.halfSize) = (size, size / 2)
        }
        
        public func grid() -> UIImage {
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
            return renderer.image { context in
                Grapher.playgroundGray.set(); context.fill(context.format.bounds)
                context.cgContext.translateBy(x: halfSize, y: halfSize)
                let gridPath = UIBezierPath()
                gridPath.move(to: CGPoint(x: 0, y: halfSize))
                gridPath.addLine(to: CGPoint(x: 0, y: -halfSize))
                gridPath.move(to: CGPoint(x: -halfSize, y: 0))
                gridPath.addLine(to: CGPoint(x: halfSize, y: 0))
                UIColor.lightGray.set(); gridPath.stroke()
                
                // Highlight origin
                let wee = size * 0.02
                let circle = UIBezierPath(ovalIn: CGRect(x: -wee, y: -wee, width: wee * 2, height: wee * 2))
                UIColor.darkGray.set(); circle.fill()
            }
        }
    }
#endif
