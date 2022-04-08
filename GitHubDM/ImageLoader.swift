//
//  ImageLoader.swift
//  GitHubDM
//
//  Created by Yingwei Fan on 9/12/21.
//

import UIKit

class ImageLoader {

  private let imageCache = ImageCache<String, UIImage>()

  private let imagePath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]

  func loadImage(_ urlString: String, completion: @escaping (UIImage?, Error?) -> Void) {
    guard let url = URL(string: urlString) else {
      return
    }
    // Read image from cache.
    if let image = imageCache[urlString] {
      DispatchQueue.main.async {
        completion(image, nil)
      }
      return
    }

    // Read image from disk.
    let replacedString = urlString.replacingOccurrences(of: "/", with: "_")
    let filename = imagePath.appendingPathComponent("\(replacedString)")

    if let imageData = try? Data(contentsOf: filename), let image = UIImage(data: imageData) {
      DispatchQueue.main.async {
        completion(image, nil)
      }
      return
    }

    URLSession.shared.dataTask(with: url) { data, response, error in
      guard let data = data else {
        DispatchQueue.main.async {
          completion(nil, error)
        }
        return
      }
      // Save image to cache.
      let image = UIImage(data: data)!
      self.imageCache[urlString] = image

      // Save image to disk.
      do {
        try data.write(to: filename)
      } catch let error {
        print(error.localizedDescription)
      }

      DispatchQueue.main.async {
        completion(image, nil)
      }
    }.resume()
  }
}

class ImageCache<Key: Hashable, Value> {

  class InnerKey: NSObject {
    let key: Key
    init(_ key: Key) {
      self.key = key
      super.init()
    }

    override var hash: Int {
      return key.hashValue
    }

    override func isEqual(_ object: Any?) -> Bool {
      guard let object = object as? InnerKey else {
        return false
      }
      return key == object.key
    }
  }

  class InnerValue {
    let value: Value
    init(_ value: Value) {
      self.value = value
    }
  }

  private var cache = NSCache<InnerKey, InnerValue>()

  func value(for key: Key) -> Value? {
    return cache.object(forKey: InnerKey(key))?.value
  }

  func insert(_ value: Value, for key: Key) {
    cache.setObject(InnerValue(value), forKey: InnerKey(key))
  }

  func remove(_ key: Key) {
    cache.removeObject(forKey: InnerKey(key))
  }

  subscript(key: Key) -> Value? {
    get {
      return value(for: key)
    }
    set {
      guard let value = newValue else {
        remove(key)
        return
      }
      insert(value, for: key)
    }
  }
}
