// Copyright © 2025 Splendid Things. All rights reserved.

import Foundation

extension UserDefaults {
    /// Subscript access to a non throwing key.
    public subscript<Value>(_ key: UserDefaultsKey<Value, Never>) -> Value {
        get { key.get(self).get() }
        set { key.set(self, newValue).get() }
    }

    /// Throwing get of a key – swift doesn't support set of a throwing subscript.
    public subscript<Value, Failure: Error>(_ key: UserDefaultsKey<Value, Failure>) -> Value {
        get throws(Failure) { try key.get(self).get() }
    }

    /// Read only `Result` of a failable key.
    public subscript<Value, Failure: Error>(resultOf key: UserDefaultsKey<Value, Failure>) -> Result<Value, Failure> {
        get { key.get(self) }
    }

    /// Set the value of a failable key.
    public func set<Value, Failure: Error>(_ key: UserDefaultsKey<Value, Failure>, to newValue: Value) throws(Failure) {
        try key.set(self, newValue).get()
    }

    /// Read an optionally typed key. If the value of the key is nil, assign the value of this key
    /// with the default.
    ///
    /// Note that this is distinctly different from a defaulted key because a write is performed
    /// when a missing key is found. As an example, this can let us store a "first seen" date
    /// when no date has previously been recorded.
    public subscript<Value>(_ key: UserDefaultsKey<Value?, Never>, initialisingWith initialValue: Value) -> Value {
        get {
            if let value = self[key] {
                return value
            }
            else {
                self[key] = initialValue
                return initialValue
            }
        }
    }
}
