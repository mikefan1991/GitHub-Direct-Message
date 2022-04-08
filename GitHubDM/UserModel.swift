//
//  UserListModel.swift
//  GitHubDM
//
//  Created by Yingwei Fan on 9/11/21.
//

import Foundation

struct UserModel: Decodable {
  var login: String
  let id: Int
  let nodeId: String
  let avatarUrl: String
  let gravatarId: String
  let url: String
  let htmlUrl: String
  let followersUrl: String
  let followingUrl: String
  let gistsUrl: String
  let starredUrl: String
  let subscriptionsUrl: String
  let organizationsUrl: String
  let reposUrl: String
  let eventsUrl: String
  let receivedEventsUrl: String
  let type: String
  let siteAdmin: Bool

  mutating func updateName() {
    login.append("+")
  }
}
