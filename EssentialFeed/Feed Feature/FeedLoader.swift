//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by George Solorio on 2/3/21.
//

import Foundation

public enum LoadFeedResult {
   case success([FeedImage])
   case failure(Error)
}

public protocol FeedLoader {
   
   func load(completion: @escaping (LoadFeedResult) -> Void)
}
