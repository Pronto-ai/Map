//
//  MKMapAnnotationView.swift
//  Map
//
//  Created by Paul Kraft on 23.04.22.
//

#if !os(watchOS)

import MapKit
import SwiftUI
import UIKit

public class MKMapAnnotationView<Content: View>: MKAnnotationView {

    // MARK: Stored Properties

    public var controller: NativeHostingController<Content>?

    // MARK: Methods

    func setup(for mapAnnotation: ViewMapAnnotation<Content>) {
        annotation = mapAnnotation.annotation
        controller?.view.removeFromSuperview()
        var controller = NativeHostingController(rootView: mapAnnotation.content, ignoreSafeArea: true)
        addSubview(controller.view)
//      bounds.size = controller.view.sizeThatFits(.init(width: CGFloat.infinity, height: CGFloat.infinity))
      self.controller = controller
      self.displayPriority = .defaultHigh
    }
  
  @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
    print()
  }

    // MARK: Overrides
  
    #if os(macOS)
    override func layout() {
        super.layout()
        
        if let controller = controller {
//            bounds.size = controller.preferredContentSize
//          bounds.size = controller.view.sizeThatFits(.init(width: CGFloat.infinity, height: CGFloat.infinity))
        }
    }
    #elseif os(iOS)
    public override func layoutSubviews() {
        super.layoutSubviews()

        if let controller = controller {
//            bounds.size = controller.view.sizeThatFits(.init(width: CGFloat.infinity, height: CGFloat.infinity))
          
//          controller.view.layoutSubviews()
//          print("size:", controller.view.subviews.first?.frame.size ?? .zero)
//          bounds.size = controller.view.subviews.first?.frame.size ?? .zero
        }
    }
    #endif

    public override func prepareForReuse() {
        super.prepareForReuse()

        #if canImport(UIKit)
        controller?.willMove(toParent: nil)
        #endif
        controller?.view.removeFromSuperview()
        controller?.removeFromParent()
        controller = nil
    }
}

public class MKMapAnnotationViewWithLabel<Content: View, Label: View>: MKAnnotationView {
  
  // MARK: Stored Properties
  
  public var controller: NativeHostingController<Content>?
  public var label: NativeHostingController<Label>?
  public var onTap: (() -> Void)?
  
  // MARK: Methods
  public override func prepareForReuse() {
    super.prepareForReuse()
    
#if canImport(UIKit)
    controller?.willMove(toParent: nil)
#endif
    controller?.view.removeFromSuperview()
    controller?.removeFromParent()
    controller = nil
    
#if canImport(UIKit)
    label?.willMove(toParent: nil)
#endif
    label?.view.removeFromSuperview()
    label?.removeFromParent()
    label = nil
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
    return self.controller?.view.sizeThatFits(.init(width: CGFloat.infinity, height: CGFloat.infinity)) ?? .zero
  }
}



extension UIHostingController {
  /// This convenience init uses dynamic subclassing to disable safe area behaviour for a UIHostingController
  /// This solves bugs with embedded SwiftUI views having redundant insets
  /// More on this here: https://defagos.github.io/swiftui_collection_part3/
  /// - Parameters:
  ///   - rootView: The content View
  ///   - ignoreSafeArea: Disables the safe area insets if true
  convenience public init(rootView: Content, ignoreSafeArea: Bool) {
    self.init(rootView: rootView)
    
    if ignoreSafeArea {
      disableSafeArea()
    }
  }
  
  func disableSafeArea() {
    guard let viewClass = object_getClass(view) else { return }
    
    let viewSubclassName = String(cString: class_getName(viewClass)).appending("_IgnoreSafeArea")
    if let viewSubclass = NSClassFromString(viewSubclassName) {
      object_setClass(view, viewSubclass)
    }
    else {
      guard let viewClassNameUtf8 = (viewSubclassName as NSString).utf8String else { return }
      guard let viewSubclass = objc_allocateClassPair(viewClass, viewClassNameUtf8, 0) else { return }
      
      if let method = class_getInstanceMethod(UIView.self, #selector(getter: UIView.safeAreaInsets)) {
        let safeAreaInsets: @convention(block) (AnyObject) -> UIEdgeInsets = { _ in
          return .zero
        }
        class_addMethod(viewSubclass, #selector(getter: UIView.safeAreaInsets),
                        imp_implementationWithBlock(safeAreaInsets),
                        method_getTypeEncoding(method))
      }
      
      objc_registerClassPair(viewSubclass)
      object_setClass(view, viewSubclass)
    }
  }
}

#endif
