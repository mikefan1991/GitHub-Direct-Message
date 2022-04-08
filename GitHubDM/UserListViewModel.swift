//
//  UserListViewModel.swift
//  GitHubDM
//
//  Created by Yingwei Fan on 9/11/21.
//

import UIKit

class UserListViewModel: NSObject {

  let networkService: NetworkService

  var users: Observable<[UserModel]?>

  init(networkService: NetworkService) {
    self.networkService = networkService
    users = Observable(value: nil)
    super.init()
  }

  // MARK: - Public

  func requestData() {
    networkService.fetchUserList { users, error in
      guard let users = users else {
        if let error = error {
          print(error.localizedDescription)
        }
        self.users.value = nil
        return
      }
      self.users.value = users
    }
  }

}
