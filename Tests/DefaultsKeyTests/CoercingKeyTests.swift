// Copyright © 2025 Splendid Things. All rights reserved.

import Testing
import Foundation
import DefaultsKey

struct CoercingKeyTests {

    let defaultsProvider = TestDefaultsProvider()
    var defaults: UserDefaults { defaultsProvider.defaults }

    @Test func missingKey() async throws {
        #expect(defaults[.stringKey] == nil)
        #expect(defaults[.boolKey] == false)
        #expect(defaults[.intKey] == 0)
        #expect(defaults[.floatKey] == 0)
        #expect(defaults[.doubleKey] == 0)
    }

    @Test func stringNonCoercible() async throws {
        defaults[.stringKey] = "Not an of the things"
        #expect(defaults[.boolKey] == false)
        #expect(defaults[.intKey] == 0)
        #expect(defaults[.floatKey] == 0)
        #expect(defaults[.doubleKey] == 0)
    }

    @Test func stringCoercibleToNumbers() async throws {
        defaults[.stringKey] = "10"
        #expect(defaults[.boolKey] == false)
        #expect(defaults[.intKey] == 10)
        #expect(defaults[.floatKey] == 10)
        #expect(defaults[.doubleKey] == 10)

        defaults[.stringKey] = "10.75"
        #expect(defaults[.boolKey] == false)
        /// Didn't expect this…
        #expect(defaults[.intKey] == 0)
        #expect(defaults[.floatKey] == 10.75)
        #expect(defaults[.doubleKey] == 10.75)
    }

    @Test func stringCoercibleToBool() async throws {
        defaults[.stringKey] = "YES"
        #expect(defaults[.boolKey] == true)
        #expect(defaults[.intKey] == 0)
        #expect(defaults[.floatKey] == 0)
        #expect(defaults[.doubleKey] == 0)

        defaults[.stringKey] = "NO"
        #expect(defaults[.boolKey] == false)
        #expect(defaults[.intKey] == 0)
        #expect(defaults[.floatKey] == 0)
        #expect(defaults[.doubleKey] == 0)

        defaults[.stringKey] = "true"
        #expect(defaults[.boolKey] == true)
        #expect(defaults[.intKey] == 0)
        #expect(defaults[.floatKey] == 0)
        #expect(defaults[.doubleKey] == 0)

        defaults[.stringKey] = "false"
        #expect(defaults[.boolKey] == false)
        #expect(defaults[.intKey] == 0)
        #expect(defaults[.floatKey] == 0)
        #expect(defaults[.doubleKey] == 0)
    }

    @Test func boolCoercible() async throws {
        defaults[.boolKey] = true
        #expect(defaults[.boolKey] == true)
        #expect(defaults[.intKey] == 1)
        #expect(defaults[.floatKey] == 1)
        #expect(defaults[.doubleKey] == 1)
        #expect(defaults[.stringKey] == "1")

        defaults[.boolKey] = false
        #expect(defaults[.boolKey] == false)
        #expect(defaults[.intKey] == 0)
        #expect(defaults[.floatKey] == 0)
        #expect(defaults[.doubleKey] == 0)
        #expect(defaults[.stringKey] == "0")
    }

    @Test func intCoercible() async throws {
        defaults[.intKey] = 0
        #expect(defaults[.boolKey] == false)
        #expect(defaults[.intKey] == 0)
        #expect(defaults[.floatKey] == 0)
        #expect(defaults[.doubleKey] == 0)
        #expect(defaults[.stringKey] == "0")

        defaults[.intKey] = 10
        #expect(defaults[.boolKey] == true)
        #expect(defaults[.intKey] == 10)
        #expect(defaults[.floatKey] == 10)
        #expect(defaults[.doubleKey] == 10)
        #expect(defaults[.stringKey] == "10")
    }

    @Test func floatCoercible() async throws {
        defaults[.floatKey] = 0
        #expect(defaults[.boolKey] == false)
        #expect(defaults[.intKey] == 0)
        #expect(defaults[.floatKey] == 0)
        #expect(defaults[.doubleKey] == 0)
        #expect(defaults[.stringKey] == "0")

        defaults[.floatKey] = 1.75
        #expect(defaults[.boolKey] == true)
        #expect(defaults[.intKey] == 1)
        #expect(defaults[.floatKey] == 1.75)
        #expect(defaults[.doubleKey] == 1.75)
        #expect(defaults[.stringKey] == "1.75")
    }

    @Test func urlCoercion() async throws {
        let url = try #require(URL(string: #"http://here.com"#))
        defaults[.urlKey] = url
        #expect(defaults[.urlKey] == url)
        #expect(defaults[.stringKey] == nil)

        let path = "/a/b/c"
        defaults[.stringKey] = path
        #expect(defaults[.stringKey] == path)
        #expect(defaults[.urlKey] == URL(fileURLWithPath: "/a/b/c"))

    }
}

private extension UserDefaultsKey {
    static var boolKey: UserDefaultsKey<Bool, Never> { .bool(coercing: .key) }
    static var intKey: UserDefaultsKey<Int, Never> { .integer(coercing: .key) }
    static var floatKey: UserDefaultsKey<Float, Never> { .float(coercing: .key) }
    static var doubleKey: UserDefaultsKey<Double, Never> { .double(coercing: .key) }
    static var stringKey: UserDefaultsKey<String?, Never> { .string(coercing: .key) }
    static var urlKey: UserDefaultsKey<URL?, Never> { .url(coercing: .key) }
}

private extension UserDefaultsKeyName {
    static let key = Self("key")
}
