//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by George Solorio on 2/3/21.
//

import Foundation

final public class RemoteFeedLoader {
   
   private let url: URL
   private let client: HTTPClient
   
   public enum Error: Swift.Error {
      case connectivity
      case invalidData
   }
   
   public enum Result: Equatable {
      case success([FeedItem])
      case failure(Error)
   }
   
   public init(url: URL, client: HTTPClient) {
      self.url = url
      self.client = client
   }
   
   public func load(completion: @escaping (Result) -> Void) {
      client.get(from: url) { result in
         switch result {
         case let .success(data, response):
            let result = FeedItemsMapper.map(data, from: response)
            completion(result)
         case.failure:
            completion(.failure(.connectivity))
         }
      }
   }
}
