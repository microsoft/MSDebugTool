//
//  AccessibilityInspectorContainerView.swift
//  GroupMe
//
//  Created by Divya on 11/09/23.
//  Copyright © 2023 Microsoft. All rights reserved.
//


    import Foundation
    import UIKit

    class UBKAccessibilityInspectorContainerView: UIView {
        private var navigationViewController: ATNavigationController!
        private var panGesture: UIPanGestureRecognizer!
        private var topConstraint: NSLayoutConstraint!
        private var originalCenterY: CGFloat = 0
        var hideButton: UIButton?
        var containerViewHeightConstraint: NSLayoutConstraint?
        var currentContainerHeight: CGFloat = 300
        let maximumContainerHeight: CGFloat = UIScreen.main.bounds.height - 64
        let defaultHeight: CGFloat = 300
        let dismissibleHeight: CGFloat = 200

        var containerViewBottomConstraint: NSLayoutConstraint?

        init(navigationViewController: ATNavigationController) {
            super.init(frame: .zero)
            self.navigationViewController = navigationViewController

            self.configureAppearance()

            let containerView = UIView()
            containerView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(containerView)

            containerView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
            containerView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
            containerView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

            containerView.addSubview(navigationViewController.view)
            navigationViewController.view.translatesAutoresizingMaskIntoConstraints = false
            navigationViewController.view.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
            navigationViewController.view.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
            navigationViewController.view.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10).isActive = true
            navigationViewController.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true

            self.panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan))
            addGestureRecognizer(self.panGesture)

            self.hideButton = UIButton(type: .custom)

            self.hideButton?.setImage(UIImage(named: ""), for: .normal)
            self.hideButton?.tintColor = UIColor.lightGray
            self.hideButton?.addTarget(self, action: #selector(self.hideInspector), for: .touchUpInside)
            self.hideButton?.accessibilityLabel = "Hide inspector"
            self.hideButton?.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(self.hideButton ?? UIButton(type: .custom))

            self.hideButton?.widthAnchor.constraint(equalToConstant: 44).isActive = true
            self.hideButton?.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
            self.hideButton?.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -5).isActive = true
            self.hideButton?.bottomAnchor.constraint(equalTo: navigationViewController.navigationBar.bottomAnchor, constant: -5).isActive = true
        }

        func setConstarintsAfterViewSetup() {
            guard let superview = self.superview else {
                return
            }

            self.containerViewHeightConstraint = self.heightAnchor.constraint(equalToConstant: 300)
            self.containerViewBottomConstraint = self.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: 0)
            self.containerViewHeightConstraint?.isActive = true
            self.containerViewBottomConstraint?.isActive = true
            self.translatesAutoresizingMaskIntoConstraints = false
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
        }

        @objc
        func handlePan(gesture: UIPanGestureRecognizer) {
            let translation = gesture.translation(in: self)
            let isDraggingDown = translation.y > 0
            switch gesture.state {
            case .began:
                self.currentContainerHeight = self.containerViewHeightConstraint?.constant ?? 0
            case .changed:
                let newHeight = self.currentContainerHeight - translation.y
                if newHeight >= 0 {
                    self.containerViewHeightConstraint?.constant = newHeight
                    self.layoutIfNeeded()
                }
            default:
                break
            }
        }

        @objc
        func hideInspector() {
            AccessibilityManager.shared.deselectView()
            if let containerViewHeightConstraint = self.containerViewHeightConstraint {
                self.removeConstraint(containerViewHeightConstraint)
            }
            if let containerViewBottomConstraint = self.containerViewBottomConstraint {
                self.removeConstraint(containerViewBottomConstraint)
            }
            self.navigationViewController.elementsViewController?.selectedElement?.hideLayerBox()
            self.navigationViewController.elementsViewController?.isFilteringWarnings = false
            self.navigationViewController.elementsViewController?.showAndHideWarnings()
            self.removeFromSuperview()
        }

        private func configureAppearance() {
            backgroundColor = .white
            layer.shadowOffset = CGSize(width: 0, height: 0)
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOpacity = 0.5
            layer.shadowRadius = 2.0
        }
    }
