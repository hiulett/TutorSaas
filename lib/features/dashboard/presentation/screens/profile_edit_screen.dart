import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/rpg_avatar.dart';
import '../../../../core/widgets/cyber_manhwa_background.dart';
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
  bool _isUploading = false;

  // Stat point allocation
  int _str = 5;
  int _int = 5;
  int _dex = 5;
  int _luk = 5;
  int _pointsPool = 10;

  final List<Map<String, String>> _hunterClasses = [
    {'id': 'warrior', 'name': 'WARRIOR', 'desc': 'Physical strength & high defense'},
    {'id': 'mage', 'name': 'MAGE', 'desc': 'Spell casting & mana manipulation'},
    {'id': 'assassin', 'name': 'ASSASSIN', 'desc': 'Stealth, speed & critical strikes'},
    {'id': 'necromancer', 'name': 'NECROMANCER', 'desc': 'Summoning the dead & dark magic'},
    {'id': 'priest', 'name': 'PRIEST', 'desc': 'Healing, buffing & holy light'},
  ];

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
        _parseBio(profile['bio'] as String? ?? '');
        setState(() {});
      } else {
        final authUser = ref.read(currentUserProvider);
        _nameController.text = authUser?.userMetadata?['full_name'] ?? authUser?.email?.split('@').first ?? '';
        _currentAvatarUrl = 'warrior';
        setState(() {});
      }
    });
  }

  void _parseBio(String rawBio) {
    if (rawBio.startsWith('[Stats|')) {
      try {
        final regex = RegExp(r'^\[Stats\|STR:(\d+)\|INT:(\d+)\|DEX:(\d+)\|LUK:(\d+)\]\s*(.*)$');
        final match = regex.firstMatch(rawBio);
        if (match != null) {
          _str = int.parse(match.group(1)!);
          _int = int.parse(match.group(2)!);
          _dex = int.parse(match.group(3)!);
          _luk = int.parse(match.group(4)!);
          _bioController.text = match.group(5)!;
          
          final totalUsed = (_str - 5) + (_int - 5) + (_dex - 5) + (_luk - 5);
          _pointsPool = 10 - totalUsed;
          if (_pointsPool < 0) _pointsPool = 0;
          return;
        }
      } catch (_) {}
    }
    _bioController.text = rawBio;
    _str = 5;
    _int = 5;
    _dex = 5;
    _luk = 5;
    _pointsPool = 10;
  }

  String _formatBio() {
    return '[Stats|STR:$_str|INT:$_int|DEX:$_dex|LUK:$_luk] ${_bioController.text.trim()}';
  }

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
        _isUploading = true;
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
        _isUploading = false;
      });

      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'PHOTO UPLOADED SUCCESSFULY 📸',
              style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4.0))),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
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
      backgroundColor: const Color(0xFF0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'CHOOSE CUSTOM PHOTO PATH',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
                        label: Text('CAMERA', style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.05),
                          foregroundColor: Colors.white,
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
                        label: Text('GALLERY', style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.05),
                          foregroundColor: Colors.white,
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

  void _adjustStat(String stat, int delta) {
    setState(() {
      if (delta > 0 && _pointsPool > 0) {
        if (stat == 'STR') _str++;
        if (stat == 'INT') _int++;
        if (stat == 'DEX') _dex++;
        if (stat == 'LUK') _luk++;
        _pointsPool--;
      } else if (delta < 0) {
        if (stat == 'STR' && _str > 5) {
          _str--;
          _pointsPool++;
        }
        if (stat == 'INT' && _int > 5) {
          _int--;
          _pointsPool++;
        }
        if (stat == 'DEX' && _dex > 5) {
          _dex--;
          _pointsPool++;
        }
        if (stat == 'LUK' && _luk > 5) {
          _luk--;
          _pointsPool++;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                      color: Colors.white.withValues(alpha: 0.05),
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
                          child: Icon(Icons.arrow_back_rounded, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'HUNTER LICENSE REGISTRY',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.0,
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
                          opacity: 0.08,
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
                                      child: const Icon(Icons.photo_camera_rounded, color: Colors.white, size: 14),
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
                                        borderRadius: BorderRadius.circular(2),
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
                                          : 'HUNTER NAME',
                                      style: GoogleFonts.spaceGrotesk(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 18,
                                        letterSpacing: 0.5,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'CLASS PATH: ${_currentAvatarUrl.toUpperCase()}',
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
                          'SELECT CLASS PATH',
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
                            final isSelected = _currentAvatarUrl == hc['id'];
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _currentAvatarUrl = hc['id']!;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.runeViolet.withValues(alpha: 0.2)
                                      : Colors.white.withValues(alpha: 0.03),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: isSelected ? AppColors.runeViolet : Colors.white12,
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                child: Text(
                                  hc['name']!,
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : Colors.white60,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),

                        // Section: Stats Allocation
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'STAT POINTS ALLOCATION',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: AppColors.manaCyan,
                                letterSpacing: 1.0,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              color: AppColors.runeViolet.withValues(alpha: 0.2),
                              child: Text(
                                'POOL: $_pointsPool PT',
                                style: GoogleFonts.jetBrainsMono(
                                  color: AppColors.manaCyan,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        GlassCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _buildStatRow('STR', _str, 'Strength & muscle power'),
                              const Divider(color: Colors.white10),
                              _buildStatRow('INT', _int, 'Spellcasting & parsing speed'),
                              const Divider(color: Colors.white10),
                              _buildStatRow('DEX', _dex, 'Agility & response rhythm'),
                              const Divider(color: Colors.white10),
                              _buildStatRow('LUK', _luk, 'Critical correction avoidance'),
                            ],
                          ),
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
                          style: const TextStyle(color: Colors.white),
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.03),
                            labelText: 'HUNTER FULL NAME',
                            labelStyle: GoogleFonts.spaceGrotesk(color: Colors.white30, fontSize: 12),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white10),
                              borderRadius: BorderRadius.all(Radius.circular(4.0)),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: AppColors.runeViolet),
                              borderRadius: BorderRadius.all(Radius.circular(4.0)),
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'NAME CANNOT BE EMPTY';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _bioController,
                          style: const TextStyle(color: Colors.white),
                          maxLines: 3,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.03),
                            labelText: 'MEMOIR / OBJECTIVES',
                            labelStyle: GoogleFonts.spaceGrotesk(color: Colors.white30, fontSize: 12),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white10),
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
                            color: Colors.white.withValues(alpha: 0.03),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedLanguage,
                              dropdownColor: const Color(0xFF0F172A),
                              style: const TextStyle(color: Colors.white),
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white54),
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

                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'LICENSE REGISTRY UPDATED SUCCESSFULY 🎉',
                                            style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.bold),
                                          ),
                                          backgroundColor: Colors.green,
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
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('ERROR SAVING LICENSE: $e'),
                                          backgroundColor: AppColors.crimsonRed,
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
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
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(4.0)),
                            ),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                )
                              : Text(
                                  'SAVE LICENSE REGISTRY',
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

  Widget _buildStatRow(String statName, int val, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(
              statName,
              style: GoogleFonts.spaceGrotesk(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 15,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  desc,
                  style: const TextStyle(color: Colors.white54, fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Custom stat bar
                Stack(
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: val / 15.0 > 1.0 ? 1.0 : val / 15.0,
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.runeViolet, AppColors.manaCyan],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '$val',
            style: GoogleFonts.jetBrainsMono(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(width: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline_rounded, color: AppColors.onSurfaceVariant, size: 20),
                onPressed: () => _adjustStat(statName, -1),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.manaCyan, size: 20),
                onPressed: () => _adjustStat(statName, 1),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
