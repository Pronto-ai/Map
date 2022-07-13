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

    private var controller: NativeHostingController<AnyView>?

    // MARK: Methods

    func setup(for mapAnnotation: ViewMapAnnotation<Content>) {
        annotation = mapAnnotation.annotation

        let controller = NativeHostingController(rootView: AnyView(mapAnnotation.content))
        addSubview(controller.view)
        bounds.size = controller.preferredContentSize
        self.controller = controller
    }
  
    func setup(for mapAnnotation: MovableViewMapAnnotation<Content>) {
        print("setup movable")
        annotation = mapAnnotation.annotation
        let view = AnyView(mapAnnotation.content.rotationEffect(Angle(degrees: mapAnnotation.annotation.heading)))
        let controller = NativeHostingController(rootView: view)
        addSubview(controller.view)
        bounds.size = controller.preferredContentSize
        self.controller = controller
    }

    // MARK: Overrides

    override func layoutSubviews() {
        super.layoutSubviews()

        if let controller = controller {
            bounds.size = controller.preferredContentSize
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        #if canImport(UIKit)
        controller?.willMove(toParent: nil)
        #endif
        controller?.view.removeFromSuperview()
        controller?.removeFromParent()
        controller = nil
    }
}

#endif
