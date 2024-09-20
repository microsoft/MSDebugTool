//
//  AccessibilityInfoCell.swift
//  GroupMe
//
//  Created by Divya on 11/10/23.
//  Copyright © 2023 Microsoft. All rights reserved.
//
    import UIKit

    class AccessibilityInfoCell: UICollectionViewCell {
        let headingLabel: UILabel
        let valueLabel: UILabel
        var heading: AccessibilityInfo = .label

        override init(frame: CGRect) {
            self.headingLabel = UILabel(frame: .zero)
            self.valueLabel = UILabel(frame: .zero)

            super.init(frame: frame)

            self.setupSubviews()
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        private func setupSubviews() {
            self.headingLabel.font = UIFont.boldSystemFont(ofSize: 16)
            self.valueLabel.font = UIFont.systemFont(ofSize: 14)
            self.valueLabel.numberOfLines = 0
            self.headingLabel.textAlignment = .left
            self.valueLabel.textAlignment = .right
            self.headingLabel.translatesAutoresizingMaskIntoConstraints = false
            self.valueLabel.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(self.headingLabel)
            contentView.addSubview(self.valueLabel)

            NSLayoutConstraint.activate([
                self.headingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                self.headingLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            ])

            NSLayoutConstraint.activate([
                self.valueLabel.leadingAnchor.constraint(equalTo: self.headingLabel.trailingAnchor, constant: 8),
                self.valueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                self.valueLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            ])
        }

        func update(with element: UIView) {
            self.headingLabel.text = self.heading.rawValue
            let superview = element.superview
            let superSuperView = element.superview?.superview as? UITableViewCell ?? element.superview?.superview as? UICollectionViewCell
            switch self.heading {
            case .label:
                self.valueLabel.text = element.accessibilityLabel ?? superview?.accessibilityLabel ?? superSuperView?.accessibilityLabel ?? "N/A"
            case .hint:
                self.valueLabel.text = element.accessibilityHint ?? superview?.accessibilityHint ?? superSuperView?.accessibilityHint ?? "N/A"
            case .id:
                self.valueLabel.text = element.accessibilityIdentifier ?? "N/A"
            case .isAccessible:
                self.valueLabel.text = element.isAccessibilityElement ? "Yes" : "No"
            }
        }
    }

    extension AccessibilityInfoCell: UICollectionViewDelegate {
        func collectionView(_: UICollectionView, didSelectItemAt _: IndexPath) { }
    }
