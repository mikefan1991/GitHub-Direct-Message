//
//  ChatInputBar.swift
//  GitHubDM
//
//  Created by Yingwei Fan on 9/12/21.
//

import UIKit

protocol ChatInputBarDelegate: NSObjectProtocol {
  func chatInputBar(_ inputBar: ChatInputBar, willSend message: String)
}

class ChatInputBar: UIView {

  private let stackView = UIStackView()

  private let textView = UITextView()

  private let sendButton = UIButton()

  private let textViewHeight: CGFloat = 40.0

  private let padding: CGFloat = 12.0

  weak var delegate: ChatInputBarDelegate?

  let totalHeight: CGFloat

  override init(frame: CGRect) {
    totalHeight = textViewHeight + padding * 2
    super.init(frame: frame)

    configureSubviews()
    configureConstraints()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func configureSubviews() {
    backgroundColor = UIColor(red: 240.0/255, green: 239.0/255, blue: 244.0/255, alpha: 1.0)

    textView.layer.borderWidth = 1.0
    textView.layer.borderColor = UIColor.lightGray.cgColor
    textView.layer.cornerRadius = textViewHeight / 2
    textView.textContainerInset = UIEdgeInsets(top: 10.0, left: 16.0, bottom: 10.0, right: 16.0)
    textView.font = UIFont.systemFont(ofSize: 15.0)
    textView.showsVerticalScrollIndicator = false
    stackView.addArrangedSubview(textView)

    sendButton.setTitle("Send", for: .normal)
    sendButton.setTitleColor(.systemBlue, for: .normal)
    sendButton.setTitleColor(.lightGray, for: .highlighted)
    sendButton.addTarget(self, action: #selector(didTapSendButton), for: .touchUpInside)
    stackView.addArrangedSubview(sendButton)

    stackView.axis = .horizontal
    addSubview(stackView)
  }

  private func configureConstraints() {
    stackView.translatesAutoresizingMaskIntoConstraints = false

    let buttonWidth = sendButton.sizeThatFits(bounds.size).width

    let constraints = [
      stackView.topAnchor.constraint(equalTo: topAnchor, constant: padding),
      stackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: padding),
      stackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -padding),
      stackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -padding),

      sendButton.widthAnchor.constraint(equalToConstant: buttonWidth + padding * 2)
    ]
    NSLayoutConstraint.activate(constraints)
  }

  @objc private func didTapSendButton() {
    guard let text = textView.text, text.count > 0 else {
      return
    }
    textView.text = ""
    delegate?.chatInputBar(self, willSend: text)
  }

}
