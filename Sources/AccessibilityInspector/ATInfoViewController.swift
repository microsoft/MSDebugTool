//
//  ATInfoViewController.swift
//  GroupMe
//
//  Created by Divya on 11/10/23.
//  Copyright © 2023 Microsoft. All rights reserved.
//

    import UIKit

    enum AccessibilityInfo: String {
        case label = "Accessibility Label"
        case hint = "Accessibility Hint"
        case id = "Accessibility ID"
        case isAccessible = "Is Accessible"
    }

    class AccessibilityInfoViewController: UIViewController {
        var collectionView: UICollectionView?
        let allAccessibilityInfo: [AccessibilityInfo] = [.label, .hint, .id, .isAccessible]
        var element: UIView? {
            didSet {
                collectionView?.reloadData()
            }
        }

        override func viewDidLoad() {
            super.viewDidLoad()

            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
            collection.backgroundColor = .clear
            collection.register(AccessibilityInfoCell.self, forCellWithReuseIdentifier: "AccessibilityInfoCell")
            self.collectionView = collection
            view.addSubview(self.collectionView ?? UICollectionView())
            self.setupConstraints()
            self.collectionView?.backgroundColor = .white
            self.collectionView?.dataSource = self
            self.collectionView?.delegate = self
            self.collectionView?.register(AccessibilityInfoCell.self, forCellWithReuseIdentifier: "AccessibilityInfoCell")
        }

        private func setupConstraints() {
            guard let collectionView = self.collectionView else { return }
            collectionView.translatesAutoresizingMaskIntoConstraints = false

            let constraints = [
                collectionView.topAnchor.constraint(equalTo: self.view.topAnchor),
                collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            ]

            NSLayoutConstraint.activate(constraints)
        }
    }

    extension AccessibilityInfoViewController: UICollectionViewDataSource {
        func numberOfSections(in _: UICollectionView) -> Int {
            1
        }

        func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
            self.allAccessibilityInfo.count
        }

        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AccessibilityInfoCell", for: indexPath) as? AccessibilityInfoCell else { return UICollectionViewCell() }
            cell.heading = self.allAccessibilityInfo[indexPath.item]
            guard let element else { return UICollectionViewCell() }
            cell.update(with: element)
            return cell
        }
    }

    extension AccessibilityInfoViewController: UICollectionViewDelegateFlowLayout {
        func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
            CGSize(width: self.view.bounds.width, height: 50.0)
        }

        func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, insetForSectionAt _: Int) -> UIEdgeInsets {
            UIEdgeInsets(top: 2.0, left: 2.0, bottom: 2.0, right: 2.0)
        }

        func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, minimumLineSpacingForSectionAt _: Int) -> CGFloat {
            2.0
        }

        func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, minimumInteritemSpacingForSectionAt _: Int) -> CGFloat {
            2.0
        }
    }
