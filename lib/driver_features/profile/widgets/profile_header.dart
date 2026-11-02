import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';
import 'package:rider_app/service/driver_api_service.dart';

class ProfileHeader extends StatefulWidget {
  const ProfileHeader({super.key});

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  String _name = '';
  String _phone = '';
  String _photoUrl = '';

  /// The photo just picked, shown right away (the upload response can come
  /// back with an empty url).
  String _localPhotoPath = '';
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _phone = prefs.getString('user_phone') ?? '';
    if (mounted) {
      setState(() {
        _name = prefs.getString('user_name') ?? '';
        _photoUrl = prefs.getString('profile_photo_url') ?? '';
      });
    }
    debugPrint('PROFILE_FETCH | profile screen opened, phone="$_phone"');
    if (_phone.isEmpty) return;
    try {
      final profile = await DriverApiService.fetchProfile(_phone);
      final name = _profileField(profile, 'name');
      final photo = _profileField(profile, 'profile_photo_url');
      debugPrint('PROFILE_FETCH | name="$name" photo="$photo"');
      if (!mounted) return;
      setState(() {
        if (name.isNotEmpty) _name = name;
        if (photo.isNotEmpty) _photoUrl = photo;
      });
      if (name.isNotEmpty) await prefs.setString('user_name', name);
      if (photo.isNotEmpty) await prefs.setString('profile_photo_url', photo);
    } catch (e) {
      debugPrint('PROFILE_PHOTO_03 | profile load failed: $e');
    }
  }

  /// Reads [key] from the profile response whether it is at the top level or
  /// inside a `profile` / `data` wrapper.
  String _profileField(Map<String, dynamic> response, String key) {
    for (final source in [response, response['profile'], response['data']]) {
      if (source is Map) {
        final value = (source[key] ?? '').toString().trim();
        if (value.isNotEmpty) return value;
      }
    }
    return '';
  }

  Future<ImageSource?> _chooseSource() {
    return showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  void _toast(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red : null,
      ),
    );
  }

  Future<void> _changePhoto() async {
    if (_uploading) return;
    debugPrint('PROFILE_PHOTO_01 | camera icon tapped');
    final source = await _chooseSource();
    if (source == null || !mounted) return;
    try {
      final image = await ImagePicker().pickImage(
        source: source,
        imageQuality: 70,
      );
      if (image == null) {
        debugPrint('PROFILE_PHOTO_01A | picker closed without a photo');
        return;
      }
      setState(() => _uploading = true);
      var url = await DriverApiService.uploadProfilePhoto(filePath: image.path);
      debugPrint('PROFILE_PHOTO_02 | uploaded url=$url');
      if (url.isEmpty && _phone.isNotEmpty) {
        // The upload response carried no url: read it from the saved profile.
        try {
          final profile = await DriverApiService.fetchProfile(_phone);
          url = _profileField(profile, 'profile_photo_url');
          debugPrint('PROFILE_PHOTO_02A | url from profile=$url');
        } catch (e) {
          debugPrint('PROFILE_PHOTO_02B | profile refetch failed: $e');
        }
      }
      if (url.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_photo_url', url);
      }
      if (!mounted) return;
      setState(() {
        if (url.isNotEmpty) _photoUrl = url;
        _localPhotoPath = image.path;
        _uploading = false;
      });
      _toast('Profile photo updated');
    } catch (e) {
      debugPrint('PROFILE_PHOTO_04 | failed: $e');
      if (!mounted) return;
      setState(() => _uploading = false);
      _toast(
        'Could not update photo: ${e.toString().replaceFirst('Exception: ', '')}',
        error: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = profileAccent(context);
    return Column(
      children: [
        Stack(
          children: [
            GestureDetector(
              onTap: _changePhoto,
              child: Container(
                width: context.w(100),
                height: context.w(100),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accent.withValues(alpha: 0.28),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (_localPhotoPath.isNotEmpty)
                      Image.file(
                        File(_localPhotoPath),
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Icon(
                          Icons.person,
                          color: accent,
                          size: context.w(40),
                        ),
                      )
                    else if (_photoUrl.isNotEmpty)
                      Image.network(
                        _photoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Icon(
                          Icons.person,
                          color: accent,
                          size: context.w(40),
                        ),
                      )
                    else
                      Icon(Icons.person, color: accent, size: context.w(40)),
                    if (_uploading)
                      const ColoredBox(
                        color: Color(0x66000000),
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: context.h(6),
              child: GestureDetector(
                onTap: _changePhoto,
                child: Container(
                  width: context.w(28),
                  height: context.w(28),
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(
                    Icons.photo_camera_rounded,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: context.w(13),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: context.h(8)),
        Text(
          _name.isEmpty ? 'Driver Partner' : _name,
          textAlign: TextAlign.center,
          style: AppTypography.bold.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
