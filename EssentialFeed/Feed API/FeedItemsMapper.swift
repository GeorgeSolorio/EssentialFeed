//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by George Solorio on 2/9/21.
//

import Foundation

internal struct RemoteFeedItem: Decodable {
   internal let id: UUID
   internal let description: String?
   internal let location: String?
   internal let image: URL
}

final class FeedItemsMapper {
   
   
   private struct Root: Decodable {
      let items: [RemoteFeedItem]
   }

   private static var OK_200: Int { 200 }
   
   static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
      
      guard response.statusCode == OK_200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
         throw RemoteFeedLoader.Error.invalidData
      }
      
      return root.items
   }
}
