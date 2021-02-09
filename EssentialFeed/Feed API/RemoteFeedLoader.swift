//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by George Solorio on 2/3/21.
//

import Foundation

public enum HTTPClentResult {
   case success(Data, HTTPURLResponse)
   case failure(Error)
}

public protocol HTTPClient {
   func get(from url: URL, completion: @escaping (HTTPClentResult) -> Void)
}

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
            if response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) {
               completion(.success(root.items))
            } else {
               completion(.failure(.invalidData))
            }
         case.failure:
            completion(.failure(.connectivity))
         }
      }
   }
}

private struct Root: Decodable {
   let items: [FeedItem]
}
