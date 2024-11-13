class Student {
  final String firstName;
  final String lastName;
  final String gradeLevel;
  final String gender;
  final String profilePictureUrl;
  final Map<String, dynamic> progress;

  Student({
    required this.firstName,
    required this.lastName,
    required this.gradeLevel,
    required this.gender,
    required this.profilePictureUrl,
    required this.progress,
  });

  factory Student.fromFirestore(Map<String, dynamic> data) {
    return Student(
      firstName: data['firstName'] ?? 'Unknown',
      lastName: data['lastName'] ?? 'Unknown',
      gradeLevel: data['gradeLevel'] ?? 'Unknown',
      gender: data['gender'] ?? 'Unknown',
      profilePictureUrl: data['profilePictureUrl'] ?? '',
      progress: data['progress'] ?? {},
    );
  }

  get id => null;
}
