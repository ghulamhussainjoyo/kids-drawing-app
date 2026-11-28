import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show showDialog;
import 'package:kids_drawing_flutter/app/genre/widget/genre.carousel.dart';
import 'package:kids_drawing_flutter/app/genre/widget/genre.live.background.dart';
import 'package:kids_drawing_flutter/app/parent_gate/utils/parent.gate.dart';
import 'package:kids_drawing_flutter/app/setting/screen/setting.screen.dart';
import 'package:kids_drawing_flutter/core/ui/button/press.button.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.colors.dart';
import 'package:kids_drawing_flutter/core/audio/app.sound.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.typography.dart';
import 'package:kids_drawing_flutter/state/genre/genre.view-model.dart';
import 'package:kids_drawing_flutter/state/setting/setting.view-model.dart';
import 'package:provider/provider.dart';

class GenreScreen extends StatefulWidget {
  const GenreScreen({super.key});
  @override
  State<GenreScreen> createState() => _GenreScreenState();
}

class _GenreScreenState extends State<GenreScreen> {
  @override
  void initState() {
    super.initState();
    _loadGenres();
  }

  void _loadGenres() {
    final lang = context.read<SettingViewModel>().language;
    context.read<GenreViewModel>().loadGenres(lang);
    context.read<AppSound>().unmute();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Selector<SettingViewModel, bool>(
            selector: (_, vm) => vm.liveBackgroundOn,
            builder: (context, liveOn, _) {
              return GenreLiveBackground(animated: liveOn);
            },
          ),
          Selector<SettingViewModel, String>(
            selector: (_, vm) => vm.language,
            builder: (context, lang, child) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.read<GenreViewModel>().loadGenres(lang);
              });
              return child!;
            },
            child: const SizedBox.shrink(),
          ),
          const Positioned.fill(
            child: IgnorePointer(
              child: ColoredBox(color: Color.fromRGBO(0, 0, 0, 0.15)),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              return Padding(
                padding: EdgeInsets.symmetric(),
                child: Stack(
                  children: [
                    Positioned(
                      top: 50,
                      left: 0,
                      right: 0,
                      bottom: 40,
                      child: GenreCarousel(),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Row(
                        children: [
                          PressButton(
                            onPressed: () async {
                              final granted = await ParentGate.request(context);
                              if (!context.mounted || !granted) return;
                              showDialog<void>(
                                context: context,
                                barrierColor: const Color(0x73000000),
                                useSafeArea: false,
                                builder: (_) => const SettingDialog(),
                              );
                            },
                            child: const SizedBox(
                              width: 44,
                              height: 44,
                              child: Icon(
                                CupertinoIcons.settings,
                                color: AppColors.purple,
                              ),
                            ),
                          ),
                          const Spacer(),
                          CupertinoButton(
                            onPressed: null,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Selector<SettingViewModel, String>(
                              selector: (_, vm) => vm.t('genre.try_free'),
                              builder: (_, text, __) => Text(
                                text,
                                style: AppTypography.semiBoldStyle(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Row(
                        children: [
                          const Spacer(),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: null,
                            child: Selector<SettingViewModel, String>(
                              selector: (_, vm) =>
                                  vm.t('genre.bottom_left_placeholder'),
                              builder: (_, text, __) => Text(
                                text,
                                style: AppTypography.semiBoldStyle(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
