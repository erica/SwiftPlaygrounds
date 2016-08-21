/*
 
 ericasadun.com
 Super-basic layout utilities
 
 */

#if os(OSX)
    import Cocoa
    public typealias View = NSView
    public typealias ViewController = NSViewController
    public typealias LayoutPriority = NSLayoutPriority
#else
    import UIKit
    public typealias View = UIView
    public typealias ViewController = UIViewController
    public typealias LayoutPriority = UILayoutPriority
#endif

public let defaultLayoutOptions: NSLayoutFormatOptions = []
public let skipConstraint = CGRect.null.origin.x

public extension NSLayoutConstraint {
    /// Activates and prioritizes in one step
    /// - parameter priority: Layout priority for the constraint
    public func activate(priority: LayoutPriority) {
        self.priority = priority
        self.isActive = true
    }
    
    /// The constraint's first item cast to View type.
    /// Should never be non-nil.
    public var firstView: View {
        guard let first = firstItem as? View else { return View() }
        return first
    }
    
    /// The constraint's second item cast to View type.
    /// May be nil.
    public var secondView: View? {
        return secondItem as? View
    }
    
    /// Expresses whether the constraint refers to a given view
    public func refers(toView theView: View) -> Bool {
        if firstView == theView { return true }
        if let secondView = secondView { return secondView == theView }
        return false
    }
}

public extension View {
    /// Adds multiple subviews at once
    public func addSubviews(_ views: View...) {
        views.forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    /// Returns a view's superviews
    public var superviews: [View] {
        guard let superview = superview else { return [] }
        return Array(sequence(first: superview, next: { $0.superview }))
    }
}

#if !arch(arm64)
    // toOpaque seems to be missing on Swift Playgrounds right now
    extension View {
        /// Overrides default description with view frame
        open override var description: String {
            // return "[<\(type(of: self)): \(Unmanaged.passUnretained(self).toOpaque())> \(self.frame)]"
            return "[<\(type(of: self)): \(Unmanaged.passUnretained(self).toOpaque())> \(self.frame)]"
        }
    }
#endif

public extension View {
    
    /// Returns a list of external constraints that reference this view
    public var externalConstraintReferences: [NSLayoutConstraint] {
        var constraints: [NSLayoutConstraint] = []
        for superview in superviews {
            for constraint in superview.constraints {
                if constraint.refers(toView: self) {
                    constraints.append(constraint)
                }
            }
        }
        return constraints
    }
    
