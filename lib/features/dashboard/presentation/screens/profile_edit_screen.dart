import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/rpg_avatar.dart';
import '../../../../core/widgets/cyber_manhwa_background.dart';
import '../../../../core/widgets/system_snack.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/dashboard_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;
  String _selectedLanguage = 'es';
  String _currentAvatarUrl = 'warrior';
  bool _isSaving = false;

  // Profile field state (sin stat points: STR/INT/DEX/LUK ya no se usan).
  // P-11g: solo el id; el nombre visible sale de l10n (`_className`).
  final List<String> _hunterClasses = [
    'warrior',
    'mage',
    'assassin',
    'necromancer',
    'priest',
  ];

  String _className(String id) {
    final l10n = AppLocalizations.of(context);
    switch (id) {
      case 'warrior':
        return l10n?.profile_edit_class_warrior ?? 'WARRIOR';
      case 'mage':
        return l10n?.profile_edit_class_mage ?? 'MAGE';
      case 'assassin':
        return l10n?.profile_edit_class_assassin ?? 'ASSASSIN';
      case 'necromancer':
        return l10n?.profile_edit_class_necromancer ?? 'NECROMANCER';
      case 'priest':
        return l10n?.profile_edit_class_priest ?? 'PRIEST';
      default:
        return id.toUpperCase();
    }
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _bioController = TextEditingController();

    // Prepopulate values once profile data is loaded
    Future.microtask(() {
      final profile = ref.read(userProfileProvider).value;
      if (profile != null) {
        _nameController.text = profile['display_name'] as String? ?? '';
        _selectedLanguage = profile['native_language'] as String? ?? 'es';
        _currentAvatarUrl = profile['avatar_url'] as String? ?? 'warrior';
        _bioController.text = profile['bio'] as String? ?? '';
        setState(() {});
      } else {
        final authUser = ref.read(currentUserProvider);
        _nameController.text = authUser?.userMetadata?['full_name'] ?? authUser?.email?.split('@').first ?? '';
        _currentAvatarUrl = 'warrior';
        setState(() {});
      }
    });
  }

  String _formatBio() => _bioController.text.trim();

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: source,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 85,
      );

      if (image == null) return;

      setState(() {
      });

      final user = ref.read(currentUserProvider);
      if (user == null) return;

      final supabase = ref.read(supabaseClientProvider);
      final bytes = await image.readAsBytes();
      final fileExt = image.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = 'avatars/${user.id}/$fileName';

      // Upload binary to avatars bucket
      await supabase.storage.from('avatars').uploadBinary(
            filePath,
            bytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      // Get public URL
      final publicUrl = supabase.storage.from('avatars').getPublicUrl(filePath);

      setState(() {
        _currentAvatarUrl = publicUrl;
      });

      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)?.profile_edit_photo_ok ?? 'PHOTO UPLOADED SUCCESSFULY 📸',
              style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            backgroundColor: AppColors.emeraldGreen,
            behavior: SnackBarBehavior.floating,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4.0))),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
        });
      }
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'ERROR UPLOADING IMAGE: $e',
              style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            backgroundColor: AppColors.crimsonRed,
            behavior: SnackBarBehavior.floating,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4.0))),
          ),
        );
      }
    }
  }

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.sheetBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
      isScrollControlled: true,
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.profile_edit_choose_photo,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.camera);
                        },
                        icon: const Icon(Icons.camera_alt_rounded),
                        label: Text(l10n.profile_edit_camera, style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.onSurface.withValues(alpha: 0.05),
                          foregroundColor: AppColors.onSurface,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(4.0)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.gallery);
                        },
                        icon: const Icon(Icons.photo_library_rounded),
                        label: Text(l10n.profile_edit_gallery, style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.onSurface.withValues(alpha: 0.05),
                          foregroundColor: AppColors.onSurface,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(4.0)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(currentUserProvider);
    final progressAsync = ref.watch(userProgressProvider);
    final progress = progressAsync.value ?? {};
    final String cefrCode = progress['level_code'] as String? ?? 'B1';

    // Ranks based on level
    final String rank = cefrCode == 'A1' ? 'D-RANK' :
                        cefrCode == 'A2' ? 'C-RANK' :
                        cefrCode == 'B1' ? 'B-RANK' :
                        cefrCode == 'B2' ? 'A-RANK' : 'S-RANK';

    return Scaffold(
      body: CyberManhwaBackground(
        bgMode: CyberBgMode.hunterStatus,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Custom Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Row(
                  children: [
                    Material(
                      color: AppColors.onSurface.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(4.0),
                      child: InkWell(
                        onTap: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/home');
                          }
                        },
                        child: const SizedBox(
                          width: 44,
                          height: 44,
                          child: Icon(Icons.arrow_back_rounded, color: AppColors.onSurface),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        l10n.profile_edit_license_registry,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.onSurface,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Main Sheet Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Hunter License Card Preview
                        GlassCard(
                          blur: 25,
                          opacity: AppColors.glassOpacity,
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  RpgAvatar(
                                    avatarUrl: _currentAvatarUrl,
                                    initials: _nameController.text.isNotEmpty
                                        ? _nameController.text.substring(0, _nameController.text.length > 1 ? 2 : 1)
                                        : 'H',
                                    size: 80,
                                    hunterClass: _currentAvatarUrl,
                                  ),
                                  GestureDetector(
                                    onTap: _showAvatarPicker,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: AppColors.runeViolet,
                                        borderRadius: BorderRadius.all(Radius.circular(4)),
                                      ),
                                      padding: const EdgeInsets.all(6),
                                      child: const Icon(Icons.photo_camera_rounded, color: AppColors.onSurface, size: 14),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: AppColors.manaCyan, width: 1),
                                        borderRadius: BorderRadius.circular(AppRadius.sm),
                                      ),
                                      child: Text(
                                        rank,
                                        style: GoogleFonts.jetBrainsMono(
                                          color: AppColors.manaCyan,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      _nameController.text.toUpperCase().isNotEmpty
                                          ? _nameController.text.toUpperCase()
                                          : l10n.profile_edit_hunter_name,
                                      style: GoogleFonts.spaceGrotesk(
                                        color: AppColors.onSurface,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 18,
                                        letterSpacing: 0.5,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      l10n.profile_edit_class_path(_currentAvatarUrl.toUpperCase()),
                                      style: GoogleFonts.jetBrainsMono(
                                        color: AppColors.onSurfaceVariant,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Section: Class Path Selection
                        Text(
                          l10n.profile_edit_select_class,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: AppColors.manaCyan,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _hunterClasses.map((hc) {
                            final isSelected = _currentAvatarUrl == hc;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _currentAvatarUrl = hc;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.runeViolet.withValues(alpha: 0.2)
                                      : AppColors.onSurface.withValues(alpha: 0.03),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: isSelected ? AppColors.runeViolet : AppColors.onSurface.withValues(alpha: 0.12),
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                child: Text(
                                  _className(hc),
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? AppColors.onSurface : AppColors.onSurface.withValues(alpha: 0.60),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),

                        // Profile fields
                        Text(
                          'IDENTIFICATION DETAILS',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: AppColors.manaCyan,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 10),
                        
                        TextFormField(
                          controller: _nameController,
                          style: const TextStyle(color: AppColors.onSurface),
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.onSurface.withValues(alpha: 0.03),
                            labelText: l10n.profile_edit_full_name,
                            labelStyle: GoogleFonts.spaceGrotesk(color: AppColors.onSurface.withValues(alpha: 0.60), fontSize: 12),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: AppColors.onSurface.withValues(alpha: 0.10)),
                              borderRadius: BorderRadius.all(Radius.circular(4.0)),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: AppColors.runeViolet),
                              borderRadius: BorderRadius.all(Radius.circular(4.0)),
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return l10n.profile_edit_name_empty;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _bioController,
                          style: const TextStyle(color: AppColors.onSurface),
                          maxLines: 3,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.onSurface.withValues(alpha: 0.03),
                            labelText: l10n.profile_edit_memoir,
                            labelStyle: GoogleFonts.spaceGrotesk(color: AppColors.onSurface.withValues(alpha: 0.60), fontSize: 12),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: AppColors.onSurface.withValues(alpha: 0.10)),
                              borderRadius: BorderRadius.all(Radius.circular(4.0)),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: AppColors.runeViolet),
                              borderRadius: BorderRadius.all(Radius.circular(4.0)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.onSurface.withValues(alpha: 0.03),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.onSurface.withValues(alpha: 0.10)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedLanguage,
                              dropdownColor: AppColors.sheetBackground,
                              style: const TextStyle(color: AppColors.onSurface),
                              isExpanded: true,
                              icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.onSurface.withValues(alpha: 0.54)),
                              items: const [
                                DropdownMenuItem(value: 'es', child: Text('SPANISH (ES)')),
                                DropdownMenuItem(value: 'en', child: Text('ENGLISH (EN)')),
                                DropdownMenuItem(value: 'fr', child: Text('FRENCH (FR)')),
                                DropdownMenuItem(value: 'de', child: Text('GERMAN (DE)')),
                                DropdownMenuItem(value: 'pt', child: Text('PORTUGUESE (PT)')),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _selectedLanguage = val;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Save Changes Button
                        ElevatedButton(
                          onPressed: _isSaving
                              ? null
                              : () async {
                                  if (!_formKey.currentState!.validate()) return;
                                  if (user == null) return;

                                  setState(() {
                                    _isSaving = true;
                                  });

                                  try {
                                    // 1. Update in supabase profile database
                                    await ref.read(dashboardRepositoryProvider).updateUserProfile(
                                      user.id,
                                      displayName: _nameController.text,
                                      avatarUrl: _currentAvatarUrl,
                                      nativeLanguage: _selectedLanguage,
                                      // Save stats inside the bio field formatted
                                      bio: _formatBio(),
                                    );

                                    // 2. Also update auth user metadata
                                    final supabase = ref.read(supabaseClientProvider);
                                    await supabase.auth.updateUser(
                                      UserAttributes(
                                        data: {
                                          'full_name': _nameController.text,
                                          'avatar_url': _currentAvatarUrl,
                                        },
                                      ),
                                    );

                                    ref.invalidate(userProfileProvider);
                                    // Refresca el progreso (rango/nombre del
                                    // header) para que el cambio se refleje al
                                    // instante al volver al Status.
                                    ref.invalidate(userProgressProvider);

                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            AppLocalizations.of(context)?.profile_edit_license_updated ?? 'LICENSE REGISTRY UPDATED SUCCESSFULY 🎉',
                                            style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.bold),
                                          ),
                                          backgroundColor: AppColors.emeraldGreen,
                                          behavior: SnackBarBehavior.floating,
                                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4.0))),
                                        ),
                                      );
                                      if (context.canPop()) {
                                        context.pop();
                                      } else {
                                        context.go('/home');
                                      }
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      SystemSnack.show(context, 'ERROR SAVING LICENSE: $e', type: SystemSnackType.error);
                                    }
                                  } finally {
                                    if (mounted) {
                                      setState(() {
                                        _isSaving = false;
                                      });
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.runeViolet,
                            foregroundColor: AppColors.onSurface,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(4.0)),
                            ),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(color: AppColors.onSurface, strokeWidth: 2.5),
                                )
                              : Text(
                                  l10n.profile_edit_save,
                                  style: GoogleFonts.jetBrainsMono(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                                ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
