import UIKit

#if !os(OSX)
    extension UIImage {
        /// Draws while preserving gstate. Non-performant.
        public static func pushDraw(
            in context: UIGraphicsImageRendererContext,
            applying actions: () -> Void)
        {
            context.cgContext.saveGState()
            actions()
            context.cgContext.restoreGState()
        }
        
        /// Render actions to an image
        public static func render(
            size: CGSize, scale: CGFloat = 1,
            applying actions: (_ context: UIGraphicsImageRendererContext) -> Void
            ) -> UIImage
        {
            let format = UIGraphicsImageRendererFormat(); format.scale = scale
            let renderer = UIGraphicsImageRenderer(size: size, format: format)
            return renderer.image { context in actions(context) }
        }
        
        
        /// Draws to an image
        public static func illustrate(
            width: CGFloat = 400, height: CGFloat = 400,
            scale: CGFloat = 1,
            centeringAxes shouldCenterContext: Bool = true,
            drawingAxes shouldDrawAxes: Bool = true,
            fill: Bool = true, stroke: Bool = true,
            applying actions: (_ context: UIGraphicsImageRendererContext) -> Void
            ) -> UIImage
        {
            
            let size = CGSize(width: width, height: height)
            let (halfWidth, halfHeight) = (width / 2, height / 2)
            return render(size: size) { context in
                if fill { UIColor.white.set(); UIRectFill(context.format.bounds) }
                
                // Draw axes
                if shouldDrawAxes {
                    
                    // X and y axes are straight lines
                    var path = UIBezierPath()
                    path.move(to: CGPoint(x: 0, y: halfHeight))
                    path.addLine(to: CGPoint(x: width, y: halfHeight))
                    path.move(to: CGPoint(x: halfWidth, y: 0))
                    path.addLine(to: CGPoint(x: halfWidth, y: height))
                    UIColor.black.set(); path.stroke()
                    
                    // Add dot at center of axes
                    UIImage.pushDraw(in: context) {
                        let amt = min(width, height) * 0.01
                        path = UIBezierPath(ovalIn: CGRect(x: -amt, y: -amt, width: amt * 2, height: amt * 2))
                        path.fill()
                    }
                }
                
                pushDraw(in: context){
                    // Zero context in middle
                    if shouldCenterContext {
                        context.cgContext.translateBy(x: halfWidth, y: halfHeight)
                    }
                    
                    // Perform actions
                    actions(context)
                }
                
                if stroke { UIColor.black.set(); UIRectFrame(context.format.bounds) }
            }
        }
        
        /// Draws a reduced version
        public func scale(by percent: CGFloat) -> UIImage {
            let (sw, sh) = (self.size.width * percent, self.size.height * percent)
            let newSize = CGSize(width: sw, height: sh)
            let rect = CGRect(origin: .zero, size: newSize)
            return UIImage.render(size: newSize) { context in
                self.draw(in: rect)
            }
        }
        
        /// Draws image1 then image2, ... into new image, aligned at top
        public func join(
            with images: UIImage...,
            fill: Bool = true, stroke: Bool = true,
            space: CGFloat = 20, inset: CGFloat = 20
            ) -> UIImage
        {
            let allImages = [self] + images
            let imageCount = allImages.count
            
            let maxh = allImages.reduce(0 as CGFloat, {
                $0 <  $1.size.height ? $1.size.height : $0
            })
            let height = maxh + 2 * inset
            
            let sumw = allImages.reduce(0 as CGFloat, {
                $0 + $1.size.width
            })
            let width = sumw + CGFloat(imageCount - 1) * space + 2 * inset
            
            let rect = CGRect(x: 0, y: 0, width: width, height: height)
            
            return UIImage.illustrate(width: width, height: height,
                                      centeringAxes: false, drawingAxes: false)
            { context in
                
                if fill { UIColor.white.setFill(); UIRectFill(rect) }
                var px = inset
                allImages.forEach { image in
                    defer { px += image.size.width + space }
                    let py = inset + (maxh - image.size.height) / 2
                    image.draw(at: CGPoint(x: px, y: py))
                }
                if stroke { UIColor.black.setStroke(); UIRectFrame(rect) }
            }
        }
    }
#endif
