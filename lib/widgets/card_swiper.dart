import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event_card.dart';
import '../theme/neo_ottoman_theme.dart';
import 'dart:math' as math;

class CardSwiper extends StatefulWidget {
  final EventCard event;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;

  const CardSwiper({
    Key? key,
    required this.event,
    required this.onSwipeLeft,
    required this.onSwipeRight,
  }) : super(key: key);

  @override
  State<CardSwiper> createState() => _CardSwiperState();
}

class _CardSwiperState extends State<CardSwiper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late double _dragStartX;
  late double _dragPosition;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0.0, end: 0.0).animate(_controller);
    _controller.addListener(() {
      setState(() {});
    });
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (_animation.value > 0.5) {
          widget.onSwipeRight();
        } else if (_animation.value < -0.5) {
          widget.onSwipeLeft();
        }
        _resetCard();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(CardSwiper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.event.id != widget.event.id) {
      _resetCard();
    }
  }

  void _resetCard() {
    _dragPosition = 0.0;
    _animation = Tween<double>(begin: 0.0, end: 0.0).animate(_controller);
    _controller.reset();
    setState(() {});
  }

  void _onDragStart(DragStartDetails details) {
    _isDragging = true;
    _dragStartX = details.localPosition.dx;
    _dragPosition = 0.0;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;

    final screenWidth = MediaQuery.of(context).size.width;
    final dragDistance = details.localPosition.dx - _dragStartX;
    _dragPosition = dragDistance / (screenWidth / 2);

    // Limit drag position
    if (_dragPosition > 1.0) {
      _dragPosition = 1.0;
    } else if (_dragPosition < -1.0) {
      _dragPosition = -1.0;
    }

    setState(() {});
  }

  void _onDragEnd(DragEndDetails details) {
    _isDragging = false;
    final velocity = details.velocity.pixelsPerSecond.dx;
    final screenWidth = MediaQuery.of(context).size.width;

    if (_dragPosition.abs() > 0.5 || velocity.abs() > screenWidth) {
      // Complete the swipe
      _animation = Tween<double>(
        begin: _dragPosition,
        end: _dragPosition > 0 ? 1.0 : -1.0,
      ).animate(_controller);
      _controller.forward();
    } else {
      // Return to center
      _animation = Tween<double>(
        begin: _dragPosition,
        end: 0.0,
      ).animate(_controller);
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final position = _isDragging ? _dragPosition : _animation.value;
    final angle = position * 0.2;
    final x = position * screenWidth * 0.5;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: GestureDetector(
            onHorizontalDragStart: _onDragStart,
            onHorizontalDragUpdate: _onDragUpdate,
            onHorizontalDragEnd: _onDragEnd,
            child: Transform.translate(
              offset: Offset(x, 0),
              child: Transform.rotate(
                angle: angle,
                child: Container(
                  width: screenWidth * 0.85,
                  decoration: NeoOttomanTheme.ornateCardDecoration,
                  child: Stack(
                    children: [
                      // Ottoman pattern background with overlay
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Opacity(
                            opacity: 0.5,
                            child: Image.asset(
                              'assets/images/ottoman_pattern_beige.jpeg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),

                      // Ornate border decoration
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: NeoOttomanTheme.gold,
                              width: 3,
                            ),
                          ),
                        ),
                      ),

                      // Card content
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Title with Ottoman-style decoration
                            Text(
                              widget.event.title,
                              style: NeoOttomanTheme.cardTitleStyle.copyWith(
                                color: NeoOttomanTheme.royalBlue,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 5),

                            // Image if available
                            if (widget.event.imagePath != null) ...[
                              Expanded(
                                flex: 3,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: NeoOttomanTheme.gold,
                                      width: 1.5,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 6,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.asset(
                                      widget.event.imagePath!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],

                            // Description with Ottoman-style scroll
                            Expanded(
                              flex: widget.event.imagePath != null ? 2 : 5,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: NeoOttomanTheme.ivory.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color:
                                        NeoOttomanTheme.gold.withOpacity(0.7),
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: SingleChildScrollView(
                                    child: Center(
                                      child: Text(
                                        widget.event.description,
                                        textAlign: TextAlign.center,
                                        style: NeoOttomanTheme.cardTextStyle
                                            .copyWith(
                                          height: 1.6,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Swipe instructions with Ottoman-style
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  // No option
                                  Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade800,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: NeoOttomanTheme.gold,
                                            width: 1,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.arrow_back,
                                          color: NeoOttomanTheme.ivory,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      if (widget.event != null)
                                        Container(
                                          constraints: const BoxConstraints(
                                              maxWidth: 120),
                                          child: Text(
                                            widget.event.noImpact.optionText,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                    ],
                                  ),

                                  // Yes option
                                  Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade800,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: NeoOttomanTheme.gold,
                                            width: 1,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.arrow_forward,
                                          color: NeoOttomanTheme.ivory,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      if (widget.event != null)
                                        Container(
                                          constraints: const BoxConstraints(
                                              maxWidth: 120),
                                          child: Text(
                                            widget.event.yesImpact.optionText,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Decision indicators with Ottoman-style seals
                      if (position != 0)
                        Positioned(
                          top: 30,
                          right: position > 0 ? 30 : null,
                          left: position < 0 ? 30 : null,
                          child: Transform.rotate(
                            angle: position > 0 ? -math.pi / 12 : math.pi / 12,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: position > 0
                                    ? Colors.green.shade800.withOpacity(0.9)
                                    : Colors.red.shade800.withOpacity(0.9),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: NeoOttomanTheme.gold,
                                  width: 2,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black38,
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Text(
                                position > 0 ? 'EVET' : 'HAYIR',
                                style: const TextStyle(
                                  color: NeoOttomanTheme.ivory,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
