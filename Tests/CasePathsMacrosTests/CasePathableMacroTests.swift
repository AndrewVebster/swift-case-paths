import CasePathsMacros
import MacroTesting
import SwiftSyntaxMacros
import XCTest

final class CasePathableMacroTests: XCTestCase {
  override func invokeTest() {
    withMacroTesting(
      // isRecording: true,
      macros: [CasePathableMacro.self]
    ) {
      super.invokeTest()
    }
  }

  func testCasePathable() {
    assertMacro {
      """
      @CasePathable enum Foo {
        case bar
        case baz(Int)
        #if os(macOS)
        case autocomplete
        case secondMissing(String)
        #elseif os(iOS)
        case ios
        #else
        case elseCase
        #endif
      }
      """
    } expansion: {
      """
      enum Foo {
        case bar
        case baz(Int)
        #if os(macOS)
        case autocomplete
        case secondMissing(String)
        #elseif os(iOS)
        case ios
        #else
        case elseCase
        #endif

        struct AllCasePaths {
          var bar: CasePaths.AnyCasePath<Foo, Void> {
            CasePaths.AnyCasePath<Foo, Void>(
              embed: {
                Foo.bar
              },
              extract: {
                guard case .bar = $0 else {
                  return nil
                }
                return ()
              }
            )
          }
          var baz: CasePaths.AnyCasePath<Foo, Int> {
            CasePaths.AnyCasePath<Foo, Int>(
              embed: Foo.baz,
              extract: {
                guard case let .baz(v0) = $0 else {
                  return nil
                }
                return v0
              }
            )
          }

            #if os(macOS)
          var autocomplete: CasePaths.AnyCasePath<Foo, Void> {
            CasePaths.AnyCasePath<Foo, Void>(
              embed: {
                Foo.autocomplete
              },
              extract: {
                guard case .autocomplete = $0 else {
                  return nil
                }
                return ()
              }
            )
          }
          var secondMissing: CasePaths.AnyCasePath<Foo, String> {
            CasePaths.AnyCasePath<Foo, String>(
              embed: Foo.secondMissing,
              extract: {
                guard case let .secondMissing(v0) = $0 else {
                  return nil
                }
                return v0
              }
            )
          }

            #elseif os(iOS)
          var ios: CasePaths.AnyCasePath<Foo, Void> {
            CasePaths.AnyCasePath<Foo, Void>(
              embed: {
                Foo.ios
              },
              extract: {
                guard case .ios = $0 else {
                  return nil
                }
                return ()
              }
            )
          }

            #else
          var elseCase: CasePaths.AnyCasePath<Foo, Void> {
            CasePaths.AnyCasePath<Foo, Void>(
              embed: {
                Foo.elseCase
              },
              extract: {
                guard case .elseCase = $0 else {
                  return nil
                }
                return ()
              }
            )
          }
          #endif
        }
        static var allCasePaths: AllCasePaths { AllCasePaths() }
      }

      extension Foo: CasePaths.CasePathable {
      }
      """
    }
  }

  func testCasePathable_ElementList() {
    assertMacro {
      """
      @CasePathable public enum Foo {
        case bar(Int), baz(String)
      }
      """
    } expansion: {
      """
      public enum Foo {
        case bar(Int), baz(String)

        public struct AllCasePaths {
          public var bar: CasePaths.AnyCasePath<Foo, Int> {
            CasePaths.AnyCasePath<Foo, Int>(
              embed: Foo.bar,
              extract: {
                guard case let .bar(v0) = $0 else {
                  return nil
                }
                return v0
              }
            )
          }
          public var baz: CasePaths.AnyCasePath<Foo, String> {
            CasePaths.AnyCasePath<Foo, String>(
              embed: Foo.baz,
              extract: {
                guard case let .baz(v0) = $0 else {
                  return nil
                }
                return v0
              }
            )
          }
        }
        public static var allCasePaths: AllCasePaths { AllCasePaths() }
      }

      extension Foo: CasePaths.CasePathable {
      }
      """
    }
  }

