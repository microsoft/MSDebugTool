//
//  ATElementsTableViewCell.swift
//  GroupMe
//
//  Created by Divya on 11/09/23.
//  Copyright © 2023 Microsoft. All rights reserved.
//

    import Foundation
    import UIKit

    class ATElementsTableViewCell: UITableViewCell {
        let classImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.image = UIImage(named: "")
            return imageView
        }()

        let cellTitleLabel: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = UIFont.preferredFont(forTextStyle: .title3)
            label.numberOfLines = 0
            label.lineBreakMode = .byWordWrapping
            return label
        }()

        let chevronImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.image = UIImage(named: "")
            return imageView
        }()

        var elementView: UIView? {
            didSet {
                self.configureCellAppearance()
            }
        }

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)

            contentView.addSubview(self.classImageView)
            contentView.addSubview(self.cellTitleLabel)
            contentView.addSubview(self.chevronImageView)

            NSLayoutConstraint.activate([
                self.classImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                self.classImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                self.classImageView.widthAnchor.constraint(equalToConstant: 25),
                self.classImageView.heightAnchor.constraint(equalToConstant: 25),
                self.cellTitleLabel.leadingAnchor.constraint(equalTo: self.classImageView.trailingAnchor, constant: 10),
                self.cellTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.chevronImageView.leadingAnchor, constant: -10),
                self.cellTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
                self.cellTitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
                self.chevronImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
                self.chevronImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                self.chevronImageView.widthAnchor.constraint(equalToConstant: 15),
                self.chevronImageView.heightAnchor.constraint(equalToConstant: 15),
            ])
            self.updateContentForTheme()
        }

        func updateContentForTheme() {
            if #available(iOS 13.0, *) {
                if self.traitCollection.userInterfaceStyle == .dark {
                    self.cellTitleLabel.textColor = UIColor.white
                    self.classImageView.tintColor = UIColor.white
                    self.chevronImageView.tintColor = UIColor.white
                } else {
                    self.cellTitleLabel.textColor = UIColor.darkText
                    self.classImageView.tintColor = UIColor.darkGray
                    self.chevronImageView.tintColor = UIColor.darkGray
                }
            }
        }

        func configureCellAppearance() {
            guard let elementView else { return }
            let viewHierarchyString = self.generateViewHierarchyString(view: elementView)
            self.cellTitleLabel.text = viewHierarchyString
        }

        func generateViewHierarchyString(view: UIView) -> String {
            var hierarchyString = String(describing: type(of: view))
            if let superView = view.superview {
                hierarchyString = "\(String(describing: type(of: superView))) -> " + hierarchyString
                if let superSuperView = superView.superview {
                    hierarchyString = "\(String(describing: type(of: superSuperView))) -> " + hierarchyString
                }
            }
            return hierarchyString
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
