/// Typed actions recorded in the immutable audit trail (Milestone 9.3).
enum AuditAction {
  create('CREATE', 'Created'),
  update('UPDATE', 'Modified'),
  voidRecord('VOID', 'Voided'),
  delete('DELETE', 'Deleted');

  final String code;
  final String displayName;

  const AuditAction(this.code, this.displayName);

  static AuditAction fromCode(String code) {
    return AuditAction.values.firstWhere(
      (a) => a.code.toUpperCase() == code.trim().toUpperCase(),
      orElse: () => AuditAction.update,
    );
  }
}
