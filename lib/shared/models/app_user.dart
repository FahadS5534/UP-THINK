enum UserRole { student, facilitator, admin }

/// Upthink User Profile Model
class AppUser {
  final String id;
  final String email;
  final String fullName;
  final String? avatarUrl;
  final UserRole role;
  final String university;
  final String department;
  final String academicLevel;
  final String remediationAggression;
  final bool latexRendering;
  final bool ragCitations;
  final bool dynamicCalibration;
  final bool interventionAlerts;
  final double studyVolumeHours;
  final int masteredNodesCount;
  final int diagnosticsPassedCount;
  final int cohortPercentile;

  const AppUser({
    required this.id,
    required this.email,
    required this.fullName,
    this.avatarUrl,
    required this.role,
    this.university = 'University of Oxford',
    this.department = 'Mathematical Institute & Computer Science',
    this.academicLevel = 'Undergraduate Scholar • MMath CompSci',
    this.remediationAggression = 'intensive',
    this.latexRendering = true,
    this.ragCitations = true,
    this.dynamicCalibration = true,
    this.interventionAlerts = true,
    this.studyVolumeHours = 64.5,
    this.masteredNodesCount = 148,
    this.diagnosticsPassedCount = 18,
    this.cohortPercentile = 88,
  });

  bool get isFacilitator => role == UserRole.facilitator || role == UserRole.admin;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    UserRole parsedRole = UserRole.student;
    final roleStr = (json['role'] as String?)?.toUpperCase();
    if (roleStr == 'FACILITATOR') {
      parsedRole = UserRole.facilitator;
    } else if (roleStr == 'ADMIN') {
      parsedRole = UserRole.admin;
    }

    return AppUser(
      id: json['id'] as String? ?? 'user-demo-1',
      email: json['email'] as String? ?? 'elena.vass@oxford.ac.uk',
      fullName: json['full_name'] as String? ?? 'Elena Vass',
      avatarUrl: json['avatar_url'] as String?,
      role: parsedRole,
      university: json['university'] as String? ?? 'University of Oxford',
      department: json['department'] as String? ?? 'Mathematical Institute & Computer Science',
      academicLevel: json['academic_level'] as String? ?? 'Undergraduate Scholar • MMath CompSci',
      remediationAggression: json['remediation_aggression'] as String? ?? 'intensive',
      latexRendering: json['latex_rendering'] as bool? ?? true,
      ragCitations: json['rag_citations'] as bool? ?? true,
      dynamicCalibration: json['dynamic_calibration'] as bool? ?? true,
      interventionAlerts: json['intervention_alerts'] as bool? ?? true,
      studyVolumeHours: (json['study_volume_hours'] as num?)?.toDouble() ?? 64.5,
      masteredNodesCount: (json['mastered_nodes_count'] as num?)?.toInt() ?? 148,
      diagnosticsPassedCount: (json['diagnostics_passed_count'] as num?)?.toInt() ?? 18,
      cohortPercentile: (json['cohort_percentile'] as num?)?.toInt() ?? 88,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'role': role == UserRole.facilitator ? 'FACILITATOR' : 'STUDENT',
      'university': university,
      'department': department,
      'academic_level': academicLevel,
      'remediation_aggression': remediationAggression,
      'latex_rendering': latexRendering,
      'rag_citations': ragCitations,
      'dynamic_calibration': dynamicCalibration,
      'intervention_alerts': interventionAlerts,
      'study_volume_hours': studyVolumeHours,
      'mastered_nodes_count': masteredNodesCount,
      'diagnostics_passed_count': diagnosticsPassedCount,
      'cohort_percentile': cohortPercentile,
    };
  }

  AppUser copyWith({
    String? fullName,
    String? avatarUrl,
    UserRole? role,
    String? university,
    String? department,
    String? academicLevel,
    String? remediationAggression,
    bool? latexRendering,
    bool? ragCitations,
    bool? dynamicCalibration,
    bool? interventionAlerts,
  }) {
    return AppUser(
      id: id,
      email: email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      university: university ?? this.university,
      department: department ?? this.department,
      academicLevel: academicLevel ?? this.academicLevel,
      remediationAggression: remediationAggression ?? this.remediationAggression,
      latexRendering: latexRendering ?? this.latexRendering,
      ragCitations: ragCitations ?? this.ragCitations,
      dynamicCalibration: dynamicCalibration ?? this.dynamicCalibration,
      interventionAlerts: interventionAlerts ?? this.interventionAlerts,
      studyVolumeHours: studyVolumeHours,
      masteredNodesCount: masteredNodesCount,
      diagnosticsPassedCount: diagnosticsPassedCount,
      cohortPercentile: cohortPercentile,
    );
  }
}
