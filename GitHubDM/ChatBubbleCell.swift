//
//  ChatBubbleCell.swift
//  GitHubDM
//
//  Created by Yingwei Fan on 9/12/21.
//

import UIKit

class ChatBubbleCell: UITableViewCell {

  static let defaultReuseIdentifier = "ChatBubbleCell"

  private let padding: CGFloat = 16.0

  var isSelfBubble = true {
    didSet {
      configureBubble()
    }
  }

  var text: String? {
    didSet {
      bubbleView?.label.text = text
    }
  }

  private var bubbleView: BubbleView?

  private func configureBubble() {
    let bubbleView = BubbleView()
    bubbleView.isSelfBubble = isSelfBubble
    self.bubbleView = bubbleView
    contentView.addSubview(bubbleView)

    bubbleView.translatesAutoresizingMaskIntoConstraints = false
    var constraints = [
      bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
      bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
    ]
    if isSelfBubble {
      constraints.append(bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8.0))
      constraints.append(bubbleView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 40.0))
    } else {
      constraints.append(bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8.0))
      constraints.append(bubbleView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -40.0))
    }
    NSLayoutConstraint.activate(constraints)
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    bubbleView?.removeFromSuperview()
    bubbleView = nil
  }

}

private class BubbleView: UIView {

  private let padding: CGFloat = 16.0

  private let imageView = UIImageView()

  lazy private var leftBubbleImage: UIImage? = {
    guard let image = UIImage(named: "left_bubble") else {
      return nil
    }
    let insets = UIEdgeInsets(top: 17, left: 21, bottom: 17, right: 17)
    return image.resizableImage(withCapInsets: insets, resizingMode: .stretch)
  }()

  lazy private var rightBubbleImage: UIImage? = {
    guard let image = UIImage(named: "right_bubble") else {
      return nil
    }
    let insets = UIEdgeInsets(top: 17, left: 17, bottom: 17, right: 21)
    return image.resizableImage(withCapInsets: insets, resizingMode: .stretch)
  }()

  private var labelLeadingConstraint: NSLayoutConstraint!

  private var labelTrailingConstraint: NSLayoutConstraint!

  let label = UILabel()

  var isSelfBubble = false {
    didSet {
      if isSelfBubble {
        imageView.image = rightBubbleImage
        labelLeadingConstraint.constant = padding
        labelTrailingConstraint.constant = -(padding + 6.0)
      } else {
        imageView.image = leftBubbleImage
        labelLeadingConstraint.constant = padding + 6.0
        labelTrailingConstraint.constant = -padding
      }
    }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)

    configureSubviews()
    configureConstraints()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func configureSubviews() {
    imageView.contentMode = .scaleToFill
    addSubview(imageView)

    label.numberOfLines = 0
    addSubview(label)
  }

  private func configureConstraints() {
    imageView.translatesAutoresizingMaskIntoConstraints = false
    label.translatesAutoresizingMaskIntoConstraints = false

    labelLeadingConstraint = label.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: padding)
    labelTrailingConstraint = label.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -padding)
    let constraints = [
      imageView.topAnchor.constraint(equalTo: topAnchor),
      imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
      imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
      imageView.bottomAnchor.constraint(equalTo: bottomAnchor),

      label.topAnchor.constraint(equalTo: imageView.topAnchor, constant: padding),
      labelLeadingConstraint!,
      labelTrailingConstraint!,
      label.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -padding)
    ]
    NSLayoutConstraint.activate(constraints)
  }

}
