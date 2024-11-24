class DocumentData {
  final String documentType;
  final String fullName;
  final String documentNumber;
  final DateTime? birthDate;
  final DateTime? expiryDate;

  DocumentData({
    required this.documentType,
    required this.fullName,
    required this.documentNumber,
    this.birthDate,
    this.expiryDate,
  });
} 