import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/core/storage/settings.repository.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.colors.dart';
import 'package:provider/provider.dart';

class MusicPanel extends StatelessWidget {
  const MusicPanel({super.key});

  static const tracks = [
    (id: 'sunshine_skip', label: 'Sunshine Skip', color: Color(0xFFF59E0B)),
    (id: 'bubble_pop', label: 'Bubble Pop Parade', color: Color(0xFFEF4444)),
    (id: 'rainbow_carousel', label: 'Rainbow Carousel', color: Color(0xFFEC4899)),
    (id: 'confetti_party', label: 'Confetti Party', color: Color(0xFF3B82F6)),
  ];

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsRepository>();
    final volumePercent = (settings.volume * 100).round();

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 20, left: 16, right: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Music',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF221A30),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(
                CupertinoIcons.speaker_2_fill,
                size: 20,
                color: AppColors.purple,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CupertinoSlider(
                  value: settings.volume,
                  min: 0,
                  max: 1,
                  activeColor: AppColors.purple,
                  thumbColor: AppColors.purple,
                  onChanged: (v) => settings.setVolume(v),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 38,
                child: Text(
                  '$volumePercent%',
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4B4257),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: tracks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final track = tracks[index];
                final isSelected = settings.selectedTrack == track.id;
                return GestureDetector(
                  onTap: () => settings.setTrack(track.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFE8F1FD)
                          : const Color(0x80FFFFFF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF3B82F6)
                            : const Color(0xFFE5DFEC),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: track.color.withValues(alpha: 0.18),
                          ),
                          child: Icon(
                            CupertinoIcons.music_note,
                            size: 18,
                            color: track.color,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            track.label,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: isSelected
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFF474151),
                            ),
                          ),
                        ),
                        if (isSelected) const _EqualizerBars(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EqualizerBars extends StatefulWidget {
  const _EqualizerBars();

  @override
  State<_EqualizerBars> createState() => _EqualizerBarsState();
}

class _EqualizerBarsState extends State<_EqualizerBars>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _bar(8 + (t * 8)),
            const SizedBox(width: 2.5),
            _bar(16 - (t * 8)),
            const SizedBox(width: 2.5),
            _bar(10 + (t * 6)),
          ],
        );
      },
    );
  }

  Widget _bar(double height) {
    return Container(
      width: 3,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
