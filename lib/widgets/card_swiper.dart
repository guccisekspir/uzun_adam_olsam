import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event_card.dart';
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

    return Center(
      child: GestureDetector(
        onHorizontalDragStart: _onDragStart,
        onHorizontalDragUpdate: _onDragUpdate,
        onHorizontalDragEnd: _onDragEnd,
        child: Transform.translate(
          offset: Offset(x, 0),
          child: Transform.rotate(
            angle: angle,
            child: Container(
              width: screenWidth * 0.50,
              height: screenHeight * 0.4,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Card content
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          widget.event.title,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),

                        // Image if available
                        if (widget.event.imagePath != null) ...[
                          Expanded(
                            flex: 3,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                widget.event.imagePath!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Description
                        Expanded(
                          flex: widget.event.imagePath != null ? 2 : 5,
                          child: SingleChildScrollView(
                            child: Text(
                              widget.event.description,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        ),
                        // Kaydırma talimatları
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  const Icon(Icons.arrow_back,
                                      color: Colors.red),
                                  Text(
                                    'HAYIR',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (widget.event != null)
                                    Text(
                                      widget.event.noImpact.optionText,
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                ],
                              ),
                              Column(
                                children: [
                                  const Icon(Icons.arrow_forward,
                                      color: Colors.green),
                                  Text(
                                    'EVET',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (widget.event != null)
                                    Text(
                                      widget.event.yesImpact.optionText,
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Decision indicators
                  if (position != 0)
                    Positioned(
                      top: 16,
                      right: position > 0 ? 16 : null,
                      left: position < 0 ? 16 : null,
                      child: Transform.rotate(
                        angle: position > 0 ? -angle : angle,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: position > 0 ? Colors.green : Colors.red,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            position > 0 ? 'EVET' : 'HAYIR',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
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
    );
  }
}
