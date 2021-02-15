//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by George Solorio on 2/15/21.
//

import Foundation

public protocol FeedStore {
   typealias DeletionCompletion = (Error?) -> Void
   typealias InsertionCompletion = (Error?) -> Void

   func deleteCacheFeed(completion: @escaping DeletionCompletion)
   func insert(_ items: [LocalFeedItem], timestamp: Date, completion: @escaping InsertionCompletion)
}
