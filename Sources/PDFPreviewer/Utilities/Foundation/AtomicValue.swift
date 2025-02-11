//  - ** Public Domain ** -
//
//  AtomicValue.swift
//  PDFPreviewer
//
//  Created by 孟超 on 2024/9/16.
//

import Foundation

/// A property wrapper to ensure thread safety for a stored property.
///
/// This property wrapper is only applicable to stored properties of struct or immutable class types. It uses `NSLock` internally to ensure thread safety for the property.
///
/// > If you want to access the property without locking, you can use the `projectedValue` of this property wrapper. However, this may lead to data races.
@propertyWrapper
final public class AtomicValue<Value>: @unchecked Sendable {
    private var storage: Value
    private let lock: NSLocking
    public var wrappedValue: Value {
        get {
            return self.lock.withLock {
                return self.storage
            }
        }
        set {
            self.lock.lock()
            self.storage = newValue
            self.lock.unlock()
        }
    }
    public var projectedValue: ((Value) throws -> Value) throws -> () {
        get {
            self.withAtomicProcess
        }
    }
    public var unsafeValue: Value {
        self.storage
    }
    
    private func withAtomicProcess(closure: (Value) throws -> Value) rethrows {
        try self.lock.withLock {
            self.storage = try closure(self.storage)
        }
    }
    
    /// Initialize the current property wrapper with the specified lock type.
    public init(_ lock: Lock = .NSLock, defaultValue: Value) {
        self.storage = defaultValue
        self.lock = lock.newLock
    }
    
    /// Initialize the current property wrapper with the specified lock type.
    public init<T>(_ lock: Lock = .NSLock, defaultValue: T? = nil) where Value == T? {
        self.storage = defaultValue
        self.lock = lock.newLock
    }
    
    public init<T>(_ lock: Lock = .NSLock) where Value == Array<T> {
        self.storage = .init()
        self.lock = lock.newLock
    }
    
    public init<T>(_ lock: Lock = .NSLock) where Value == Set<T>, T: Hashable {
        self.storage = .init()
        self.lock = lock.newLock
    }
    
    public init<Key, Element>(_ lock: Lock = .NSLock) where Value == Dictionary<Key, Element>, Key: Hashable {
        self.storage = .init()
        self.lock = lock.newLock
    }
    
    public enum Lock {
        case NSLock
        case NSRecursiveLock
        var newLock: NSLocking {
            switch self {
                case .NSLock:
                    Foundation.NSLock()
                case .NSRecursiveLock:
                    Foundation.NSConditionLock()
            }
        }
    }
    
}
