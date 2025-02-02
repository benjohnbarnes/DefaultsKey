// Copyright © 2025 Splendid Things. All rights reserved.

import Testing
import Foundation
import DefaultsKey

struct Test {

    let defaultsProvider = TestDefaultsProvider()
    var defaults: UserDefaults { defaultsProvider.defaults }

    @Test func test() async throws {
        @UserDefault(.key, defaults: self.defaults) var userDefault

        #expect(userDefault == nil)

        userDefault = false
        #expect(userDefault == false)

        userDefault = true
        #expect(userDefault == true)

        userDefault = nil
        #expect(userDefault == nil)
    }
}

private extension UserDefaultsKey<Bool?, Never> {
    static let key: Self = .bool("a-key")
}
