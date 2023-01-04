//
//  MKMapAnnotationView.swift
//  Map
//
//  Created by Paul Kraft on 23.04.22.
//

#if !os(watchOS)

import MapKit
import SwiftUI

public protocol SwiftUIMapAnnotation<Content, Label> {
  associatedtype Content: View
  associatedtype Label: View
  
  var annotation: MKAnnotation { get }
  var content: Content { get }
  var label: Label { get }
  
  var onTap: (() -> Void)? { get }
}

extension ViewMapAnnotation: SwiftUIMapAnnotation { }

open class MKMapAnnotationView<Content: View, Label: View>: MKAnnotationView {
    
    // MARK: Stored Properties
    public var labelController: NativeHostingController<Label>?
    public var controller: NativeHostingController<Content>?
    public var onTap: (() -> Void)?
    
    // MARK: Methods
    
    public func setup<T: SwiftUIMapAnnotation<Content, Label>>(for mapAnnotation: T) {
        annotation = mapAnnotation.annotation
        
        self.prepareForReuse()
        
        let controller = NativeHostingController(rootView: mapAnnotation.content)
        let labelController = NativeHostingController(rootView: mapAnnotation.label)
        
        controller.view.backgroundColor = .clear
        labelController.view.backgroundColor = .clear
        
        addSubview(controller.view)
        addSubview(labelController.view)
        
        self.controller = controller
        self.labelController = labelController
        // This blog post says that setting a display priority helps MapKit avoid layout thrash
        // https://medium.com/@worthbak/clustering-with-mapkit-on-ios-11-part-2-2418a865543b
        self.displayPriority = .defaultHigh
        
        self.onTap = mapAnnotation.onTap
        
        configureConstraints()
        
        bounds.size = self.controller?.view.sizeThatFits(
            .init(
                width: CGFloat.infinity,
                height: CGFloat.infinity
            )
        ) ?? .zero
    }
    
    // MARK: Overrides
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        
        #if canImport(UIKit)
        controller?.willMove(toParent: nil)
        #endif
        controller?.view.removeFromSuperview()
        controller?.removeFromParent()
        controller = nil
        
        #if canImport(UIKit)
        labelController?.willMove(toParent: nil)
        #endif
        labelController?.view.removeFromSuperview()
        labelController?.removeFromParent()
        labelController = nil
    }
    
    // We need to use the hit test because otherwise moving annotations don't trigger
    // `touchesEnded`.
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        switch event?.type {
        case .touches:
            let frameSize = self.frame.size
            if point.x >= 0, point.x <= frameSize.width, point.y >= 0, point.y <= frameSize.height {
                return self
            }
            return nil
        default:
            return nil
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        onTap?()
    }
    
    public override var intrinsicContentSize: CGSize {
        return self.controller?.view.sizeThatFits(
            .init(width: CGFloat.infinity, height: CGFloat.infinity)
        ) ?? CGSize(width: -1, height: -1)
    }
    
    func configureConstraints() {
        guard let content = self.controller?.view, let labelContent = self.labelController?.view else {
            return
        }
        
        content.translatesAutoresizingMaskIntoConstraints = false
        labelContent.translatesAutoresizingMaskIntoConstraints = false
        
        // content layout
        NSLayoutConstraint.activate([
            content.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            content.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        
        // label layout
        NSLayoutConstraint.activate([
            labelContent.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            labelContent.bottomAnchor.constraint(equalTo: content.topAnchor, constant: -10)
        ])
    }
}

#endif
