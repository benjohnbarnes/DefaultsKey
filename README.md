#  `DefaultsKey`

DefaultsKey provides `UserDefaultsKey<Value, Failure: Error>`, a typed wrapper for safe and ergonomic access to Foundation's 
`UserDefaults`.


## Basic Use

Here's how you read or write a value in `UserDefaults` with `UserDefaultsKey`:

```swift
let defaults = UserDefaults.standard

// Read a value.
let isEnabled = defaults[.isFeatureEnabled]

// Write a value.
defaults[.isFeatureEnabled] = isEnabled
```

A key declaration looks like this:

```swift
extension UserDefaultsKey<Bool?, Never> {
  static let isFeatureEnabled: Self = .bool("is-my-feature-enabled")
}
```


## Design Goals – why use this?
* `UserDefaultsKey` is typed, so you can only read and write the type a key actually contains, removing a source of error. This also
documents the type of a key ensuring there is no confusion about this.
* `UserDefaultsKey` entirely prevents writing non PList values in to `UserDefaults` **at compile time**. This eliminates a source of run
time panics that would crash your App.
* `UserDefaultsKey` supports types beyond vanilla PList values if they are `Codable` or if they are `RawRepresentable` as a PList type
(such as `String` backed enums).
* `UserDefaultsKey` supports non `Optional` values that have a default to use if a key isn't in a `UserDefaults` container. This ensures
the default has a single source of truth and is consistent at all use points in a program, and prevents scattered handling of
missing keys.
* The library design prioritises ergonomic, clear and simple declaration and usage of keys. A `UserDefaultKey` will autocomplete in 
Xcode and offer contextually relevant keys to you as you code.
* `UserDefaultsKey` supports both non throwing keys and throwing keys.
* `UserDefaultsKey` lets you opt specific keys in to `UserDefaults` value coercion behaviour when you need to use this. Any keys that
use this clearly document themself as such.


## Creating Basic Keys

The following methods are available to provide you with simple typed keys:

```swift
extension UserDefaultsKey where Failure == Never {
    public static func bool(_ keyName: UserDefaultsKeyName) -> Self where Value == Bool?
    public static func integer(_ keyName: UserDefaultsKeyName) -> Self where Value == Int?
    public static func float(_ keyName: UserDefaultsKeyName) -> Self where Value == Float?
    public static func double(_ keyName: UserDefaultsKeyName) -> Self where Value == Double?
    public static func date(_ keyName: UserDefaultsKeyName) -> Self where Value == Date?
    public static func string(_ keyName: UserDefaultsKeyName) -> Self where Value == String?
    public static func data(_ keyName: UserDefaultsKeyName) -> Self where Value == Data?
}
```

Note that values here are optional because a key may be missing. Optionality is also respected when you assign, so you can remove
a key's value by assigning `nil`.


## Default Values

You might want to set up a default for your key as well, so there is no need to handle optionality at the usage site, and all
usage sites will use the same default value.

You can do that like this:

```swift
extension UserDefaultsKey<Bool, Never> {
    static let isFeatureEnabled: Self = .defaulting(
        .bool("is-my-feature-enabled"), 
        with: false
    )
}
```

Note that now the extension is on `UserDefaultsKey<Bool, Never>`, instead of `UserDefaultsKey<Bool?, Never>` because the key is not
optional in this case and has a default value `false`.

### `initialisingWith:`

DefaultsKey provides a second mechanism to handle optionality. For an `Optional` key, you can use this subscript form:

```swift
let firstUseDate = defaults[.firstUseDate, initialisingWith: .now]
```

The example given here holds a `Date`. It ensures that at the moment of reading a key for the first time, the value is initialised
**and recorded** in to `UserDefaults`. Future reads will see this recoded value (unless it is modified), rather than the future
date at which they are read.


## `RawRepresentable` Values

If you have a `RawRepresentable` type, such as an `enum Colour: String`, you can get a key for this too.

```swift
enum Colour: String {
  case red, green, blue
}

extension UserDefaultsKey<Colour, Never> {
    static let colourKey = Self.defaulting(
        .rawRepresentable(represented: .string("colour-key")), 
        with: .red
    )
}
```


## `Codable` Values

Any `Codable` type is also supported.

```swift
extension UserDefaultsKey<MyCodable, Error> {
  static let myDefaultsKey: Self = .jsonCoded("codable-key-name")
}
```

Notice that this `UserDefaultsKey` has an `Error` as it will `throw` if a coding error is encountered when the key is read or written. 


## Coercing Keys

Type "Coercion" is an automatic and implicit conversion from one type to another. Foundation's `UserDefaults` provides some special
handling of `Bool`, `Int`, `Float` and `Double` types. 

* It can coerce any of the number types to a `String`.
* It can coerce a `Bool` to `String`, using `"YES"` and `"NO"` to encode `true` and `false`.
* It can coerce from `String` to any number type, if the number type can represent the `String` (without rounding).
* It can coerce from `String` to a `Bool` if the `String` is `"NO"`, `"YES"`, `"true"` or `"false"`.
* It can coerce from a `Bool` to a number type, using `0` and `1` to encode `false` and `true`.
* NB: it will not coerce from a number type to a `Bool`.

`UserDefaults` also has some coercion between `String` and `URL` – it will build a local file `URL` from a path `String`.

In general I avoid using `UserDefaults` coercing behaviour. If you use the previously mentioned key creation functions, no
coercions will be performed. 

I considered leaving coercion support out of DefaultsKey, but it can it can be useful. For example, if a `UserDefaults` instance
includes command line arguments or environment values, it will have come from "stringly" typed input. Without support for coercion
you would be reduced to working with `String` values with a loss of type safety and the means to specify the value type you **expect**
the environment key to contain.

You can build keys that will coerce using these functions:

```swift
static func bool(coercing keyName: UserDefaultsKeyName) -> Self where Value == Bool
static func integer(coercing keyName: UserDefaultsKeyName) -> Self where Value == Int
static func float(coercing keyName: UserDefaultsKeyName) -> Self where Value == Float
static func double(coercing keyName: UserDefaultsKeyName) -> Self where Value == Double
static func string(coercing keyName: UserDefaultsKeyName) -> Self where Value == String?
static func url(coercing keyName: UserDefaultsKeyName) -> Self where Value == URL?
```


## `UserDefaultsKeyName`

When you create a key with a method such as `bool(_ keyName: UserDefaultsKeyName) -> UserDefaultsKey`, you can simply write
`let myKey = UserDefaultsKey.bool("my-key-name")`, and this is often a good approach. However, the function doesn't take a `String` for
the key name, it takes a `UserDefaultsKeyName`. Because key names have their own type, if you need, you can write extension functions on
this to add logic that generates key names. As an example, you might have keys associated with each of your different backend environments
(production, test, staging, etc). You could then write functions from `Environment` to `UserDefaultsKeyName` for various purposes.

