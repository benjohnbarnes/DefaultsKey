// Copyright © 2025 Splendid Things. All rights reserved.

import Foundation

public struct UserDefaultsKeyName: Sendable {
    let name: String
}

extension UserDefaultsKeyName: ExpressibleByStringLiteral {
    public init(stringLiteral name: StringLiteralType) { self.name = name }
}

extension UserDefaultsKeyName: Identifiable, Hashable {
    public var id: String { name }
}
