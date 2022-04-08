//
//  MessageModel.swift
//  GitHubDM
//
//  Created by Yingwei Fan on 9/12/21.
//

import Foundation

struct MessageModel: Codable {
  let text: String
  let isSelfMessage: Bool
  let username: String

  init(text: String, isSelfMessage: Bool, username: String = "self") {
    self.text = text
    self.isSelfMessage = isSelfMessage
    self.username = username
  }
}