  func testCasePathable_AccessControl() {
    assertMacro {
      """
      @CasePathable public enum Foo {
        case bar(Int)
      }
      """
    } expansion: {
      """
      public enum Foo {
        case bar(Int)

        public struct AllCasePaths {
          public var bar: CasePaths.AnyCasePath<Foo, Int> {
            CasePaths.AnyCasePath<Foo, Int>(
              embed: Foo.bar,
              extract: {
                guard case let .bar(v0) = $0 else {
                  return nil
                }
                return v0
              }
            )
          }
        }
        public static var allCasePaths: AllCasePaths { AllCasePaths() }
      }

      extension Foo: CasePaths.CasePathable {
      }
      """
    }
    assertMacro {
      """
      @CasePathable package enum Foo {
        case bar(Int)
      }
      """
    } expansion: {
      """
      package enum Foo {
        case bar(Int)

        package struct AllCasePaths {
          package var bar: CasePaths.AnyCasePath<Foo, Int> {
            CasePaths.AnyCasePath<Foo, Int>(
              embed: Foo.bar,
              extract: {
                guard case let .bar(v0) = $0 else {
                  return nil
                }
                return v0
              }
            )
          }
        }
        package static var allCasePaths: AllCasePaths { AllCasePaths() }
      }

      extension Foo: CasePaths.CasePathable {
      }
      """
    }
    assertMacro {
      """
      @CasePathable private enum Foo {
        case bar(Int)
      }
      """
    } expansion: {
      """
      private enum Foo {
        case bar(Int)

        struct AllCasePaths {
          var bar: CasePaths.AnyCasePath<Foo, Int> {
            CasePaths.AnyCasePath<Foo, Int>(
              embed: Foo.bar,
              extract: {
                guard case let .bar(v0) = $0 else {
                  return nil
                }
                return v0
              }
            )
          }
        }
        static var allCasePaths: AllCasePaths { AllCasePaths() }
      }

      extension Foo: CasePaths.CasePathable {
      }
      """
    }
  }

  func testOverloadedCaseName() {
    assertMacro {
      """
      @CasePathable enum Foo {
        case bar(Int)
        case bar(int: Int)
      }
      """
    } diagnostics: {
      """
      @CasePathable enum Foo {
        case bar(Int)
        case bar(int: Int)
             ┬──
             ╰─ 🛑 '@CasePathable' cannot be applied to overloaded case name 'bar'
      }
      """
    }
  }

  func testRequiresEnum() {
    assertMacro {
      """
      @CasePathable struct Foo {
      }
      """
    } diagnostics: {
      """
      @CasePathable struct Foo {
                    ┬─────
                    ╰─ 🛑 '@CasePathable' cannot be applied to struct type 'Foo'
      }
      """
    }
  }

  func testRedundantConformances() {
    assertMacro {
      """
      @CasePathable enum Foo: CasePathable {
      }
      """
    } expansion: {
      """
      enum Foo: CasePathable {

          struct AllCasePaths {

          }
          static var allCasePaths: AllCasePaths { AllCasePaths() }
      }
      """
    }
    assertMacro {
      """
      @CasePathable enum Foo: CasePaths.CasePathable {
      }
      """
    } expansion: {
      """
      enum Foo: CasePaths.CasePathable {

          struct AllCasePaths {

          }
          static var allCasePaths: AllCasePaths { AllCasePaths() }
      }
      """
    }
  }

  func testWildcard() {
    assertMacro {
      """
      @CasePathable enum Foo {
        case bar(_ int: Int, _ bool: Bool)
      }
      """
    } expansion: {
      """
      enum Foo {
        case bar(_ int: Int, _ bool: Bool)

        struct AllCasePaths {
          var bar: CasePaths.AnyCasePath<Foo, (Int, Bool)> {
            CasePaths.AnyCasePath<Foo, (Int, Bool)>(
              embed: Foo.bar,
              extract: {
                guard case let .bar(v0, v1) = $0 else {
                  return nil
                }
                return (v0, v1)
              }
            )
          }
        }
        static var allCasePaths: AllCasePaths { AllCasePaths() }
      }

      extension Foo: CasePaths.CasePathable {
      }
      """
    }
  }

  func testSelf() {
    assertMacro {
      """
      @CasePathable enum Foo {
        case bar(Bar<Self>)
      }
      """
    } expansion: {
      """
      enum Foo {
        case bar(Bar<Self>)

        struct AllCasePaths {
          var bar: CasePaths.AnyCasePath<Foo, Bar<Foo>> {
            CasePaths.AnyCasePath<Foo, Bar<Foo>>(
              embed: Foo.bar,
              extract: {
                guard case let .bar(v0) = $0 else {
                  return nil
                }
                return v0
              }
            )
          }
        }
        static var allCasePaths: AllCasePaths { AllCasePaths() }
      }

      extension Foo: CasePaths.CasePathable {
      }
      """
    }
  }

  func testDefaults() {
    assertMacro {
      """
      @CasePathable enum Foo {
        case bar(int: Int = 42, bool: Bool = true)
      }
      """
    } expansion: {
      """
      enum Foo {
        case bar(int: Int = 42, bool: Bool = true)

        struct AllCasePaths {
          var bar: CasePaths.AnyCasePath<Foo, (int: Int, bool: Bool)> {
            CasePaths.AnyCasePath<Foo, (int: Int, bool: Bool)>(
              embed: Foo.bar,
              extract: {
                guard case let .bar(v0, v1) = $0 else {
                  return nil
                }
                return (v0, v1)
              }
            )
          }
        }
        static var allCasePaths: AllCasePaths { AllCasePaths() }
      }

      extension Foo: CasePaths.CasePathable {
      }
      """
    }
  }

}
