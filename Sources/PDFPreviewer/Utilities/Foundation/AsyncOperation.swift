//
//  AsyncOperation.swift
//  PDFPreviewer
//
//  Created by 孟超 on 2024/9/17.
//

import Foundation

class AsyncOperation: Operation, @unchecked Sendable {
    
    private enum State: String {
        case ready, executing, finished
    }
    
    private var state: State = .ready {
        willSet {
            willChangeValue(forKey: newValue.rawValue)
            willChangeValue(forKey: state.rawValue)
        }
        didSet {
            didChangeValue(forKey: oldValue.rawValue)
            didChangeValue(forKey: state.rawValue)
        }
    }
    
    /// A Boolean value indicating whether the operation can be performed now.
    override final var isReady: Bool {
        return super.isReady && state == .ready
    }
    /// A Boolean value indicating whether the operation is currently executing.
    override final var isExecuting: Bool {
        return state == .executing
    }
    /// A Boolean value indicating whether the operation has finished executing its task.
    override final var isFinished: Bool {
        return state == .finished
    }
    /// A Boolean value indicating whether the operation executes its task asynchronously.
    ///
    /// Always return `true`.
    override final var isAsynchronous: Bool {
        true
    }
    /// Begins the execution of the operation.
    ///
    /// The operation cannot be restarted after finished.
    override final func start() {
        if self.isFinished { return }
        self.state = .executing
        self.main()
    }
    
    override final func main() {
        self.body()
        self.state = .finished
    }
    
    func body() {
        fatalError("[\(Self.self)][\(#function)] Subclasses of `AsyncOperation` must override this method, and they must not call the superclass's `main`, `start`, `cancel`, `body` method in the implementation.")
    }
}
