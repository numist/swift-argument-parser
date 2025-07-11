//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Argument Parser open source project
//
// Copyright (c) 2020 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

/// A type that can be expressed as a command-line argument.
public protocol ExpressibleByArgument: _SendableMetatype {
  /// Creates a new instance of this type from a command-line-specified
  /// argument.
  init?(argument: String)

  /// The description of this instance to show as a default value in a
  /// command-line tool's help screen.
  var defaultValueDescription: String { get }

  /// An array of all possible strings that can convert to a value of this
  /// type, for display in the help screen.
  ///
  /// The default implementation of this property returns an empty array. If the
  /// conforming type is also `CaseIterable`, the default implementation returns
  /// an array with a value for each case.
  static var allValueStrings: [String] { get }

  /// A dictionary containing the descriptions for each possible value of this type,
  /// for display in the help screen.
  ///
  /// The default implementation of this property returns an empty dictionary. If
  /// the conforming type is also `CaseIterable`, the default implementation
  /// returns a dictionary with a description for each value as its key-value pair.
  /// Note that the conforming type must implement the
  /// `defaultValueDescription` for each value - if the description and the
  /// value are the same string, it's assumed that a description is not implemented.
  static var allValueDescriptions: [String: String] { get }

  /// The completion kind to use for options or arguments of this type that
  /// don't explicitly declare a completion kind.
  ///
  /// The default implementation of this property returns `.default`.
  static var defaultCompletionKind: CompletionKind { get }
}

extension ExpressibleByArgument {
  public var defaultValueDescription: String {
    "\(self)"
  }

  public static var allValueStrings: [String] { [] }

  public static var allValueDescriptions: [String: String] { [:] }

  public static var defaultCompletionKind: CompletionKind {
    .default
  }
}

extension ExpressibleByArgument where Self: CaseIterable {
  public static var allValueStrings: [String] {
    self.allCases.map { String(describing: $0) }
  }

  public static var defaultCompletionKind: CompletionKind {
    .list(allValueStrings)
  }
}

extension ExpressibleByArgument
where
  Self: CaseIterable, Self: RawRepresentable, RawValue: ExpressibleByArgument
{
  public static var allValueStrings: [String] {
    self.allCases.map(\.rawValue.defaultValueDescription)
  }

  public static var allValueDescriptions: [String: String] {
    self.allCases.reduce(into: [:]) { descriptions, value in
      // Assure that the value and the description are not the same string,
      // otherwise it's assumed that a description is not implemented.
      if value.rawValue.defaultValueDescription != value.defaultValueDescription
      {
        descriptions[value.rawValue.defaultValueDescription] =
          value.defaultValueDescription
      }
    }
  }
}

extension ExpressibleByArgument
where Self: RawRepresentable, RawValue: ExpressibleByArgument {
  public var defaultValueDescription: String {
    rawValue.defaultValueDescription
  }
}

extension String: ExpressibleByArgument {
  public init?(argument: String) {
    self = argument
  }
}

extension RawRepresentable
where Self: ExpressibleByArgument, RawValue: ExpressibleByArgument {
  public init?(argument: String) {
    if let value = RawValue(argument: argument) {
      self.init(rawValue: value)
    } else {
      return nil
    }
  }
}

// MARK: LosslessStringConvertible

extension LosslessStringConvertible where Self: ExpressibleByArgument {
  public init?(argument: String) {
    self.init(argument)
  }
}

extension Int: ExpressibleByArgument {}
extension Int8: ExpressibleByArgument {}
extension Int16: ExpressibleByArgument {}
extension Int32: ExpressibleByArgument {}
extension Int64: ExpressibleByArgument {}
extension UInt: ExpressibleByArgument {}
extension UInt8: ExpressibleByArgument {}
extension UInt16: ExpressibleByArgument {}
extension UInt32: ExpressibleByArgument {}
extension UInt64: ExpressibleByArgument {}

extension Float: ExpressibleByArgument {}
extension Double: ExpressibleByArgument {}

extension Bool: ExpressibleByArgument {}
