//
//  NetworkService.swift
//  GitHubDM
//
//  Created by Yingwei Fan on 9/11/21.
//

import Foundation

class NetworkService {

  lazy var imageLoader: ImageLoader = {
    return ImageLoader()
  }()

  func fetchUserList(_ completion: @escaping ([UserModel]?, Error?) -> Void) {
    guard let url = URL(string: "https://api.github.com/users") else {
      return
    }
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    URLSession.shared.dataTask(with: request) { data, response, error in
      guard let data = data else {
        DispatchQueue.main.async {
          completion(nil, error)
        }
        return
      }

      let decoder = JSONDecoder()
      decoder.keyDecodingStrategy = .convertFromSnakeCase
      let users = try! decoder.decode([UserModel].self, from: data)
      DispatchQueue.main.async {
        completion(users, nil)
      }
    }.resume()
  }

}
