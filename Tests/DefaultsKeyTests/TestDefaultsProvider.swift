// Copyright © 2025 Splendid Things. All rights reserved.

import Foundation

final class TestDefaultsProvider {
    let id = UUID()

    deinit {
        UserDefaults().removePersistentDomain(forName: id.uuidString)
    }

    var defaults: UserDefaults {
        UserDefaults(suiteName: id.uuidString)!
    }
}
