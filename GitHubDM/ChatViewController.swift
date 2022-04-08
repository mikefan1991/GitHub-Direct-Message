//
//  ChatViewController.swift
//  GitHubDM
//
//  Created by Yingwei Fan on 9/12/21.
//

import UIKit

class ChatViewController: UIViewController {

  private let tableView = UITableView()

  private let inputBar = ChatInputBar()

  private let viewModel: ChatViewModel

  private var inputBarBottomConstraint: NSLayoutConstraint!
  private var inputBarHeightConstraint: NSLayoutConstraint!

  init(user: UserModel, networkService: NetworkService) {
    viewModel = ChatViewModel(user: user, networkService: networkService)
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    configureSubviews()
    configureConstraints()

    NotificationCenter.default.addObserver(self,
                                           selector: #selector(keyboardWillChangeFrame(_:)),
                                           name: UIResponder.keyboardWillChangeFrameNotification,
                                           object: nil)

    NotificationCenter.default.addObserver(self, selector: #selector(didReceiveMessage(_:)), name: NewMessageNotificationName, object: nil)
  }

  override func viewSafeAreaInsetsDidChange() {
    super.viewSafeAreaInsetsDidChange()

    inputBarHeightConstraint.constant = view.safeAreaInsets.bottom + inputBar.totalHeight
  }

  // MARK: - Private

  private func configureSubviews() {
    title = "@" + viewModel.user.login
    navigationItem.largeTitleDisplayMode = .never
    view.backgroundColor = .white

    tableView.dataSource = self
    tableView.allowsSelection = false
    tableView.separatorStyle = .none
    tableView.register(ChatBubbleCell.self, forCellReuseIdentifier: ChatBubbleCell.defaultReuseIdentifier)
    view.addSubview(tableView)

    inputBar.delegate = self
    view.addSubview(inputBar)

    viewModel.messages.bind { [weak self] messages in
      let numberOfRows = self?.tableView.numberOfRows(inSection: 0) ?? 0
      guard !messages.isEmpty else {
        var indexPaths = [IndexPath]()
        for i in 0..<numberOfRows {
          indexPaths.append(IndexPath(row: i, section: 0))
        }
        self?.tableView.deleteRows(at: indexPaths, with: .left)
        return
      }
      if messages.count > numberOfRows {
        var indexPaths = [IndexPath]()
        for i in numberOfRows..<messages.count {
          indexPaths.append(IndexPath(row: i, section: 0))
        }
        self?.tableView.performBatchUpdates({
          self?.tableView.insertRows(at: indexPaths, with: .automatic)
        }, completion: { _ in
          self?.tableView.scrollToRow(at: IndexPath(row: messages.count-1, section: 0), at: .bottom, animated: true)
        })
      }
    }
  }

  private func configureConstraints() {
    tableView.translatesAutoresizingMaskIntoConstraints = false
    inputBar.translatesAutoresizingMaskIntoConstraints = false

    inputBarBottomConstraint = inputBar.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    inputBarHeightConstraint = inputBar.heightAnchor.constraint(equalToConstant: inputBar.totalHeight)

    let constraints = [
      tableView.topAnchor.constraint(equalTo: view.topAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: inputBar.topAnchor),

      inputBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      inputBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      inputBarBottomConstraint!,
      inputBarHeightConstraint!
    ]
    NSLayoutConstraint.activate(constraints)
  }

  // MARK: - Actions

  @objc private func keyboardWillChangeFrame(_ notification: Notification) {
    guard let userInfo = notification.userInfo,
          let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue,
          let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue,
          let curve = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as AnyObject).uintValue else {
      return
    }

    // Animate the input bar with the keyboard so that it is not hidden after the keyboard is up.
    inputBarBottomConstraint.constant = endFrame.origin.y < view.frame.maxY ? -endFrame.height : 0
    inputBarHeightConstraint.constant =
      endFrame.origin.y < view.frame.maxY ? inputBar.totalHeight : inputBar.totalHeight + view.safeAreaInsets.bottom
    let options = UIView.AnimationOptions(rawValue: curve)
    UIView.animate(withDuration: duration, delay: 0, options: options) {
      self.view.layoutIfNeeded()
      let row = self.tableView.numberOfRows(inSection: 0) - 1
      if row >= 0 {
        self.tableView.scrollToRow(at: IndexPath(row: row, section: 0), at: .bottom, animated: false)
      }
    }
  }

  @objc private func didReceiveMessage(_ notification: Notification) {
    guard let userInfo = notification.userInfo, let message = userInfo[NewMessageNotificationKey] as? MessageModel else {
      return
    }
    viewModel.receiveMessage(message)
  }

}

extension ChatViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.messages.value.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: ChatBubbleCell.defaultReuseIdentifier, for: indexPath) as! ChatBubbleCell
    let message = viewModel.messages.value[indexPath.row]
    cell.isSelfBubble = message.isSelfMessage
    cell.text = message.text
    return cell
  }
}

extension ChatViewController: ChatInputBarDelegate {
  func chatInputBar(_ inputBar: ChatInputBar, willSend message: String) {
    viewModel.sendMessage(message)
  }
}
