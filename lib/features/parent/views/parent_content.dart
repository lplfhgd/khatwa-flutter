import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/playful_colors.dart';
import '../../communication/controllers/communication_controller.dart';
import '../../communication/models/communication_card.dart';
import '../../communication/models/story_item.dart';
import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class ParentContent extends StatelessWidget {
  const ParentContent({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CommunicationController>();

    return Obx(() {
      if (!controller.hasSelectedChild) {
        return const _NoChildState();
      }

      if (controller.isLoading.value &&
          controller.cards.isEmpty &&
          controller.stories.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      final error = controller.errorMessage.value;

      if (error != null &&
          controller.cards.isEmpty &&
          controller.stories.isEmpty) {
        return _ErrorState(
          message: error,
          onRetry: controller.loadSelectedChildContent,
        );
      }

      return _ContentView(controller: controller);
    });
  }
}

class _ContentView extends StatelessWidget {
  const _ContentView({
    required this.controller,
  });

  final CommunicationController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = Theme.of(context).extension<PlayfulColors>()!;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Obx(
            () => _Header(
              name: controller.childName,
              palette: palette,
            ),
          ),
          const SizedBox(height: 16),
          _SearchField(
            onChanged: controller.setQuery,
          ),
          const SizedBox(height: 18),
          Obx(() {
            if (controller.cards.isEmpty) {
              return _EmptyBubble(
                icon: Icons.palette_outlined,
                text: 'لا توجد بطاقات تواصل بعد',
                color: palette.yellow,
              );
            }

            final visible = controller.visibleCards;

            if (visible.isEmpty) {
              return _EmptyBubble(
                icon: Icons.search_rounded,
                text: 'لا توجد بطاقة مطابقة لبحثك',
                color: palette.blue,
              );
            }

            final playingId = controller.playingCardId.value;

            return GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.78,
              children: [
                for (var i = 0; i < visible.length; i++)
                  _CardTile(
                    card: visible[i],
                    color: _tileColor(palette, i),
                    isPlaying: playingId == visible[i].id,
                    onPlay: () => controller.playCard(visible[i]),
                    onEdit: () => _openCardEditor(
                      controller,
                      existing: visible[i],
                    ),
                    onDelete: () => _confirmDelete(
                      title: 'حذف البطاقة',
                      message: 'هل تريد حذف هذه البطاقة؟',
                      onConfirm: () => controller.deleteCard(visible[i]),
                    ),
                  ),
              ],
            );
          }),
          const SizedBox(height: 20),
          _BigButton(
            icon: Icons.add_rounded,
            label: 'إضافة بطاقة',
            color: scheme.primary,
            textColor: scheme.onPrimary,
            onTap: () => _openCardEditor(controller),
          ),
          const SizedBox(height: 32),
          _SectionHeader(
            icon: Icons.movie_creation_outlined,
            title: 'القصص',
            color: palette.pink,
            textColor: palette.onPastel,
          ),
          const SizedBox(height: 12),
          Obx(() {
            if (controller.stories.isEmpty) {
              return _EmptyBubble(
                icon: Icons.auto_stories_outlined,
                text: 'لا توجد قصص مضافة بعد',
                color: palette.pink,
              );
            }

            return Column(
              children: [
                for (var i = 0; i < controller.stories.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _StoryTile(
                      story: controller.stories[i],
                      color: _tileColor(palette, i + 2),
                      onOpen: () => controller.openStory(
                        controller.stories[i],
                      ),
                      onDelete: () => _confirmDelete(
                        title: 'حذف القصة',
                        message: 'هل تريد حذف هذه القصة؟',
                        onConfirm: () => controller.deleteStory(
                          controller.stories[i],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }),
          const SizedBox(height: 8),
          _BigButton(
            icon: Icons.video_library_outlined,
            label: 'إضافة قصة',
            color: palette.purple,
            textColor: palette.onPastel,
            onTap: () => _openStoryEditor(controller),
          ),
        ],
      ),
    );
  }
}

Color _tileColor(PlayfulColors palette, int index) {
  final colors = [
    palette.pink,
    palette.blue,
    palette.yellow,
    palette.green,
    palette.purple,
    palette.orange,
  ];

  return colors[index % colors.length];
}

class _Header extends StatelessWidget {
  const _Header({
    required this.name,
    required this.palette,
  });

  final String name;
  final PlayfulColors palette;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: palette.yellow,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.dashboard_customize_outlined,
              size: 28,
              color: palette.onPastel,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'بطاقات التواصل',
                  style: text.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: palette.onPastel,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name.isEmpty
                      ? 'أنشئ بطاقات تواصل سهلة وواضحة لطفلك'
                      : 'أنشئ بطاقات تواصل سهلة وواضحة لـ $name',
                  style: text.bodyMedium?.copyWith(
                    color: palette.onPastel,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.onChanged,
  });

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'ابحث في البطاقات',
        prefixIcon: const Icon(Icons.search_rounded),
        filled: true,
        fillColor: scheme.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(
            color: scheme.outlineVariant,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(
            color: scheme.primary,
            width: 2,
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.color,
    required this.textColor,
  });

  final IconData icon;
  final String title;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: textColor,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: text.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CardTile extends StatefulWidget {
  const _CardTile({
    required this.card,
    required this.color,
    required this.isPlaying,
    required this.onPlay,
    required this.onEdit,
    required this.onDelete,
  });

  final CommunicationCard card;
  final Color color;
  final bool isPlaying;
  final VoidCallback onPlay;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  State<_CardTile> createState() => _CardTileState();
}

class _CardTileState extends State<_CardTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
    lowerBound: 0.92,
    upperBound: 1,
  );

  @override
  void didUpdateWidget(covariant _CardTile oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isPlaying && !oldWidget.isPlaying) {
      _pulse.repeat(reverse: true);
    } else if (!widget.isPlaying && oldWidget.isPlaying) {
      _pulse.stop();
      _pulse.value = 1;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = Theme.of(context).extension<PlayfulColors>()!;
    final text = Theme.of(context).textTheme;

    final radius = BorderRadius.circular(28);
    final hasVoice = widget.card.audioUrl.isNotEmpty;

    return ScaleTransition(
      scale: _pulse,
      child: Material(
        color: widget.color,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(
            color: widget.isPlaying ? scheme.primary : Colors.transparent,
            width: 3,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onPlay,
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: _CardImage(
                          url: widget.card.imageUrl,
                        ),
                      ),
                    ),
                    PositionedDirectional(
                      top: 6,
                      end: 6,
                      child: _MenuButton(
                        onEdit: widget.onEdit,
                        onDelete: widget.onDelete,
                      ),
                    ),
                    PositionedDirectional(
                      bottom: 14,
                      start: 14,
                      child: _SoundBubble(
                        active: widget.isPlaying,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                child: Column(
                  children: [
                    Text(
                      widget.card.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: text.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: palette.onPastel,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _VoiceBadge(hasVoice: hasVoice),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardImage extends StatelessWidget {
  const _CardImage({
    required this.url,
  });

  final String url;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (url.isEmpty) {
      return ColoredBox(
        color: scheme.surfaceContainerLowest,
        child: const Center(
          child: Icon(
            Icons.image_outlined,
            size: 44,
          ),
        ),
      );
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;

        return const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        );
      },
      errorBuilder: (_, __, ___) {
        return ColoredBox(
          color: scheme.surfaceContainerLowest,
          child: const Center(
            child: Icon(
              Icons.broken_image_outlined,
              size: 44,
            ),
          ),
        );
      },
    );
  }
}

class _SoundBubble extends StatelessWidget {
  const _SoundBubble({
    required this.active,
  });

  final bool active;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? scheme.primary : scheme.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(
        active ? Icons.graphic_eq_rounded : Icons.volume_up_rounded,
        size: 20,
        color: active ? scheme.onPrimary : scheme.onSurface,
      ),
    );
  }
}

class _VoiceBadge extends StatelessWidget {
  const _VoiceBadge({
    required this.hasVoice,
  });

  final bool hasVoice;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = Theme.of(context).extension<PlayfulColors>()!;
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: hasVoice ? palette.green : scheme.surface,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasVoice ? Icons.mic_rounded : Icons.mic_off_outlined,
            size: 14,
            color: palette.onPastel,
          ),
          const SizedBox(width: 4),
          Text(
            hasVoice ? 'صوت مسجل' : 'بدون صوت',
            style: text.labelSmall?.copyWith(
              color: palette.onPastel,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.onEdit,
    required this.onDelete,
  });

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return PopupMenuButton<_CardAction>(
      tooltip: 'المزيد',
      icon: CircleAvatar(
        radius: 16,
        backgroundColor: scheme.surface,
        child: Icon(
          Icons.more_horiz_rounded,
          size: 18,
          color: scheme.onSurface,
        ),
      ),
      onSelected: (action) {
        switch (action) {
          case _CardAction.edit:
            onEdit();
          case _CardAction.delete:
            onDelete();
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: _CardAction.edit,
          child: Row(
            children: [
              Icon(Icons.edit_outlined),
              SizedBox(width: 8),
              Text('تعديل البطاقة'),
            ],
          ),
        ),
        PopupMenuItem(
          value: _CardAction.delete,
          child: Row(
            children: [
              Icon(Icons.delete_outline),
              SizedBox(width: 8),
              Text('حذف البطاقة'),
            ],
          ),
        ),
      ],
    );
  }
}

enum _CardAction {
  edit,
  delete,
}

class _StoryTile extends StatelessWidget {
  const _StoryTile({
    required this.story,
    required this.color,
    required this.onOpen,
    required this.onDelete,
  });

  final StoryItem story;
  final Color color;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = Theme.of(context).extension<PlayfulColors>()!;
    final text = Theme.of(context).textTheme;

    return Material(
      color: color,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: scheme.surface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.smart_display_rounded,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      story.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: palette.onPastel,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'اضغط لمشاهدة القصة',
                      style: text.bodySmall?.copyWith(
                        color: palette.onPastel,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.play_arrow_rounded,
                size: 28,
              ),
              IconButton(
                tooltip: 'حذف',
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BigButton extends StatelessWidget {
  const _BigButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(999);

    return Material(
      color: color,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 16,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 22,
                color: textColor,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: text.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyBubble extends StatelessWidget {
  const _EmptyBubble({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<PlayfulColors>()!;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 36,
            color: palette.onPastel,
          ),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: palette.onPastel,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoChildState extends StatelessWidget {
  const _NoChildState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.child_care_rounded,
              size: 54,
            ),
            SizedBox(height: 12),
            Text(
              'اختر طفلًا أولًا لإدارة بطاقات التواصل والقصص الخاصة به.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 50,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}

void _confirmDelete({
  required String title,
  required String message,
  required VoidCallback onConfirm,
}) {
  Get.dialog(
    AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: Get.back,
          child: const Text('إلغاء'),
        ),
        FilledButton(
          onPressed: () {
            Get.back();
            onConfirm();
          },
          child: const Text('حذف'),
        ),
      ],
    ),
  );
}

void _openCardEditor(
  CommunicationController controller, {
  CommunicationCard? existing,
}) {
  Get.bottomSheet(
    _CardEditorSheet(
      controller: controller,
      existing: existing,
    ),
    isScrollControlled: true,
    backgroundColor: Get.theme.colorScheme.surface,
  );
}

class _CardEditorSheet extends StatefulWidget {
  const _CardEditorSheet({
    required this.controller,
    this.existing,
  });

  final CommunicationController controller;
  final CommunicationCard? existing;

  @override
  State<_CardEditorSheet> createState() => _CardEditorSheetState();
}

class _CardEditorSheetState extends State<_CardEditorSheet>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _labelController;

  final ImagePicker _imagePicker = ImagePicker();
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _previewPlayer = AudioPlayer();

  StreamSubscription<void>? _playerSubscription;

  late final AnimationController _recordAnimation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
    lowerBound: 0.85,
    upperBound: 1.1,
  );

  String? _imagePath;
  String? _audioPath;

  bool _isRecording = false;
  bool _isPlaying = false;

  CommunicationCard? get _existing => widget.existing;

  bool get _hasImage =>
      _imagePath != null || (_existing?.imageUrl.isNotEmpty ?? false);

  bool get _hasAudio =>
      _audioPath != null || (_existing?.audioUrl.isNotEmpty ?? false);

  @override
  void initState() {
    super.initState();

    _labelController = TextEditingController(
      text: _existing?.label ?? '',
    );

    _playerSubscription = _previewPlayer.onPlayerComplete.listen((_) {
      if (!mounted) return;

      setState(() {
        _isPlaying = false;
      });
    });
  }

  @override
  void dispose() {
    _playerSubscription?.cancel();
    _recorder.dispose();
    _previewPlayer.dispose();
    _recordAnimation.dispose();
    _labelController.dispose();

    super.dispose();
  }

  void _message(String message) {
    Get.snackbar(
      'خطوة',
      message,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> _pickImage() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 900,
        imageQuality: 85,
      );

      if (image == null || !mounted) return;

      setState(() {
        _imagePath = image.path;
      });
    } catch (_) {
      _message('تعذر اختيار الصورة.');
    }
  }

  Future<void> _toggleRecording() async {
    try {
      if (_isRecording) {
        _recordAnimation.stop();
        _recordAnimation.value = 1;

        final path = await _recorder.stop();

        if (!mounted) return;

        setState(() {
          _isRecording = false;

          if (path != null) {
            _audioPath = path;
          }
        });

        return;
      }

      final permission = await _recorder.hasPermission();

      if (!permission) {
        _message('يجب السماح للتطبيق باستخدام الميكروفون.');
        return;
      }

      final directory = await getTemporaryDirectory();

      final path =
          '${directory.path}/card_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _previewPlayer.stop();

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
        ),
        path: path,
      );

      if (!mounted) return;

      setState(() {
        _isRecording = true;
        _isPlaying = false;
      });

      _recordAnimation.repeat(reverse: true);
    } catch (_) {
      _recordAnimation.stop();
      _recordAnimation.value = 1;

      if (mounted) {
        setState(() {
          _isRecording = false;
        });
      }

      _message('تعذر بدء التسجيل الصوتي.');
    }
  }

  Future<void> _toggleAudioPreview() async {
    try {
      if (_isPlaying) {
        await _previewPlayer.stop();

        if (mounted) {
          setState(() {
            _isPlaying = false;
          });
        }

        return;
      }

      final Source source;

      if (_audioPath != null) {
        source = DeviceFileSource(_audioPath!);
      } else if (_existing?.audioUrl.isNotEmpty ?? false) {
        source = UrlSource(_existing!.audioUrl);
      } else {
        return;
      }

      setState(() {
        _isPlaying = true;
      });

      await _previewPlayer.play(source);
    } catch (_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }

      _message('تعذر تشغيل التسجيل.');
    }
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_isRecording) {
      _message('أوقف التسجيل أولًا قبل حفظ البطاقة.');
      return;
    }

    if (!_hasImage) {
      _message('اختر صورة للبطاقة.');
      return;
    }

    if (!_hasAudio) {
      _message('سجل صوتًا للبطاقة.');
      return;
    }

    widget.controller.saveCard(
      existing: _existing,
      label: _labelController.text.trim(),
      imageFilePath: _imagePath,
      audioFilePath: _audioPath,
    );
  }

  Widget _imagePreview() {
    if (_imagePath != null) {
      return Image.file(
        File(_imagePath!),
        fit: BoxFit.cover,
      );
    }

    return _CardImage(
      url: _existing?.imageUrl ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final palette = Theme.of(context).extension<PlayfulColors>()!;
    final text = Theme.of(context).textTheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _existing == null ? 'إضافة بطاقة تواصل' : 'تعديل بطاقة التواصل',
                textAlign: TextAlign.center,
                style: text.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 18),
              _EditorStep(
                color: palette.pink,
                title: '1. اختر صورة',
                child: InkWell(
                  onTap: _pickImage,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    height: 160,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: _hasImage
                        ? SizedBox.expand(
                            child: _imagePreview(),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 42,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'اضغط لاختيار صورة',
                                style: text.bodyMedium?.copyWith(
                                  color: palette.onPastel,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _EditorStep(
                color: palette.blue,
                title: '2. سجل الصوت',
                subtitle:
                    'سجل الكلمة أو العبارة التي ستسمع عند الضغط على البطاقة.',
                child: Row(
                  children: [
                    ScaleTransition(
                      scale: _recordAnimation,
                      child: IconButton.filled(
                        tooltip: _isRecording ? 'إيقاف التسجيل' : 'بدء التسجيل',
                        onPressed: _toggleRecording,
                        style: IconButton.styleFrom(
                          backgroundColor:
                              _isRecording ? scheme.error : scheme.primary,
                          foregroundColor:
                              _isRecording ? scheme.onError : scheme.onPrimary,
                          minimumSize: const Size(56, 56),
                        ),
                        icon: Icon(
                          _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _isRecording
                            ? 'جارٍ التسجيل...'
                            : _hasAudio
                                ? 'تم تسجيل الصوت'
                                : 'لا يوجد تسجيل بعد',
                        style: text.bodyMedium?.copyWith(
                          color: palette.onPastel,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'معاينة الصوت',
                      onPressed: _hasAudio && !_isRecording
                          ? _toggleAudioPreview
                          : null,
                      icon: Icon(
                        _isPlaying
                            ? Icons.stop_circle_outlined
                            : Icons.play_circle_outline_rounded,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _EditorStep(
                color: palette.green,
                title: '3. اسم البطاقة',
                child: TextFormField(
                  controller: _labelController,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'اسم البطاقة',
                    prefixIcon: Icon(Icons.edit_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'اكتب اسم البطاقة.';
                    }

                    return null;
                  },
                  onFieldSubmitted: (_) => _submit(),
                ),
              ),
              const SizedBox(height: 22),
              Obx(
                () => FilledButton.icon(
                  onPressed: widget.controller.isSaving.value ? null : _submit,
                  icon: widget.controller.isSaving.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(
                    widget.controller.isSaving.value
                        ? 'جارٍ الحفظ...'
                        : 'حفظ البطاقة',
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

class _EditorStep extends StatelessWidget {
  const _EditorStep({
    required this.color,
    required this.title,
    required this.child,
    this.subtitle,
  });

  final Color color;
  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<PlayfulColors>()!;
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: text.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: palette.onPastel,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: text.bodySmall?.copyWith(
                color: palette.onPastel,
              ),
            ),
          ],
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

void _openStoryEditor(
  CommunicationController controller,
) {
  Get.bottomSheet(
    _StoryEditorSheet(
      controller: controller,
    ),
    isScrollControlled: true,
    backgroundColor: Get.theme.colorScheme.surface,
  );
}

class _StoryEditorSheet extends StatefulWidget {
  const _StoryEditorSheet({
    required this.controller,
  });

  final CommunicationController controller;

  @override
  State<_StoryEditorSheet> createState() => _StoryEditorSheetState();
}

class _StoryEditorSheetState extends State<_StoryEditorSheet> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _urlController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    widget.controller.saveStory(
      title: _titleController.text.trim(),
      youtubeUrl: _urlController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<PlayfulColors>()!;
    final text = Theme.of(context).textTheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'إضافة قصة',
                textAlign: TextAlign.center,
                style: text.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 18),
              _EditorStep(
                color: palette.pink,
                title: 'عنوان القصة',
                child: TextFormField(
                  controller: _titleController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'عنوان القصة',
                    prefixIcon: Icon(Icons.title_rounded),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'اكتب عنوان القصة.';
                    }

                    return null;
                  },
                ),
              ),
              const SizedBox(height: 14),
              _EditorStep(
                color: palette.yellow,
                title: 'رابط YouTube',
                child: TextFormField(
                  controller: _urlController,
                  keyboardType: TextInputType.url,
                  textDirection: TextDirection.ltr,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'رابط الفيديو',
                    prefixIcon: Icon(Icons.link_rounded),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'أدخل رابط الفيديو.';
                    }

                    if (StoryItem.extractYoutubeId(
                          value.trim(),
                        ) ==
                        null) {
                      return 'أدخل رابط YouTube صالحًا.';
                    }

                    return null;
                  },
                  onFieldSubmitted: (_) => _submit(),
                ),
              ),
              const SizedBox(height: 22),
              Obx(
                () => FilledButton.icon(
                  onPressed: widget.controller.isSaving.value ? null : _submit,
                  icon: widget.controller.isSaving.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          Icons.save_outlined,
                        ),
                  label: Text(
                    widget.controller.isSaving.value
                        ? 'جارٍ الحفظ...'
                        : 'حفظ القصة',
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