    /// Returns a list of internal constraints that reference this view
    public var internalConstraintReferences: [NSLayoutConstraint] {
        var constraints: [NSLayoutConstraint] = []
        for constraint in constraints {
            if constraint.refers(toView: self) {
                constraints.append(constraint)
            }
        }
        return constraints
    }
}

public extension View {
    /// Provides more approachable auto layout control
    public var autoLayoutEnabled: Bool {
        get {return !translatesAutoresizingMaskIntoConstraints}
        set {translatesAutoresizingMaskIntoConstraints = !newValue}
    }
}

/// Constrain a group of views
/// - parameter priority: layout priority between 1 and 1000
/// - parameter format: visual layout format string
/// - parameter views: in order from view1 to viewN
public func constrainViews(
    priority: LayoutPriority = 1000,
    _ format: String, views: View...)
{
    guard !views.isEmpty else { return }
    var bindings: [String: View] = ["view": views.first!]
    for (count, view) in views.enumerated() {
        bindings["view"+String(count + 1)] = view
        view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    let constraints = NSLayoutConstraint.constraints(
        withVisualFormat: format, options: [],
        metrics: nil, views: bindings)
    constraints.forEach { $0.activate(priority: priority) }
    NSLayoutConstraint.activate(constraints)
}

/// Constrain a single view
public func constrainView(
    priority: LayoutPriority = 1000,
    _ format: String, view: View) {
    constrainViews(priority: priority, format, views: view)
}

extension View {
    /// Stretch view to superview
    /// - parameter h: should stretch horizontally
    /// - parameter v: should stretch vertically
    public func stretchToSuperview(
        priority: LayoutPriority = 1000,
        h: Bool = true, v: Bool = true,
        inset: Int = 0)
    {
        #if os(OSX)
            guard let _ = superview else { self.print("no superview") ; return }
        #else
            guard let _ = superview else { print("no superview") ; return }
        #endif
        translatesAutoresizingMaskIntoConstraints = false
        if h { constrainView(priority: priority, "H:|-(\(inset))-[view]-(\(inset))-|", view: self) }
        if v { constrainView(priority: priority, "V:|-(\(inset))-[view]-(\(inset))-|", view: self) }
    }
    
    /// Center view in superview
    /// - parameter h: should center horizontally
    /// - parameter v: should center vertically
    public func centerInSuperview(
        priority: LayoutPriority = 1000,
        h: Bool = true, v: Bool = true) {
        #if os(OSX)
            guard let superview = superview else { self.print("no superview") ; return }
        #else
            guard let superview = superview else { print("no superview") ; return }
        #endif
        translatesAutoresizingMaskIntoConstraints = false
        if h { centerXAnchor.constraint(
            equalTo: superview.centerXAnchor)
            .activate(priority: priority)
        }
        if v { centerYAnchor.constraint(
            equalTo: superview.centerYAnchor)
            .activate(priority: priority)
        }
    }
    
    /// Set size constraint
    /// - Note: Set size's width or height to skipConstraint to skip
    public func constrainSize(
        priority: LayoutPriority = 1000,
        size: CGSize)
    {
        if size.width != skipConstraint {
            widthAnchor.constraint(equalToConstant: size.width)
                .activate(priority: priority)
        }
        if size.height != skipConstraint {
            heightAnchor.constraint(equalToConstant: size.height)
                .activate(priority: priority)
        }
    }
    
    /// Set minimum size constraint
    /// - Note: Set size's width or height to skipConstraint to skip
    public func constrainMinimumSize(
        priority: LayoutPriority = 1000,
        size: CGSize
        )
    {
        if size.width != skipConstraint {
            widthAnchor.constraint(greaterThanOrEqualToConstant: size.width)
                .activate(priority: priority)
        }
        if size.height != skipConstraint {
            heightAnchor.constraint(greaterThanOrEqualToConstant: size.height)
                .activate(priority: priority)
        }
    }
    
    /// Set maximum size constraint
    /// - Note: Set size's width or height to skipConstraint to skip
    public func constrainMaximumSize(
        priority: LayoutPriority = 1000,
        size: CGSize)
    {
        if size.width != skipConstraint {
            widthAnchor.constraint(lessThanOrEqualToConstant: size.width)
                .activate(priority: priority)
        }
        if size.height != skipConstraint {
            heightAnchor.constraint(lessThanOrEqualToConstant: size.height)
                .activate(priority: priority)
        }
    }
    
    /// Set position
    /// - Note: Set location's x or y to skipConstraint to skip
    public func constrainPosition(
        priority: LayoutPriority = 1000,
        position: CGPoint)
    {
        #if os(OSX)
            guard let superview = superview else { self.print("no superview") ; return }
        #else
            guard let superview = superview else { print("no superview") ; return }
        #endif
        if position.x != skipConstraint {
            leftAnchor.constraint(
                greaterThanOrEqualTo: superview.leftAnchor, constant: position.x)
                .activate(priority: priority)
        }
        if position.y != skipConstraint {
            topAnchor.constraint(
                greaterThanOrEqualTo: superview.topAnchor, constant: position.y)
                .activate(priority: priority)
        }
    }
}


#if !os(OSX)
    extension View {
        /// Stretch view to the edges of the parent view controller
        public func stretchToViewController(
            priority: LayoutPriority = 1000,
            viewController: UIViewController,
            insets: CGSize = .zero)
        {
            viewController.view.addSubview(self)
            translatesAutoresizingMaskIntoConstraints = false
            
            topAnchor.constraint(
                equalTo: viewController.view.topAnchor, constant: insets.height)
                .activate(priority: priority)
            bottomAnchor.constraint(
                equalTo: viewController.view.bottomAnchor, constant: insets.height)
                .activate(priority: priority)
            leadingAnchor.constraint(
                equalTo: viewController.view.leadingAnchor, constant: insets.width)
                .activate(priority: priority)
            trailingAnchor.constraint(
                equalTo: viewController.view.trailingAnchor, constant: insets.width)
                .activate(priority: priority)
        }
    }
#endif

extension View {
    /// Aligns view to superview using layout attribute name.
    /// - note: positive inset offsets always point towards the interior of the superview
    public func alignInSuperview(_ attribute: NSLayoutAttribute, inset: CGFloat = 0.0, priority: LayoutPriority = 1000) {
        guard let superview = superview else { return }
        let actualInset: CGFloat = [.left, .leading, .top].contains(attribute) ? -inset : inset
        let constraint = NSLayoutConstraint(item: superview, attribute: attribute, relatedBy: .equal, toItem: self, attribute: attribute, multiplier: 1.0, constant: actualInset)
        constraint.priority = priority
        constraint.isActive = true
    }
    
    /// Places view in (existing) superview using layout string.
    /// Use invalid char (e.g. "-" or "*") to skip constraint.
    public func placeInSuperview(_ position: String, inseth: CGFloat = 0.0, insetv: CGFloat = 0.0, priority: LayoutPriority = 1000) {
        if position.characters.count != 2 {return}
        if superview == nil {return}
        
        autoLayoutEnabled = true
        
        let positionChars = position.lowercased().characters
        let verticalPosition = positionChars[position.startIndex]
        let horizontalPosition = positionChars[position.index(after: position.startIndex)]
        
        switch verticalPosition {
        case "t": alignInSuperview(.top, inset: insetv, priority: priority)
        case "c": alignInSuperview(.centerY, inset: insetv, priority: priority)
        case "b": alignInSuperview(.bottom, inset: insetv, priority: priority)
        case "x": stretchToSuperview(priority: priority, h: false, v: true, inset: Int(insetv))
        default: break
        }
        
        switch horizontalPosition {
        case "l": alignInSuperview(.leading, inset: inseth, priority: priority)
        case "c": alignInSuperview(.centerX, inset: inseth, priority: priority)
        case "r": alignInSuperview(.trailing, inset: inseth, priority: priority)
        case "x": stretchToSuperview(priority: priority, h: true, v: false, inset: Int(inseth))
        default: break
        }
    }
}

#if !os(OSX)
    extension UIViewController {
        public func place(_ view: View, _ position: String, inseth: CGFloat = 0.0, insetv: CGFloat = 0.0, priority: LayoutPriority = 1000) {
            self.view.addSubview(view)
            view.placeInSuperview(position, inseth: inseth, insetv: insetv, priority: priority)
        }
    }
#endif