import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/profile/widgets/profile_widgets.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
import 'package:rider_app/driver_features/profile/screens/tickets/additional_details_screen.dart';
import 'package:rider_app/driver_features/profile/screens/tickets/ticket_widgets.dart';

class AddPhotosScreen extends StatefulWidget {
  const AddPhotosScreen({super.key, required this.category, required this.problem});

  final String category;
  final String problem;

  @override
  State<AddPhotosScreen> createState() => _AddPhotosScreenState();
}

class _AddPhotosScreenState extends State<AddPhotosScreen> {
  final _photos = <String>[];

  Future<void> _add() async {
    final photo = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (photo == null) return;
    setState(() => _photos.add(photo.path));
  }

  @override
  Widget build(BuildContext context) {
    return ProfilePage(
      title: 'Add Photos',
      trailing: Icon(Icons.help_outline_rounded, color: profileAccent(context)),
      bottom: ticketFilled(context, AppStrings.continueAction, () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => AdditionalDetailsScreen(
              category: widget.category,
              problem: widget.problem,
              photos: List<String>.from(_photos),
            ),
          ),
        );
      }),
      child: ListView(
        padding: EdgeInsets.fromLTRB(context.w(20), 0, context.w(20), context.h(12)),
        children: [
          Text(
            'Add clear photos to help us understand the issue (Optional)',
            style: AppTypography.regular.copyWith(fontSize: 13, color: context.torkk.textSecondary),
          ),
          SizedBox(height: context.h(14)),
          Wrap(
            spacing: context.w(10),
            runSpacing: context.h(10),
            children: [
              _addTile(context),
              for (var i = 0; i < _photos.length; i++)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(context.r(12)),
                      child: Image.file(File(_photos[i]), width: context.w(96), height: context.w(96), fit: BoxFit.cover),
                    ),
                    Positioned(
                      right: 4,
                      top: 4,
                      child: GestureDetector(
                        onTap: () => setState(() => _photos.removeAt(i)),
                        child: const CircleAvatar(radius: 10, backgroundColor: Colors.black54, child: Icon(Icons.close, size: 12, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          SizedBox(height: context.h(16)),
          Container(
            padding: EdgeInsets.all(context.w(12)),
            decoration: BoxDecoration(color: context.adaptiveTint(const Color(0xFFF5F3FF)), borderRadius: BorderRadius.circular(context.r(12))),
            child: Row(
              children: [
                Icon(Icons.photo_camera_outlined, color: profileAccent(context), size: context.w(18)),
                SizedBox(width: context.w(8)),
                Expanded(
                  child: Text(
                    'Take photos of the location , parcel or any relevant details.',
                    style: AppTypography.regular.copyWith(fontSize: 12, color: context.torkk.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _addTile(BuildContext context) {
    return GestureDetector(
      onTap: _add,
      child: Container(
        width: context.w(96),
        height: context.w(96),
        decoration: BoxDecoration(
          color: context.adaptiveTint(const Color(0xFFF5F3FF)),
          borderRadius: BorderRadius.circular(context.r(12)),
          border: Border.all(color: const Color(0xFFE9D5FF)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_camera_outlined, color: profileAccent(context)),
            Text('Add Photo', style: AppTypography.regular.copyWith(fontSize: 11, color: profileAccent(context))),
          ],
        ),
      ),
    );
  }
}
