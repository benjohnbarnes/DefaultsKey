// Copyright © 2025 Splendid Things. All rights reserved.

import Foundation

@propertyWrapper public struct UserDefault<Value: Sendable> {
    let key: UserDefaultsKey<Value, Never>
    let defaults: UserDefaults

    public init(_ key: UserDefaultsKey<Value, Never>, defaults: UserDefaults = .standard) {
        self.key = key
        self.defaults = defaults
    }

    public var wrappedValue: Value {
        get { defaults[key] }
        set { defaults[key] = newValue }
    }
}
