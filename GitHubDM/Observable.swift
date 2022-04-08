//
//  Observable.swift
//  GitHubDM
//
//  Created by Yingwei Fan on 9/11/21.
//

import Foundation

class Observable<T> {
  var value: T {
    didSet {
      DispatchQueue.main.async {
        self.listener?(self.value)
      }
    }
  }

  private var listener: ((T) -> Void)?

  init(value: T) {
    self.value = value
  }

  func bind(_ closure: @escaping (T) -> Void) {
    listener = closure
    DispatchQueue.main.async {
      closure(self.value)
    }
  }
}
