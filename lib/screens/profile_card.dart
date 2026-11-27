import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/dates.dart';
import '../data/app_store.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// Round profile picture: the user's photo, or their initial on the hero colour.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, this.size = 84});

  final double size;

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final bytes = store.photoBytes;
    final name = store.data.name.trim();
    final initial = name.isEmpty ? '' : name.characters.first.toUpperCase();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.night,
        border: Border.all(color: AppColors.peach, width: 3),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: bytes != null
          ? Image.memory(
              bytes,
              width: size,
              height: size,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              errorBuilder: (_, __, ___) => Icon(Icons.person, color: AppColors.nightSoft, size: size * 0.5),
            )
          : initial.isEmpty
          ? Icon(Icons.person, color: AppColors.nightSoft, size: size * 0.5)
          : Text(
              initial,
              style: AppText.body(size * 0.4, weight: FontWeight.w800, color: AppColors.nightInk),
            ),
    );
  }
}

/// Photo, name and "member since", with editing for both.
class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    final d = store.data;
    final hasName = d.name.trim().isNotEmpty;
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Semantics(
            button: true,
            label: 'Change profile photo',
            child: GestureDetector(
              onTap: () => showPhotoOptions(context),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const ProfileAvatar(),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.card, width: 3),
                      ),
                      child: Icon(Icons.photo_camera_outlined, size: 16, color: AppColors.onAccent),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasName ? d.name : 'Add your name',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.body(20, weight: FontWeight.w800, color: hasName ? AppColors.ink : AppColors.muted),
                ),
                const SizedBox(height: 2),
                Text(
                  'Member since ${shortDate(d.firstUse)} ${d.firstUse.year}',
                  style: AppText.body(13, color: AppColors.muted),
                ),
                const SizedBox(height: 6),
                TextButton.icon(
                  onPressed: () => showEditName(context),
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 36)),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: Text(hasName ? 'Edit name' : 'Add name'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> showPhotoOptions(BuildContext context) {
  final store = StoreScope.read(context);
  final hasPhoto = store.data.photoBase64.isNotEmpty;
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.card,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (sheet) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.line, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text('Profile photo', style: AppText.body(18, weight: FontWeight.w800)),
            ),
            const SizedBox(height: 8),
            _SheetOption(
              icon: Icons.photo_library_outlined,
              label: 'Choose from gallery',
              onTap: () {
                Navigator.of(sheet).pop();
                _pickPhoto(context, ImageSource.gallery);
              },
            ),
            _SheetOption(
              icon: Icons.photo_camera_outlined,
              label: 'Take a photo',
              onTap: () {
                Navigator.of(sheet).pop();
                _pickPhoto(context, ImageSource.camera);
              },
            ),
            if (hasPhoto)
              _SheetOption(
                icon: Icons.delete_outline,
                label: 'Remove photo',
                color: AppColors.danger,
                onTap: () {
                  Navigator.of(sheet).pop();
                  store.update((d) => d.photoBase64 = '');
                },
              ),
          ],
        ),
      ),
    ),
  );
}

Future<void> _pickPhoto(BuildContext context, ImageSource source) async {
  final store = StoreScope.read(context);
  final messenger = ScaffoldMessenger.maybeOf(context);
  try {
    // Resized and compressed on the device, so the saved photo stays small.
    final file = await ImagePicker().pickImage(source: source, maxWidth: 512, maxHeight: 512, imageQuality: 82);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) return;
    store.update((d) => d.photoBase64 = base64Encode(bytes));
  } catch (e) {
    debugPrint('Photo pick failed: $e');
    final where = source == ImageSource.camera ? 'camera' : 'gallery';
    messenger?.showSnackBar(
      SnackBar(content: Text('Could not open the $where. Please allow access in your phone settings and try again.')),
    );
  }
}

Future<void> showEditName(BuildContext context) async {
  final store = StoreScope.read(context);
  final result = await showDialog<String>(
    context: context,
    builder: (_) => _NameDialog(initial: store.data.name),
  );
  if (result == null) return;
  store.update((d) => d.name = result.trim());
}

class _NameDialog extends StatefulWidget {
  const _NameDialog({required this.initial});

  final String initial;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final TextEditingController _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.card,
      title: Text('Your name', style: AppText.body(18, weight: FontWeight.w700)),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 30,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.done,
        style: AppText.body(16),
        onSubmitted: (v) => Navigator.of(context).pop(v),
        decoration: const InputDecoration(hintText: 'Your name', counterText: ''),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.of(context).pop(_controller.text), child: const Text('Save')),
      ],
    );
  }
}

class _SheetOption extends StatelessWidget {
  const _SheetOption({required this.icon, required this.label, required this.onTap, this.color});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.ink;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: c),
              const SizedBox(width: 14),
              Text(
                label,
                style: AppText.body(15, weight: FontWeight.w600, color: c),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
