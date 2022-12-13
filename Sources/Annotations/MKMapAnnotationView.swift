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

struct SizePreferenceKey: PreferenceKey {
  static var defaultValue: CGSize = .zero
  static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

extension View {
  func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
    background(
      GeometryReader { geometryProxy in
        Color.clear
          .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
      }
    )
    .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
  }
}

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
  
  public func configureConstraints() {
    self.translatesAutoresizingMaskIntoConstraints = false
//    if let controller {
//      let size = controller.view.sizeThatFits(.init(width: CGFloat.infinity, height: CGFloat.infinity))
//      let constraints = [
//        controller.view.centerXAnchor.constraint(equalTo: self.centerXAnchor),
//        controller.view.centerYAnchor.constraint(equalto),
//        self.widthAnchor.constraint(equalToConstant: size.width),
//        self.heightAnchor.constraint(equalToConstant: size.height)
//      ]
//      NSLayoutConstraint.activate(constraints)
//    }
    
  }
  
//  public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//    return nil
//  }
}

public class MKMapAnnotationViewWithLabel<Content: View, Label: View>: MKAnnotationView {
  
  // MARK: Stored Properties
  
  public var controller: NativeHostingController<Content>?
  public var label: NativeHostingController<Label>?
  
  // MARK: Methods
  
  func setup(for mapAnnotation: ViewMapAnnotation<Content>) {
    annotation = mapAnnotation.annotation
    controller?.view.removeFromSuperview()
    var controller = NativeHostingController(rootView: mapAnnotation.content, ignoreSafeArea: true)
    addSubview(controller.view)
    //      bounds.size = controller.view.sizeThatFits(.init(width: CGFloat.infinity, height: CGFloat.infinity))
    self.controller = controller
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
  
  public func configureConstraints() {
    self.translatesAutoresizingMaskIntoConstraints = false
    //    if let controller {
    //      let size = controller.view.sizeThatFits(.init(width: CGFloat.infinity, height: CGFloat.infinity))
    //      let constraints = [
    //        controller.view.centerXAnchor.constraint(equalTo: self.centerXAnchor),
    //        controller.view.centerYAnchor.constraint(equalto),
    //        self.widthAnchor.constraint(equalToConstant: size.width),
    //        self.heightAnchor.constraint(equalToConstant: size.height)
    //      ]
    //      NSLayoutConstraint.activate(constraints)
    //    }
    
  }
  
  //  public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
  //    return nil
  //  }
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
