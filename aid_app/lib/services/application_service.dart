import '../models/application_model.dart';
import 'database_service.dart';
import 'notification_service.dart';

class ApplicationService {
  final DatabaseService _db = DatabaseService.instance;

  Future<void> submitApplication(Application application) async {
    await _db.createApplication(application.toMap());
    final staff = await _db.getStaffUsers();
    final staffIds = staff.map((u) => (u['id'] as String?) ?? '').where((id) => id.isNotEmpty).toList();
    final tokensMap = await _db.getTokensForUsers(staffIds);
    for (final user in staff) {
      final staffId = (user['id'] as String?) ?? '';
      if (staffId.isEmpty) continue;
      await NotificationService.instance.enqueueNotification(
        recipientId: staffId,
        title: 'Новое заявление',
        body: 'Студент ${application.fullName} отправил заявление',
        type: 'application_submitted',
        payload: {'applicationId': application.id, 'applicantId': application.userId},
        senderId: application.userId,
      );
      final tokens = tokensMap[staffId] ?? const <String>[];
      await NotificationService.instance.sendPushToTokens(
        tokens: tokens,
        title: 'Новое заявление',
        body: 'Студент ${application.fullName} отправил заявление',
        data: {'applicationId': application.id},
      );
    }
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

    final application = await _db.getApplicationById(applicationId);
    final recipientId = application?['userId'] as String? ?? '';
    if (recipientId.isNotEmpty) {
      final tokensMap = await _db.getTokensForUsers([recipientId]);
      final tokens = tokensMap[recipientId] ?? const <String>[];
      await NotificationService.instance.enqueueNotification(
        recipientId: recipientId,
        title: 'Заявление одобрено',
        body: 'Сумма к выплате: $amount',
        type: 'application_approved',
        payload: {'applicationId': applicationId, 'amount': amount},
        senderId: staffId,
      );
      await NotificationService.instance.sendPushToTokens(
        tokens: tokens,
        title: 'Заявление одобрено',
        body: 'Сумма к выплате: $amount',
        data: {'applicationId': applicationId, 'amount': amount},
      );
    }
  }

  Future<void> rejectApplication(String applicationId, String reason, String staffId) async {
    await _db.updateApplication(applicationId, {
      'status': 'rejected',
      'rejectionReason': reason,
      'reviewedBy': staffId,
      'reviewedAt': DateTime.now().toIso8601String(),
    });

    final application = await _db.getApplicationById(applicationId);
    final recipientId = application?['userId'] as String? ?? '';
    if (recipientId.isNotEmpty) {
      final tokensMap = await _db.getTokensForUsers([recipientId]);
      final tokens = tokensMap[recipientId] ?? const <String>[];
      await NotificationService.instance.enqueueNotification(
        recipientId: recipientId,
        title: 'Заявление отклонено',
        body: reason,
        type: 'application_rejected',
        payload: {'applicationId': applicationId},
        senderId: staffId,
      );
      await NotificationService.instance.sendPushToTokens(
        tokens: tokens,
        title: 'Заявление отклонено',
        body: reason,
        data: {'applicationId': applicationId},
      );
    }
  }
}
