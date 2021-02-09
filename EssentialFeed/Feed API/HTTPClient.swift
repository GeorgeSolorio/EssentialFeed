//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by George Solorio on 2/9/21.
//

import Foundation

public enum HTTPClientResult {
   case success(Data, HTTPURLResponse)
   case failure(Error)
}

public protocol HTTPClient {
   func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
