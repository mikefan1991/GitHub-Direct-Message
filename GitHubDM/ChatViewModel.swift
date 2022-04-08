//
//  ChatViewModel.swift
//  GitHubDM
//
//  Created by Yingwei Fan on 9/12/21.
//

import Foundation

let NewMessageNotificationName = NSNotification.Name(rawValue: "NewMessageNotification")
let NewMessageNotificationKey = "NewMessageNotificationKey"
let MessagesUserDefaultsKey = "MessagesUserDefaultsKey"

class ChatViewModel: NSObject {

  let networkService: NetworkService

  let user: UserModel

  var messages = Observable(value: [MessageModel]())

  init(user: UserModel, networkService: NetworkService) {
    self.user = user
    self.networkService = networkService
    super.init()
    messages.value = readStoredMessages()
  }

  func sendMessage(_ message: String) {
    guard message.count > 0 else {
      return
    }
    let messageModel = MessageModel(text: message, isSelfMessage: true)
    messages.value.append(messageModel)
    storeMessage(messageModel)


    // Send a response after 2 seconds.
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
      let responseMessage = message + " " + message
      let responseMessageModel = MessageModel(text: responseMessage, isSelfMessage: false, username: self.user.login)
      let userInfo = [NewMessageNotificationKey: responseMessageModel]
      NotificationCenter.default.post(name: NewMessageNotificationName, object: nil, userInfo: userInfo)
    }
  }

  func receiveMessage(_ message: MessageModel) {
    guard message.username == user.login else {
      return
    }

    messages.value.append(message)
    storeMessage(message)
  }

  // Store a message into the user defaults.
  private func storeMessage(_ message: MessageModel) {
    var messagesDict = [String: [MessageModel]]()
    if let encodedData = UserDefaults.standard.object(forKey: MessagesUserDefaultsKey) as? Data,
       let dict = try? JSONDecoder().decode([String: [MessageModel]].self, from: encodedData) {
      messagesDict = dict
    }
    messagesDict[user.login] = messages.value
    let encoder = JSONEncoder()
    guard let encodedData = try? encoder.encode(messagesDict) else {
      print("Encoding messages failed.")
      return
    }
    UserDefaults.standard.setValue(encodedData, forKey: MessagesUserDefaultsKey)
  }

  // Read all messages from this user from the user defaults.
  private func readStoredMessages() -> [MessageModel] {
    guard let encodedData = UserDefaults.standard.object(forKey: MessagesUserDefaultsKey) as? Data else {
      return []
    }
    let decoder = JSONDecoder()
    guard let messagesDict = try? decoder.decode([String: [MessageModel]].self, from: encodedData),
          let messagesArray = messagesDict[user.login] else {
      return []
    }
    return messagesArray
  }

}
