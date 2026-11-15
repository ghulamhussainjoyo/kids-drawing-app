import 'package:flutter/material.dart';
import 'package:kids_drawing_flutter/core/storage/settings.repository.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.colors.dart';
import 'package:provider/provider.dart';

class LittleArtistPanel extends StatelessWidget {
  const LittleArtistPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsRepository>();
    String pronoun;
    if (settings.gender == 'girl') {
      pronoun = 'she';
    } else if (settings.gender == 'boy') {
      pronoun = 'he';
    } else {
      pronoun = 'they';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 8, bottom: 24, left: 16, right: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Little Artist',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF221A30),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            "Who's the little artist?",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF433C4F),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _GenderOption(
                label: 'Girl',
                isSelected: settings.gender == 'girl',
                icon: Icons.face_3,
                accentColor: const Color(0xFFF59E0B),
                onTap: () => settings.setGender('girl'),
              ),
              const SizedBox(width: 18),
              _GenderOption(
                label: 'Boy',
                isSelected: settings.gender == 'boy',
                icon: Icons.face,
                accentColor: const Color(0xFF3B82F6),
                onTap: () => settings.setGender('boy'),
              ),
              const SizedBox(width: 18),
              _GenderOption(
                label: 'Siblings',
                isSelected: settings.gender == 'siblings',
                icon: Icons.groups,
                accentColor: const Color(0xFF10B981),
                onTap: () => settings.setGender('siblings'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'How old is $pronoun?',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF433C4F),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final age in [
                  '0–2',
                  '3–4',
                  '5–6',
                  '7–8',
                  '9–11',
                  '12+',
                ]) ...[
                  _AgeCircle(
                    age: age,
                    isSelected: settings.ageRange == age,
                    onTap: () => settings.setAgeRange(age),
                  ),
                  const SizedBox(width: 10),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'What does $pronoun love?',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF433C4F),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _InterestItem(
                  label: 'Animals',
                  imagePath: 'assets/gallery/animals.png',
                  isSelected: settings.interests.contains('animals'),
                  onTap: () => settings.toggleInterest('animals'),
                ),
                _InterestItem(
                  label: 'Music',
                  imagePath: 'assets/gallery/music.png',
                  isSelected: settings.interests.contains('music'),
                  onTap: () => settings.toggleInterest('music'),
                ),
                _InterestItem(
                  label: 'Seasons',
                  imagePath: 'assets/gallery/seasons.png',
                  isSelected: settings.interests.contains('seasons'),
                  onTap: () => settings.toggleInterest('seasons'),
                ),
                _InterestItem(
                  label: 'School',
                  imagePath: 'assets/gallery/school.png',
                  isSelected: settings.interests.contains('school'),
                  onTap: () => settings.toggleInterest('school'),
                ),
                _InterestItem(
                  label: 'Transport',
                  imagePath: 'assets/gallery/transport.png',
                  isSelected: settings.interests.contains('transport'),
                  onTap: () => settings.toggleInterest('transport'),
                ),
                _InterestItem(
                  label: 'Princesses',
                  imagePath: 'assets/gallery/princes.png',
                  isSelected: settings.interests.contains('princes'),
                  onTap: () => settings.toggleInterest('princes'),
                ),
                _InterestItem(
                  label: 'Fruit Garden',
                  imagePath: 'assets/gallery/fruit- garden.png',
                  isSelected: settings.interests.contains('fruit-garden'),
                  onTap: () => settings.toggleInterest('fruit-garden'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GenderOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  const _GenderOption({
    required this.label,
    required this.isSelected,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget avatar = Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(
          color: isSelected ? accentColor : const Color(0xFFDCD5E4),
          width: isSelected ? 3.5 : 1.5,
        ),
      ),
      child: Icon(icon, size: 40, color: accentColor),
    );
    if (!isSelected) {
      avatar = ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0, 0, 0, 1, 0,
        ]),
        child: avatar,
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          avatar,
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              color: isSelected
                  ? const Color(0xFF221A30)
                  : const Color(0xFF746C7E),
            ),
          ),
        ],
      ),
    );
  }
}

class _AgeCircle extends StatelessWidget {
  final String age;
  final bool isSelected;
  final VoidCallback onTap;

  const _AgeCircle({
    required this.age,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? AppColors.purple : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.purple : const Color(0xFFDCD5E4),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            age,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : const Color(0xFF6B6275),
            ),
          ),
        ),
      ),
    );
  }
}

class _InterestItem extends StatelessWidget {
  final String label;
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;

  const _InterestItem({
    required this.label,
    required this.imagePath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
                border: Border.all(
                  color: isSelected
                      ? AppColors.purple
                      : const Color(0xFFDED8E7),
                  width: isSelected ? 3 : 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.palette_outlined,
                    color: AppColors.purple,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.purple : const Color(0xFF5E5669),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
