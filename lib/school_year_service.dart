// services/school_year_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SchoolYearService {
  final FirebaseFirestore _firestore;
  String? _currentSchoolYear;

  SchoolYearService(this._firestore);

  Future<String> getCurrentSchoolYear() async {
    try {
      if (_currentSchoolYear == null) {
        final doc = await _firestore.collection('Settings').doc('SchoolYear').get();
        if (doc.exists) {
          _currentSchoolYear = doc.data()?['active'] as String?;
        }
        
        if (_currentSchoolYear == null) {
          _currentSchoolYear = await _initializeDefaultSchoolYear();
        }
      }
      return _currentSchoolYear!;
    } catch (e) {
      debugPrint('Error getting school year: $e');
      return '2024-2025'; // Fallback value
    }
  }

  Future<String> _initializeDefaultSchoolYear() async {
    final defaultYear = '2024-2025';
    await _firestore.collection('Settings').doc('SchoolYear').set({
      'active': defaultYear,
      'updatedAt': FieldValue.serverTimestamp()
    });
    return defaultYear;
  }

  Stream<String> get schoolYearStream {
    return _firestore.collection('Settings').doc('SchoolYear')
      .snapshots()
      .map((snapshot) => snapshot.data()?['active'] as String? ?? '2024-2025');
  }
}