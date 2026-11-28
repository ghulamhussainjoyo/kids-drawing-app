import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/app/setting/widgets/music.volume.slider.dart';
import 'package:kids_drawing_flutter/app/setting/widgets/setting.card.dart';
import 'package:kids_drawing_flutter/app/setting/widgets/setting.disabled.dart';
import 'package:kids_drawing_flutter/app/setting/widgets/setting.panel.scaffold.dart';
import 'package:kids_drawing_flutter/app/setting/widgets/setting_toggle_row.dart';
import 'package:kids_drawing_flutter/core/ui/button/press.button.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.colors.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.typography.dart';
import 'package:kids_drawing_flutter/state/setting/setting.view-model.dart';
import 'package:kids_drawing_flutter/utils/responsive.dart';
import 'package:provider/provider.dart';

class MusicPanel extends StatelessWidget {
  const MusicPanel({super.key});

  static const tracks = [
    (id: 'puppy_playtime', color: Color(0xFF8B5CF6)),
    (id: 'sunshine_skip', color: Color(0xFFF59E0B)),
    (id: 'bubble_pop', color: Color(0xFFEF4444)),
    (id: 'rainbow_carousel', color: Color(0xFFEC4899)),
    (id: 'confetti_party', color: Color(0xFF3B82F6)),
  ];

  @override
  Widget build(BuildContext context) {
    final (musicOn, volume, selectedTrack) = context
        .select<SettingViewModel, (bool, double, String)>(
          (s) => (s.musicOn, s.volume, s.selectedTrack),
        );
    final viewModel = context.read<SettingViewModel>();

    return SettingPanelScaffold(
      title: viewModel.t('music.title'),
      onClose: () => Navigator.of(context).pop(),
      child: Column(
        children: [
          SettingToggleRow(
            icon: Icon(
              CupertinoIcons.music_note_2,
              color: AppColors.purple,
              size: context.rs(22),
            ),
            title: viewModel.t('music.toggle'),
            value: musicOn,
            onChanged: viewModel.setMusicOn,
          ),
          SettingDisabled(
            disabled: !musicOn,
            child: Column(
              children: [
                _VolumeCard(
                  volume: volume,
                  enabled: musicOn,
                  onChanged: viewModel.setVolume,
                ),
                for (final track in tracks)
                  _TrackRow(
                    label: viewModel.t('music.${track.id}'),
                    color: track.color,
                    selected: selectedTrack == track.id,
                    showEqualizer: musicOn && selectedTrack == track.id,
                    onTap: () => viewModel.setTrack(track.id),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VolumeCard extends StatelessWidget {
  final double volume;
  final bool enabled;
  final ValueChanged<double> onChanged;

  const _VolumeCard({
    required this.volume,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SettingCard(
      child: Row(
        children: [
          Icon(
            CupertinoIcons.speaker_2_fill,
            size: context.rs(22),
            color: AppColors.purple,
          ),
          SizedBox(width: context.rs(12)),
          Expanded(
            child: MusicVolumeSlider(
              value: volume,
              enabled: enabled,
              onChanged: onChanged,
            ),
          ),
          SizedBox(width: context.rs(8)),
          SizedBox(
            width: context.rs(42),
            child: Text(
              '${(volume * 100).round()}%',
              textAlign: TextAlign.end,
              style: AppTypography.numericStyle(
                fontSize: context.rs(14),
                color: const Color(0xFF4B4257),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackRow extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final bool showEqualizer;
  final VoidCallback onTap;

  const _TrackRow({
    required this.label,
    required this.color,
    required this.selected,
    required this.showEqualizer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: PressButton(
        onPressed: onTap,
        child: SettingCard(
          selected: selected,
          child: Row(
            children: [
              Container(
                width: context.rs(32),
                height: context.rs(32),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.18),
                ),
                child: Icon(
                  CupertinoIcons.music_note,
                  size: context.rs(18),
                  color: color,
                ),
              ),
              SizedBox(width: context.rs(12)),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: selected
                      ? AppTypography.boldStyle(
                          fontSize: context.rs(15),
                          color: const Color(0xFF221A30),
                        )
                      : AppTypography.semiBoldStyle(
                          fontSize: context.rs(15),
                          color: const Color(0xFF433C4F),
                        ),
                ),
              ),
              if (showEqualizer) _EqualizerBars(scale: context.rs(1)),
            ],
          ),
        ),
      ),
    );
  }
}

class _EqualizerBars extends StatefulWidget {
  final double scale;

  const _EqualizerBars({required this.scale});

  @override
  State<_EqualizerBars> createState() => _EqualizerBarsState();
}

class _EqualizerBarsState extends State<_EqualizerBars>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _bar(double height) {
    final s = widget.scale;
    return Container(
      width: 3 * s,
      height: height * s,
      decoration: BoxDecoration(
        color: AppColors.purple,
        borderRadius: BorderRadius.circular(2 * s),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = _controller.value;
          return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _bar(8 + t * 8),
              SizedBox(width: 2.5 * widget.scale),
              _bar(16 - t * 8),
              SizedBox(width: 2.5 * widget.scale),
              _bar(10 + t * 6),
            ],
          );
        },
      ),
    );
  }
}
