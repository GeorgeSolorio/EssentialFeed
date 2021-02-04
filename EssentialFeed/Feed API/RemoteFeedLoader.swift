//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by George Solorio on 2/3/21.
//

import Foundation

public protocol HTTPClient {
   func get(from url: URL)
}

final public class RemoteFeedLoader {
   
   private let url: URL
   private let client: HTTPClient
   
   public init(url: URL, client: HTTPClient) {
      self.url = url
      self.client = client
   }
   
   public func load() {
      client.get(from: url)
   }
}
