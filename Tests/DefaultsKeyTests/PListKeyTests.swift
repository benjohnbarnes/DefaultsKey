// Copyright © 2025 Splendid Things. All rights reserved.

import Foundation
import Testing
import DefaultsKey

struct PListKeyTests {
    let defaultsProvider = TestDefaultsProvider()
    var defaults: UserDefaults { defaultsProvider.defaults }

    @Test func boolKey() async throws {
        let key1: UserDefaultsKey<Bool?, Never> = .bool("key1")
        let key2: UserDefaultsKey<Bool?, Never> = .bool("key2")
        testKeyIndependence(key1: key1, v1: true, key2: key2, v2: false)
    }

    @Test func intKey() async throws {
        let key1: UserDefaultsKey<Int?, Never> = .integer("key1")
        let key2: UserDefaultsKey<Int?, Never> = .integer("key2")
        testKeyIndependence(key1: key1, v1: 10, key2: key2, v2: 20)
    }

    @Test func floatKey() async throws {
        let key1: UserDefaultsKey<Float?, Never> = .float("key1")
        let key2: UserDefaultsKey<Float?, Never> = .float("key2")
        testKeyIndependence(key1: key1, v1: 10, key2: key2, v2: 20)
    }

    @Test func doubleKey() async throws {
        let key1: UserDefaultsKey<Double?, Never> = .double("key1")
        let key2: UserDefaultsKey<Double?, Never> = .double("key2")
        testKeyIndependence(key1: key1, v1: 10, key2: key2, v2: 20)
    }

    @Test func stringKey() async throws {
        let key1: UserDefaultsKey<String?, Never> = .string("key1")
        let key2: UserDefaultsKey<String?, Never> = .string("key2")
        testKeyIndependence(key1: key1, v1: "1", key2: key2, v2: "2")
    }

    @Test func dataKey() async throws {
        let key1: UserDefaultsKey<Data?, Never> = .data("key1")
        let key2: UserDefaultsKey<Data?, Never> = .data("key2")
        testKeyIndependence(key1: key1, v1: Data([1,2,3]), key2: key2, v2: Data([4,5,6]))
    }

    @Test func dateKey() async throws {
        let key1: UserDefaultsKey<Date?, Never> = .date("key1")
        let key2: UserDefaultsKey<Date?, Never> = .date("key2")

        let date1 = Date.now
        let date2 = date1.addingTimeInterval(10)

        testKeyIndependence(key1: key1, v1: date1, key2: key2, v2: date2)
    }

    func testKeyIndependence<Value: Equatable>(key1: UserDefaultsKey<Value?, Never>, v1: Value, key2: UserDefaultsKey<Value?, Never>, v2: Value) {
        /// Ensure test data is good.
        #expect(v1 != v2)

        /// Ensure no initial data.
        #expect(defaults[key1] == nil)
        #expect(defaults[key2] == nil)

        /// Assign 1 doesn't assign 2.
        defaults[key1] = v1
        #expect(defaults[key1] == v1)
        #expect(defaults[key2] == nil)

        /// Assign 2 doesn't assign 1.
        defaults[key2] = v2
        #expect(defaults[key1] == v1)
        #expect(defaults[key2] == v2)

        /// Clear 1 doesn't clear 2.
        defaults[key1] = nil
        #expect(defaults[key1] == nil)
        #expect(defaults[key2] == v2)

        /// Clear 2 leaves both clear.
        defaults[key2] = nil
        #expect(defaults[key1] == nil)
        #expect(defaults[key2] == nil)
    }
}
