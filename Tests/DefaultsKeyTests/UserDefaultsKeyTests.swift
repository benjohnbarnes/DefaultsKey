// Copyright © 2025 Splendid Things. All rights reserved.

import Foundation
import Testing
import DefaultsKey

struct UserDefaultsKeyTests {

    let defaultsProvider = TestDefaultsProvider()
    var defaults: UserDefaults { defaultsProvider.defaults }

    @Test func missingKeyTakesDefault() async throws {
        let defaultingKey = UserDefaultsKey.defaulting(.string("key"), with: "default")
        #expect(defaults[defaultingKey] == "default")

        defaults[defaultingKey] = "changed"
        #expect(defaults[defaultingKey] == "changed")
    }

    @Test func initialisingWith() async throws {
        let key = UserDefaultsKey.string("key")

        #expect(defaults[key] == nil)

        #expect(defaults[key, initialisingWith: "initial"] == "initial")
        #expect(defaults[key] == "initial")

        #expect(defaults[key, initialisingWith: "alternative"] == "initial")
        #expect(defaults[key] == "initial")

        defaults[key] = "changed"
        #expect(defaults[key] == "changed")
    }

    @Test func rawRepresentedBy() async throws {
        let rawRepresentableKey = UserDefaultsKey.rawRepresentable(type: Representable.self, represented: .string("key"))

        #expect(defaults[rawRepresentableKey] == nil)

        defaults[rawRepresentableKey] = .a
        #expect(defaults[rawRepresentableKey] == .a)

        defaults[rawRepresentableKey] = .b
        #expect(defaults[rawRepresentableKey] == .b)

        defaults.set("c", forKey: "key")
        #expect(defaults[rawRepresentableKey] == nil)
    }

    @Test func jsonCoded() async throws {
        let codableKey = UserDefaultsKey.jsonCoded(type: Coded.self, "key")
        try #expect(defaults[codableKey] == nil)

        try defaults.set(codableKey, to: .v1)
        try #expect(defaults[codableKey] == .v1)

        try defaults.set(codableKey, to: .v2)
        try #expect(defaults[codableKey] == .v2)

        defaults.set(Data(), forKey: "key")
        #expect(throws: Error.self) { try defaults[codableKey] }
    }
}

private enum Representable: String {
    case a, b
}

private struct Coded: Codable, Equatable {
    let a: Int
    let b: String

    static let v1 = Coded(a: 1, b: "1")
    static let v2 = Coded(a: 2, b: "2")
}
