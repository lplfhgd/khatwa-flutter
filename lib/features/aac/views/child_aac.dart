import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../communication/models/communication_card.dart';
import '../../communication/services/communication_service.dart';
import '../../pairing/services/linked_child_storage.dart';

class ChildAac extends StatefulWidget {
  const ChildAac({super.key});

  @override
  State<ChildAac> createState() => _ChildAacState();
}

class _ChildAacState extends State<ChildAac> {
  static const primary = Color(0xFF168F8B);
  static const background = Color(0xFFF7F9F7);
  static const textColor = Color(0xFF263F43);

  final CommunicationService _service = Get.find<CommunicationService>();
  final LinkedChildStorage _storage = Get.find<LinkedChildStorage>();
  final AudioPlayer _player = AudioPlayer();

  Stream<List<CommunicationCard>>? _cardsStream;
  String? _playingId;
  String? _error;

  @override
  void initState() {
    super.initState();

    _player.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() => _playingId = null);
      }
    });

    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final linkedChild = await _storage.read();

      if (!mounted) return;

      if (linkedChild == null) {
        setState(() {
          _error = 'تعذر العثور على بيانات الطفل المرتبط.';
        });
        return;
      }

      setState(() {
        _cardsStream = _service.watchChildCards(
          parentId: linkedChild.parentId,
          childId: linkedChild.childId,
        );
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _error = 'تعذر تحميل بطاقات التواصل.';
      });
    }
  }

  Future<void> _playCard(CommunicationCard card) async {
    if (card.audioUrl.isEmpty) return;

    try {
      await _player.stop();

      setState(() {
        _playingId = card.id;
      });

      await _player.play(
        UrlSource(card.audioUrl),
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _playingId = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر تشغيل صوت البطاقة.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          style: const TextStyle(
            fontSize: 18,
            color: textColor,
          ),
        ),
      );
    }

    final stream = _cardsStream;

    if (stream == null) {
      return const Center(
        child: CircularProgressIndicator(color: primary),
      );
    }

    return StreamBuilder<List<CommunicationCard>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint('CHILD CARDS ERROR: ${snapshot.error}');

          return const Center(
            child: Text(
              'تعذر تحميل بطاقات التواصل.',
              style: TextStyle(
                fontSize: 18,
                color: textColor,
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: primary),
          );
        }

        final cards = snapshot.data ?? const <CommunicationCard>[];

        return Container(
          color: background,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 24, 18, 30),
            children: [
              const Text(
                'أتواصل',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'اختر ما تريد قوله',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  color: Color(0xFF607983),
                ),
              ),
              const SizedBox(height: 24),
              if (cards.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Column(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 70,
                        color: primary,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'لا توجد بطاقات تواصل حاليًا',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cards.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 0.82,
                  ),
                  itemBuilder: (context, index) {
                    final card = cards[index];
                    final playing = _playingId == card.id;

                    return InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () => _playCard(card),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: playing ? primary : const Color(0xFFE5F3ED),
                            width: playing ? 2 : 1,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            Expanded(
                              child: SizedBox(
                                width: double.infinity,
                                child: Image.network(
                                  card.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Icon(
                                        Icons.image_outlined,
                                        size: 55,
                                        color: primary,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Text(
                                      card.label,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.w900,
                                        color: textColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    playing
                                        ? Icons.volume_up_rounded
                                        : Icons.play_circle_outline_rounded,
                                    color: primary,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
