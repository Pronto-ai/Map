//
//  ViewMapAnnotation.swift
//  Map
//
//  Created by Paul Kraft on 23.04.22.
//

#if !os(watchOS)

import MapKit
import SwiftUI

public struct ViewMapAnnotation<Content: View, Label: View>: MapAnnotation {

    // MARK: Nested Types

    private class Annotation: NSObject, MKAnnotation {

        // MARK: Stored Properties

        let coordinate: CLLocationCoordinate2D
        let title: String?
        let subtitle: String?

        // MARK: Initialization

        init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?) {
            self.coordinate = coordinate
            self.title = title
            self.subtitle = subtitle
        }

    }

    // MARK: Static Functions

    public static func registerView(on mapView: MKMapView) {
        mapView.register(MKMapAnnotationView<Content, Label>.self, forAnnotationViewWithReuseIdentifier: reuseIdentifier)
    }

    // MARK: Stored Properties

    public let annotation: MKAnnotation
    public let onTap: (() -> Void)?
    public let content: Content
    public let label: Label

    // MARK: Initialization

    public init(
        coordinate: CLLocationCoordinate2D,
        title: String? = nil,
        subtitle: String? = nil,
        onTap: @escaping () -> Void,
        @ViewBuilder label: () -> Label = { EmptyView() },
        @ViewBuilder content: () -> Content
    ) {
        self.annotation = Annotation(coordinate: coordinate, title: title, subtitle: subtitle)
        self.onTap = onTap
        self.label = label()
        self.content = content()
    }

    public init(
        annotation: MKAnnotation,
        @ViewBuilder label: () -> Label = { EmptyView() },
        @ViewBuilder content: () -> Content
    ) {
        self.annotation = annotation
        self.label = label()
        self.content = content()
        self.onTap = { }
    }

    // MARK: Methods

    public func view<AnnotationItems: RandomAccessCollection, OverlayItems: RandomAccessCollection>(for mapView: MKMapView, coordinator: Map<AnnotationItems, OverlayItems>.Coordinator) -> MKAnnotationView? {
        let view = mapView.dequeueReusableAnnotationView(
            withIdentifier: Self.reuseIdentifier,
            for: annotation
        ) as? MKMapAnnotationView<Content, Label>

        view?.setup(for: self)
        return view
    }

}

#endif
