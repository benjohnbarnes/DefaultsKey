// Copyright © 2024 Splendid Things. All rights reserved.

import Foundation

/// `UserDefaultsKey` provides type safe access to default values stored in a `UserDefaults`.
public struct UserDefaultsKey<Value: Sendable, Failure: Error>: Sendable {
    let get: Get
    let set: Set

    typealias Get = @Sendable (UserDefaults) -> Result<Value, Failure>
    typealias Set = @Sendable (UserDefaults, Value) -> Result<Void, Failure>

    init(get: @escaping Get, set: @escaping Set) {
        self.get = get
        self.set = set
    }

    init(get: @escaping @Sendable (UserDefaults) -> Value, set: @escaping @Sendable (UserDefaults, Value) -> Void) where Failure == Never {
        self.get = { .success(get($0)) }
        self.set = { .success(set($0, $1)) }
    }
}

// MARK: - PList compatible keys

extension UserDefaultsKey where Failure == Never {
    public static func bool(_ keyName: UserDefaultsKeyName) -> Self where Value == Bool? { .unsafePListKey(keyName) }
    public static func integer(_ keyName: UserDefaultsKeyName) -> Self where Value == Int? { .unsafePListKey(keyName) }
    public static func float(_ keyName: UserDefaultsKeyName) -> Self where Value == Float? { .unsafePListKey(keyName) }
    public static func double(_ keyName: UserDefaultsKeyName) -> Self where Value == Double? { .unsafePListKey(keyName) }
    public static func date(_ keyName: UserDefaultsKeyName) -> Self where Value == Date? { .unsafePListKey(keyName) }
    public static func string(_ keyName: UserDefaultsKeyName) -> Self where Value == String? { .unsafePListKey(keyName) }
    public static func data(_ keyName: UserDefaultsKeyName) -> Self where Value == Data? { .unsafePListKey(keyName) }

    /// This is private and "unsafe…" because asking `UserDefaults` to store arbitrary (non plist) types
    /// aborts with a fatal error. Eg: `defaults.set((), forKey: "void")`.
    ///
    /// The policy used is that if the type is present but is a different type, then this is not an
    /// error and nil is returned. It would be interesting to also consider this as an error.
    ///
    private static func unsafePListKey<V>(_ keyName: UserDefaultsKeyName) -> UserDefaultsKey where Value == V? {
        UserDefaultsKey(
            get: { store in .success(store.object(forKey: keyName.name).flatMap { $0 as? V }) },
            set: { store, newValue in .success(store.set(newValue, forKey: keyName.name)) }
        )
    }
}

// MARK: - Coercing keys

extension UserDefaultsKey where Failure == Never {
    public static func bool(coercing keyName: UserDefaultsKeyName) -> Self where Value == Bool {
        Self { $0.bool(forKey: keyName.name) } set: { $0.set($1, forKey: keyName.name) }
    }

    public static func integer(coercing keyName: UserDefaultsKeyName) -> Self where Value == Int {
        Self { $0.integer(forKey: keyName.name) } set: { $0.set($1, forKey: keyName.name) }
    }

    public static func float(coercing keyName: UserDefaultsKeyName) -> Self where Value == Float {
        Self { $0.float(forKey: keyName.name) } set: { $0.set($1, forKey: keyName.name) }
    }

    public static func double(coercing keyName: UserDefaultsKeyName) -> Self where Value == Double {
        Self { $0.double(forKey: keyName.name) } set: { $0.set($1, forKey: keyName.name) }
    }

    public static func string(coercing keyName: UserDefaultsKeyName) -> Self where Value == String? {
        Self { $0.string(forKey: keyName.name) } set: { $0.set($1, forKey: keyName.name) }
    }

    public static func url(coercing keyName: UserDefaultsKeyName) -> Self where Value == URL? {
        Self { $0.url(forKey: keyName.name) } set: { $0.set($1, forKey: keyName.name) }
    }
}

// MARK: -

extension UserDefaultsKey {
    public static func defaulting(
        _ optionalKey: UserDefaultsKey<Value?, Failure>,
        with defaultValue: Value
    ) -> Self {
        UserDefaultsKey(
            get: { store in optionalKey.get(store).map { $0 ?? defaultValue } },
            set: { store, newValue in optionalKey.set(store, newValue) }
        )
    }

    public static func rawRepresentable<V: RawRepresentable>(
        type: V.Type = V.self,
        represented rawKey: UserDefaultsKey<V.RawValue?, Never>
    ) -> Self where Value == V?, Failure == Never {
        Self(
            get: { store in rawKey.get(store).map { $0.flatMap(V.init(rawValue:)) } },
            set: { store, newValue in rawKey.set(store, newValue.map(\.rawValue)) }
        )
    }

    public static func jsonCoded<V: Codable>(
        type: V.Type = V.self,
        _ keyName: UserDefaultsKeyName
    ) -> Self where Value == V?, Failure == Error {
        Self(
            get: { store in
                Result {
                    guard let data = store.data(forKey: keyName.name) else {
                        return nil
                    }

                    return try JSONDecoder().decode(V.self, from: data)
                }
            },
            set: { store, newValue in
                Result {
                    guard let newValue else {
                        store.removeObject(forKey: keyName.name)
                        return
                    }

                    try store.set(JSONEncoder().encode(newValue), forKey: keyName.name)
                }
            }
        )
    }
}
