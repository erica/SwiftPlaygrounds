#if os(macOS)
    import Cocoa
    fileprivate typealias _Font = NSFont
    fileprivate typealias _Color = NSColor
#else
    import UIKit
    fileprivate typealias _Font = UIFont
    fileprivate typealias _Color = UIColor
#endif

fileprivate let π = CGFloat(Double.pi)

extension String {
    /// Left pads string to at least `minWidth` characters wide
    fileprivate func leftPadded(_ character: Character, toWidth minWidth: Int) -> String {
        guard minWidth > characters.count
            else { return self }
        return String(repeating: String(character),
                      count: minWidth - characters.count) + self
    }
    
    /// Right pads string to at least `minWidth` characters wide
    fileprivate func rightPadded(_ character: Character, toWidth minWidth: Int) -> String {
        guard minWidth > characters.count
            else { return self }
        return self + String(repeating: String(character),
                             count: minWidth - characters.count)
    }
}

// Create padded CGFloat representation
extension CGFloat {
    fileprivate func paddedString(leftPad: Int = 0, rightPad: Int = 0) -> String {
        // Split at decimal
        let split = "\(self)".components(separatedBy: ".")
        assert (split.count > 1, "CGFloat always represents with decimal")
        
        // Fetch whole and fractional components
        let whole = split[0]; var fraction = split[1]
        
        // Truncate rhs if needed
        if rightPad != 0 && fraction.characters.count > rightPad {
            let idx = fraction.index(fraction.startIndex, offsetBy: rightPad)
            fraction = fraction.substring(to: idx)
        }
        
        // Pad, combine, and return
        return whole.leftPadded(" ", toWidth: leftPad) + "."
            + fraction.rightPadded("0", toWidth: rightPad)
    }
}

/// Visible properties
extension CGAffineTransform {
    fileprivate var _xScale: CGFloat { return sqrt(a * a + c * c) }
    fileprivate var _yScale: CGFloat { return sqrt(b * b + d * d) }
    fileprivate var _scale: CGSize { return CGSize(width: _xScale, height: _yScale) }
    fileprivate var _rotation: CGFloat { return atan2(b, a) }
    fileprivate var _degrees: CGFloat { return _rotation * 180 / CGFloat(Double.pi) }
}

/// Custom description
extension CGAffineTransform: CustomStringConvertible {
    public var description: String {
        // Default padding
        let (lpad, rpad, space) = (5, 3, " ")
        
        // Blanks between left and right pipes
        let blank = String(repeatElement(" ", count: (lpad + rpad + 1) * 3 +
            space.characters.count * 2))
        
        // A little padding utility for repeat use
        let padder: (Int, Int) -> (CGFloat) -> String = { lpad, rpad in
            return { value in
                value.paddedString(leftPad: lpad, rightPad: rpad)
            }
        }
        let pad = padder(lpad, rpad)
        let pad1 = padder(0, 1); let pad2 = padder(0, 2)
        
        // Return a single (a, b, c) matrix line
        let matrixLine: (CGFloat, CGFloat, CGFloat) -> String = { a, b, c in
            "│" + [a, b, c].map(pad).joined(separator: " ") + "│"
        }
        
        // A single blank line
        let blankline = "│" + blank + "│"
        
        // Construct result as text string
        var result = ""
        result += "┌" + blank + "┐\n"
        result += matrixLine(a, b, 0)
        result += " translation: (" + pad1(tx)
            + ", " + pad1(ty) + ")\n"
        result += blankline
        result += " scale:       (" + pad2(_xScale)
            + ", " + pad2(_yScale) + ")\n"
        result += matrixLine(c, d, 0)
        result += " rotation:    \(pad2(_degrees))°\n"
        result += blankline
        result += " rotation:    \(pad2(_rotation / π)) π\n"
        result += matrixLine(tx, ty, 1)
        result += " rotation:    \(pad2(_rotation)) radians\n"
        result += "└" + blank + "┘"
        return result
    }
}

// Custom Debug Presentation
extension CGAffineTransform: CustomDebugStringConvertible {
    /// Returns everything in description plus breakouts of
    /// transform properties
    public var debugDescription: String {
        return description
            + "\na: \(a), b: \(b), c: \(c), d: \(d), tx: \(tx), ty: \(tx)"
    }
}

extension CGAffineTransform {
    /// Attributed version of description
    public var attributedDescription: NSAttributedString {
        return NSAttributedString(string: description,
                                  attributes: CGAffineTransform._attributes)
    }
    
    /// Attributed version of debugDescription
    public var attributedDebugDescription: NSAttributedString {
        return NSAttributedString(string: debugDescription,
                                  attributes: CGAffineTransform._attributes)
    }
    
    // A shared set of rendering attributes
    // Other possible faces: CourierNewPSMT, Courier
    private static var _attributes: [String: Any] = [
        NSFontAttributeName: _Font(name: "Menlo-Regular", size: 9)!,
        NSForegroundColorAttributeName: _Color.black
    ]
}

// Custom Quicklook Presentation
extension CGAffineTransform: CustomPlaygroundQuickLookable {
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        return PlaygroundQuickLook.attributedString(attributedDescription)
    }
}
