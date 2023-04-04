//
//  DispatchQueue+executeOnMain.swift
//  YPersistence
//
//  Created by Mark Pospesel on 12/3/21.
//  Copyright © 2023 Y Media Labs. All rights reserved.
//

import Foundation

extension DispatchQueue {
    /// Executes the block on the main thread.
    /// If called from the main thread, the block will be executed immediately and synchronously.
    /// If called from a background thread, the block will be executed asynchronously on the main thread.
    /// This method is intended to avoid unnecessary calls to `DispatchQueue.main.async` but you
    /// wish to guarantee that the code is run on the main thread.
    /// - Parameter work: The block of work to be executed on the main thread.
    public static func executeOnMain(execute work: @escaping @convention(block) () -> Void) {
        if Thread.isMainThread {
            // If we're on main, run it immediately
            work()
        } else {
            // If we're not on main, then run it asynchronously on main
            DispatchQueue.main.async { work() }
        }
    }
}
