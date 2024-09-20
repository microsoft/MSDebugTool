//
//  ATNavigationController.swift
//  GroupMe
//
//  Created by Divya on 11/09/23.
//  Copyright © 2023 Microsoft. All rights reserved.
//

    import Foundation
    import UIKit

    class ATNavigationController: UINavigationController {
        var elementsViewController: ATElementsTableViewController?
        var inspectorViewController: AccessibilityInfoViewController?
        var isShowingInspector = false
        var shadowLayer: CALayer?

        init(uiElementsViewController rootViewController: ATElementsTableViewController) {
            super.init(rootViewController: rootViewController)

            navigationBar.isTranslucent = false
            self.elementsViewController = rootViewController
            self.inspectorViewController = AccessibilityInfoViewController()
        }

        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }

        func updateAllElements(_ elementsArray: [UIView]) {
            self.elementsViewController?.elementsArray = elementsArray
            self.elementsViewController?.refreshTableData()
        }

        func selectElement(_ selectedElement: UIView) {
            self.elementsViewController?.selectedElement = selectedElement
            self.inspectorViewController?.element = selectedElement
            guard let inspectorViewController else { return }

            if let childViewController = children.last as? ATElementsTableViewController, isShowingInspector {
                pushViewController(inspectorViewController, animated: true)
            } else {
                popToRootViewController(animated: false)
                pushViewController(inspectorViewController, animated: false)
            }
        }
    }
