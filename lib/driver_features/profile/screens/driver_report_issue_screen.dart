import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rider_app/service/api_client.dart';
import 'package:rider_app/common/constants/app_urls.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

// --- REPORT ISSUE SCREEN ---
class DriverReportIssueScreen extends StatefulWidget {
  const DriverReportIssueScreen({super.key});

  @override
  State<DriverReportIssueScreen> createState() =>
      _DriverReportIssueScreenState();
}

class _DriverReportIssueScreenState extends State<DriverReportIssueScreen> {
  final _descController = TextEditingController();
  String _selectedIssueType = 'App Bug';
  bool _submitting = false;

  final List<String> _issueTypes = [
    'App Bug',
    'Payment Issue',
    'Navigation Problem',
    'Customer Dispute',
    'Other',
  ];

  Future<void> _submitIssue() async {
    final desc = _descController.text.trim();
    if (desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe the issue.')),
      );
      return;
    }

    setState(() => _submitting = true);
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('user_phone') ?? '';

    final urlString = AppUrls.reportIssue;
    debugPrint('[DEBUG REPORT ISSUE] Submitting to URL: $urlString');
    debugPrint(
      '[DEBUG REPORT ISSUE] Payload: phone=$phone, type=$_selectedIssueType, desc=$desc',
    );

    try {
      final response = await apiClient.post(
        Uri.parse(urlString),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
          'issue_type': _selectedIssueType,
          'description': desc,
        }),
      );

      debugPrint(
        '[DEBUG REPORT ISSUE] Response Status Code: ${response.statusCode}',
      );
      debugPrint('[DEBUG REPORT ISSUE] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        if (mounted) {
          _descController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Issue reported successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        throw Exception(
          'Failed to report issue: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('[DEBUG REPORT ISSUE] ERROR: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit issue: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF4F46E5);
    return Scaffold(
      backgroundColor: context.torkk.surfaceMuted,
      appBar: AppBar(
        title: const Text(
          'Report Issue',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: context.torkk.background,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _submitting
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'File a Support Ticket',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: context.torkk.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Describe any problems you encountered and our team will review and resolve it.',
                    style: TextStyle(
                      color: context.torkk.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Issue Type',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: context.torkk.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: context.torkk.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.torkk.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedIssueType,
                        isExpanded: true,
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedIssueType = val);
                          }
                        },
                        items: _issueTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Description',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: context.torkk.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descController,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: 'Provide details about the issue...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      filled: true,
                      fillColor: context.torkk.surface,
                    ),
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitIssue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Submit Report',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
