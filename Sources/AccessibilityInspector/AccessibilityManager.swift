//
//  AccessibilityManager.swift
//  GroupMe
//
//  Created by Divya on 18/08/23.
//  Copyright © 2023 Microsoft. All rights reserved.
//
#if DEBUG || STAGING || INTERNALQA

    import Foundation
    import UIKit

    public class AccessibilityManager: UIResponder {
       public static let shared = AccessibilityManager()
        var viewArray = [UIView]()
        var currentTouchedElements = [UIView]()
        var overlayView: UIView?
        var selectedView: UIView?
        var window: UIWindow?
        var navigationViewController: ATNavigationController?
        var inspectorContainerView: UBKAccessibilityInspectorContainerView?

        override private init() {
            super.init()
            // Configure the navigation of the inspector.
            let elementsViewController = ATElementsTableViewController()
            self.navigationViewController = ATNavigationController(uiElementsViewController: elementsViewController)
            guard let navigationViewController else {
                return
            }
            self.navigationViewController = navigationViewController
            self.inspectorContainerView = UBKAccessibilityInspectorContainerView(navigationViewController: navigationViewController)
            self.navigationViewController?.isShowingInspector = true
        }

       public func findAllUiElements(window: UIWindow) {
            self.viewArray.removeAll()
            window.isUserInteractionEnabled = false
            window.windowLevel = .statusBar + 1 // Set the window level appropriately
            window.makeKeyAndVisible()

            for viewTmp in window.subviews where self.canAdd(view: viewTmp) {
                self.viewArray.append(viewTmp)
                self.getChildUIElements(parentView: viewTmp)
            }

            window.isUserInteractionEnabled = true
            self.window = window
            guard let inspectorContainerView else {
                return
            }

            window.addSubview(inspectorContainerView)
            self.inspectorContainerView?.setConstarintsAfterViewSetup()
            self.inspectorContainerView?.leadingAnchor.constraint(equalTo: window.leadingAnchor).isActive = true
            self.inspectorContainerView?.trailingAnchor.constraint(equalTo: window.trailingAnchor).isActive = true

            window.setNeedsLayout()
            window.layoutIfNeeded()

            self.showInspector(false)

            let classesToRemove = ["UITransitionView", "UIDropShadowView", "UILayoutContainerView", "UINavigationTransitionView", "UIViewControllerWrapperView"]

            self.viewArray = self.viewArray.filter { view in
                let className = String(describing: type(of: view))
                return !classesToRemove.contains(className)
            }
            self.navigationViewController?.updateAllElements(self.viewArray)
            self.addOverLayView()
        }

        func addOverLayView() {
            guard let window else { return }
            self.overlayView = UIView()
            self.overlayView?.backgroundColor = .clear
            self.overlayView?.frame = window.bounds
            guard let overlayView else { return }

            window.addSubview(self.overlayView ?? UIView())
            window.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[overlay]|", metrics: nil, views: ["overlay": overlayView]) +
                NSLayoutConstraint.constraints(withVisualFormat: "V:|[overlay]|", metrics: nil, views: ["overlay": overlayView]))
            window.bringSubviewToFront(overlayView)
            window.bringSubviewToFront(self.inspectorContainerView ?? UIView())
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.onTap(sender:)))
            self.overlayView?.addGestureRecognizer(tap)
        }

        func deselectView() {
            self.overlayView?.removeFromSuperview()
            self.overlayView = nil
            self.selectedView?.hideLayerBox()
        }

        func enableDetectionWindow() { }

        func canAdd(view: UIView) -> Bool {
            // Don't interact with Apple private classes
            if !String(describing: type(of: view)).starts(with: "_") {
                return true
            }
            return false
        }

        func showInspector(_ popViewController: Bool) {
            if popViewController {
                self.navigationViewController?.popViewController(animated: false)
            }
            self.navigationViewController?.isShowingInspector = true
        }

        func getChildUIElements(parentView: UIView) {
            for viewTmp in parentView.subviews where self.canAdd(view: viewTmp) {
                self.viewArray.append(viewTmp)
                self.getChildUIElements(parentView: viewTmp)
            }
        }

        func selectElementAtPoint(_ point: CGPoint, excludeCurrentSelection _: Bool) {
            guard let window else { return }

            self.overlayView?.isHidden = true
            defer { self.overlayView?.isHidden = false }

            guard let hitView = self.hitTest(point: point, in: window, exclude: nil).last else { return }
            if self.selectedView != nil {
                self.selectedView?.hideLayerBox()
            }
            self.selectedView = hitView
            hitView.showLayerBoxWithColour(.red)
            self.navigationViewController?.selectElement(hitView)
        }

        func hitTest(point: CGPoint, in view: UIView, exclude : UIView? = nil) -> [UIView] {
            var subviewsAtPoint = [UIView]()
            for subview in view.subviews {
                let isHidden = subview.isHidden || subview.alpha < 0.01 || view == exclude
                if isHidden {
                    continue
                }

                let subviewContainsPoint = subview.frame.contains(point)
                if subviewContainsPoint {
                    subviewsAtPoint.append(subview)
                }

                // If this view doesn't clip to its bounds, we need to check its subviews even if it
                // Doesn't contain the selection point. They may be visible and contain the selection point.
                if subviewContainsPoint || !subview.clipsToBounds {
                    let pointInSubview = view.convert(point, to: subview)
                    subviewsAtPoint.append(contentsOf: self.hitTest(point: pointInSubview, in: subview))
                }
            }
            return subviewsAtPoint
        }

        @objc
        func onTap(sender: UITapGestureRecognizer) {
            guard self.window != nil, self.overlayView != nil else { return }

            let pointInWindow = sender.location(in: self.overlayView)
            self.selectElementAtPoint(pointInWindow, excludeCurrentSelection: true)
        }
    }

    extension UIView {
        func showLayerBoxWithColour(_ colour: UIColor) {
            var hasShapeLayer = false

            for subLayer in layer.sublayers ?? [] where subLayer is ATShapeLayer {
                hasShapeLayer = true
                break
            }

            if !hasShapeLayer {
                let enlargedSize = CGSize(width: bounds.size.width - 2, height: bounds.size.height - 2)
                let shapeLayer = ATShapeLayer(size: enlargedSize, colour: colour)
                layer.addSublayer(shapeLayer)
            }
        }

        func hideLayerBox() {
            var removeLayers = [CALayer]()

            for subLayer in layer.sublayers ?? [] where subLayer is ATShapeLayer {
                removeLayers.append(subLayer)
            }

            for layer in removeLayers {
                layer.removeFromSuperlayer()
            }
        }
    }
#endif
