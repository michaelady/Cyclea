/// Compile-time switches. Production web and Android builds leave these off.
///
/// Tester tools (seed demo data) are hidden unless the build passes
/// `--dart-define=CYCLEA_TESTER_TOOLS=true`.
class CycleaFlags {
  static const testerTools = bool.fromEnvironment('CYCLEA_TESTER_TOOLS');
}
