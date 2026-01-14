import '../models/application_model.dart';
import 'database_service.dart';

class ApplicationService {
  final DatabaseService _db = DatabaseService.instance;

  Future<void> submitApplication(Application application) async {
    await _db.createApplication(application.toMap());
  }

  Future<List<Application>> getAllApplications() async {
    final maps = await _db.getAllApplications();
    return maps.map((m) => Application.fromMap(m)).toList();
  }

  Future<List<Application>> getApplicationsByUserId(String userId) async {
    final maps = await _db.getApplicationsByUserId(userId);
    return maps.map((m) => Application.fromMap(m)).toList();
  }

  Future<List<Application>> getApplicationsByStatus(ApplicationStatus status) async {
    final maps = await _db.getApplicationsByStatus(status.toString().split('.').last);
    return maps.map((m) => Application.fromMap(m)).toList();
  }

  Future<Map<String, int>> getApplicationStats() async {
    final applications = await getAllApplications();
    
    return {
      'pending': applications.where((a) => a.status == ApplicationStatus.pending).length,
      'approved': applications.where((a) => a.status == ApplicationStatus.approved).length,
      'rejected': applications.where((a) => a.status == ApplicationStatus.rejected).length,
      'inReview': applications.where((a) => a.status == ApplicationStatus.inReview).length,
    };
  }

  Future<double> getTotalApprovedAmount() async {
    final applications = await getAllApplications();
    double total = 0;
    
    for (var app in applications) {
      if (app.status == ApplicationStatus.approved && app.approvedAmount != null) {
        total += app.approvedAmount!;
      }
    }
    
    return total;
  }

  Future<void> approveApplication(String applicationId, double amount, String staffId) async {
    await _db.updateApplication(applicationId, {
      'status': 'approved',
      'approvedAmount': amount,
      'reviewedBy': staffId,
      'reviewedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> rejectApplication(String applicationId, String reason, String staffId) async {
    await _db.updateApplication(applicationId, {
      'status': 'rejected',
      'rejectionReason': reason,
      'reviewedBy': staffId,
      'reviewedAt': DateTime.now().toIso8601String(),
    });
  }
}
