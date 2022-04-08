//
//  ViewController.swift
//  GitHubDM
//
//  Created by Yingwei Fan on 9/11/21.
//

import UIKit

class UserListViewController: UIViewController {

  let networkService: NetworkService

  let tableView = UITableView()

  let viewModel: UserListViewModel

  init(_ networkService: NetworkService) {
    viewModel = UserListViewModel(networkService: networkService)
    self.networkService = networkService
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.

    configureSubviews()
    configureConstraints()
    viewModel.requestData()
  }

  // MARK: - Private

  private func configureSubviews() {
    navigationController?.navigationBar.prefersLargeTitles = true
    let navBarAppearance = UINavigationBarAppearance()
    navBarAppearance.configureWithDefaultBackground()
    navigationController?.navigationBar.standardAppearance = navBarAppearance
    navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
    navigationItem.backButtonDisplayMode = .minimal
    title = "GitHub DM"

    tableView.dataSource = self
    tableView.delegate = self
    tableView.estimatedRowHeight = UserCell.imageViewHeight + UserCell.padding * 2
    tableView.separatorInset = UserCell.separatorInset
    // Remove the top seperator line.
    tableView.tableHeaderView = UIView()
    tableView.register(UserCell.self, forCellReuseIdentifier: UserCell.defaultReuseIdentifier)
    view.addSubview(tableView)

    viewModel.users.bind { [weak self] users in
      self?.tableView.reloadData()
    }
  }

  private func configureConstraints() {
    tableView.translatesAutoresizingMaskIntoConstraints = false

    let constraints = [
      tableView.topAnchor.constraint(equalTo: view.topAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ]
    NSLayoutConstraint.activate(constraints)
  }

}

extension UserListViewController: UITableViewDataSource {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.users.value?.count ?? 0
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.defaultReuseIdentifier, for: indexPath) as! UserCell
    cell.tag = indexPath.row
    if let users = viewModel.users.value {
      let user = users[indexPath.row]
      cell.nameLabel.text = "@" + user.login

      networkService.imageLoader.loadImage(user.avatarUrl) { image, error in
        guard cell.tag == indexPath.row else {
          return
        }
        guard let image = image else {
          if let error = error {
            print(error.localizedDescription)
          }
          return
        }
        cell.avatarImageView.image = image
      }
    }
    return cell
  }

}

extension UserListViewController: UITableViewDelegate {

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    guard let user = viewModel.users.value?[indexPath.row] else {
      return
    }
//    let chatViewController = ChatViewController(user: user, networkService: networkService)
//    navigationController?.pushViewController(chatViewController, animated: true)
    viewModel.users.value?[indexPath.row].updateName()
  }

}
