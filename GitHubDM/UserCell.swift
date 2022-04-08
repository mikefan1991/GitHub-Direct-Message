//
//  UserCell.swift
//  GitHubDM
//
//  Created by Yingwei Fan on 9/12/21.
//

import UIKit

class UserCell: UITableViewCell {

  static let defaultReuseIdentifier = "UserCell"

  static let imageViewHeight: CGFloat = 44.0

  static let padding: CGFloat = 16.0

  static let separatorInset = UIEdgeInsets(top: 0, left: padding * 2 + imageViewHeight, bottom: 0, right: 0)

  let avatarImageView = UIImageView()

  let nameLabel = UILabel()

  private let imageViewHeight: CGFloat = 44.0

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    configureSubviews()
    configureConstraints()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func prepareForReuse() {
    super.prepareForReuse()

    nameLabel.text = nil
    avatarImageView.image = nil
  }

  private func configureSubviews() {
    accessoryType = .disclosureIndicator

    avatarImageView.contentMode = .scaleAspectFill
    contentView.addSubview(avatarImageView)

    nameLabel.numberOfLines = 1
    contentView.addSubview(nameLabel)
  }

  private func configureConstraints() {
    avatarImageView.translatesAutoresizingMaskIntoConstraints = false
    nameLabel.translatesAutoresizingMaskIntoConstraints = false

    let constraints = [
      avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Self.padding),
      avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Self.padding),
      avatarImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -Self.padding),
      avatarImageView.heightAnchor.constraint(equalToConstant: imageViewHeight),
      avatarImageView.widthAnchor.constraint(equalTo: avatarImageView.heightAnchor),

      nameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: Self.padding),
      nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Self.padding),
      nameLabel.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor)
    ]
    NSLayoutConstraint.activate(constraints)
  }

}
