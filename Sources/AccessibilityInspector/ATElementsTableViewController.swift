//
//  ATElementsTableViewController.swift
//  GroupMe
//
//  Created by Divya on 11/09/23.
//  Copyright © 2023 Microsoft. All rights reserved.
//

    import Foundation
    import UIKit

    class ATElementsTableViewController: UIViewController {
        let toolbar = UIToolbar()
        var elementsArray: [UIView] = [] {
            didSet {
                self.configureFilteredArray()
                self.tableView?.reloadData()
            }
        }

        var selectedUIElementIndex: IndexPath? {
            didSet {
                if let oldIndex = oldValue {
                    if let oldElement = getUIElementForIndex(oldIndex.row) as? UIView {
                        oldElement.hideLayerBox()
                    }
                }
            }
        }

        var isFilteringWarnings = false
        var previousSelectedButton: UIButton?
        var selectedElement: UIView?
        private var showWarnings: UIBarButtonItem?
        var filteredList = [UIView]()
        private var tableView: UITableView?

        func configureFilteredArray() {
            self.filteredList.removeAll()
            let filteredElements = self.elementsArray.filter { element in
                if element is UILabel || element is UIImageView {
                    return false
                }
                var skipElement = false
                if let superView = element.superview {
                    if superView.accessibilityLabel != nil ||
                        superView.accessibilityHint != nil ||
                        superView.accessibilityTraits != UIAccessibilityTraits.none
                    {
                        skipElement = true
                    }
                    if let superSuperView = superView.superview {
                        if superSuperView.accessibilityLabel != nil ||
                            superSuperView.accessibilityHint != nil ||
                            superSuperView.accessibilityTraits != UIAccessibilityTraits.none
                        {
                            skipElement = true
                        }
                    }
                }

                return !skipElement && element.accessibilityLabel == nil && element.accessibilityHint == nil && element.accessibilityTraits == UIAccessibilityTraits.none
            }
            self.filteredList.append(contentsOf: filteredElements)
        }

        func setupViews() {
            showWarnings = UIBarButtonItem(title: "Show Warnings: OFF", style: .plain, target: self, action: #selector(self.toolbarButtonAction(_:)))
            if let showWarnings = showWarnings {
                self.toolbar.items = [showWarnings]
            }
            self.toolbar.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(self.toolbar)
        }

        func setupConstraints() {
            guard let tableView else { return }
            NSLayoutConstraint.activate([
                tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
                tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
                tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                self.toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                self.toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                self.toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            ])
        }

        func getUIElementForIndex(_ index: Int) -> UIView? {
            var tmpView: UIView?
            tmpView = self.elementsArray[index]

            if self.isFilteringWarnings {
                tmpView = self.filteredList[index]
            }

            return tmpView
        }

        override func viewDidLoad() {
            super.viewDidLoad()
            self.title = "All UI Elements"
            let tableView = UITableView(frame: .zero, style: .plain)
            tableView.backgroundColor = .clear
            tableView.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(tableView)
            self.tableView = tableView
            self.tableView?.delegate = self
            self.tableView?.dataSource = self
            self.tableView?.rowHeight = UITableView.automaticDimension
            self.tableView?.estimatedRowHeight = 88
            self.tableView?.estimatedRowHeight = 44.0
            self.tableView?.rowHeight = UITableView.automaticDimension
            self.tableView?.register(ATElementsTableViewCell.self, forCellReuseIdentifier: "ATElementsTableViewCell")
            self.setupViews()
            self.setupConstraints()
        }

        @IBAction
        func toolbarButtonAction(_: Any) {
            self.isFilteringWarnings = !self.isFilteringWarnings
            self.showWarnings?.title = self.isFilteringWarnings ? "Show Warnings: ON" : "Show Warnings: OFF"
            self.tableView?.reloadData()
            self.showAndHideWarnings()
        }

        func showAndHideWarnings() {
            self.filteredList.map {
                if self.isFilteringWarnings {
                    $0.showLayerBoxWithColour(.orange)
                } else {
                    $0.hideLayerBox()
                }
            }
        }

        func refreshTableData() {
            self.tableView?.reloadData()
        }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            self.tableView?.reloadData()
        }
    }

    extension ATElementsTableViewController: UITableViewDelegate, UITableViewDataSource {
        func numberOfSections(in _: UITableView) -> Int {
            1
        }

        func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
            UITableView.automaticDimension
        }

        func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
            if self.isFilteringWarnings {
                return self.filteredList.count
            }
            return self.elementsArray.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ATElementsTableViewCell", for: indexPath) as? ATElementsTableViewCell else {
                return UITableViewCell()
            }
            cell.elementView = self.getUIElementForIndex(indexPath.row)
            cell.selectionStyle = .default
            cell.isAccessibilityElement = true
            return cell
        }

        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            selectedUIElementIndex = indexPath
            if let selectedUIElementIndex = selectedUIElementIndex {
                self.getUIElementForIndex(selectedUIElementIndex.row)?.hideLayerBox()
            }
            self.selectedElement = self.getUIElementForIndex(indexPath.row)
            self.selectedElement?.showLayerBoxWithColour(UIColor.red)
            if let navController = self.navigationController as? ATNavigationController {
                navController.selectElement(self.selectedElement ?? UIView())
            }
        }

        func tableView(_: UITableView, titleForHeaderInSection _: Int) -> String? {
            if !self.filteredList.isEmpty {
                return "\(self.filteredList.count) Accessibility warnings"
            } else {
                return "No Accessibility warnings"
            }
        }
    }
