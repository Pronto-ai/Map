//
//  MKMapAnnotationView.swift
//  Map
//
//  Created by Paul Kraft on 23.04.22.
//

#if !os(watchOS)

import MapKit
import SwiftUI

class MKMapAnnotationView<Content: View>: MKAnnotationView {

    // MARK: Stored Properties

    private var controller: NativeHostingController<Content>?

    // MARK: Computed Properties

    override var intrinsicContentSize: CGSize {
        controller?.view.intrinsicContentSize
            ?? .init(width: NativeView.noIntrinsicMetric, height: NativeView.noIntrinsicMetric)
    }

    private var intrinsicContentFrame: CGRect {
        let size = intrinsicContentSize
        return CGRect(origin: .init(x: -size.width / 2, y: -size.height / 2), size: size)
    }

    // MARK: Methods

    func setup(for mapAnnotation: ViewMapAnnotation<Content>) {
        annotation = mapAnnotation.annotation

        #if canImport(UIKit)
        backgroundColor = .clear
        #endif

        let controller = NativeHostingController(rootView: mapAnnotation.content)

        #if canImport(UIKit)
        controller.view.backgroundColor = .clear
        #endif

        controller.view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(controller.view)
        NSLayoutConstraint.activate([
            controller.view.centerXAnchor.constraint(equalTo: centerXAnchor),
            controller.view.centerYAnchor.constraint(equalTo: centerYAnchor),
            controller.view.widthAnchor.constraint(equalTo: widthAnchor),
            controller.view.heightAnchor.constraint(equalTo: heightAnchor),
        ])

        self.controller = controller
        self.invalidateIntrinsicContentSize()
    }

    // MARK: Overrides

    override func prepareForReuse() {
        super.prepareForReuse()

        #if canImport(UIKit)
        controller?.willMove(toParent: nil)
        #endif
        controller?.view.removeFromSuperview()
        controller?.removeFromParent()
        controller = nil
    }

    override func layout() {
        bounds = intrinsicContentFrame

        super.layout()
    }

    #if canImport(UIKit)

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        intrinsicContentFrame.contains(point)
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        controller?.view.frame = intrinsicContentFrame
        guard let view = controller?.view.hitTest(point, with: event) ?? super.hitTest(point, with: event) else {
            return nil
        }
        superview?.bringSubviewToFront(self)
        return view
    }

    #elseif canImport(AppKit)

    override func hitTest(_ point: NSPoint) -> NSView? {
        controller?.view.frame = intrinsicContentFrame
        guard let view = controller?.view.hitTest(point) ?? super.hitTest(point) else {
            return nil
        }
        return view
    }

    #endif

}

#endif
