//
//  Combine + Concurrency.swift
//  The What If
//
//  Created by Yona Harel on 05/08/2022.
//

import Foundation
import Combine

extension Publisher {
    /// an extension to have perform asynchronous code in a combine flatMap
    /// taken from the one and only John Sundell https://www.swiftbysundell.com/articles/calling-async-functions-within-a-combine-pipeline/
    func asyncMap<T>(
        _ transform: @escaping (Output) async -> T
    ) -> Publishers.FlatMap<Future<T, Never>, Self> {
        flatMap { value in
            Future { promise in
                Task {
                    let output = await transform(value)
                    promise(.success(output))
                }
            }
        }
    }
}
