/// Carries the authenticated user's segment identifier used by ThemeRules
/// to select the active theme variant.
class UserContext {
  final String? segment;

  const UserContext({this.segment});

  /// Factory constructor representing an anonymous/unauthenticated user context.
  factory UserContext.anonymous() => const UserContext(segment: 'anonymous');

  /// Helper to check if the current user context is anonymous.
  bool get isAnonymous => segment == null || segment == 'anonymous';
}
