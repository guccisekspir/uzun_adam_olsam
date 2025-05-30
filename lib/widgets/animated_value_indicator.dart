import 'package:flutter/material.dart';

class AnimatedValueIndicator extends StatefulWidget {
  final String label;
  final int value;
  final int? previousValue;
  final Color color;
  final bool animate;

  const AnimatedValueIndicator({
    Key? key,
    required this.label,
    required this.value,
    this.previousValue,
    required this.color,
    this.animate = false,
  }) : super(key: key);

  @override
  State<AnimatedValueIndicator> createState() => _AnimatedValueIndicatorState();
}

class _AnimatedValueIndicatorState extends State<AnimatedValueIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _valueAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  
  int _displayValue = 0;
  double _progressValue = 0.0;
  bool _showChangeIndicator = false;
  int _changeAmount = 0;

  @override
  void initState() {
    super.initState();
    _displayValue = widget.value;
    _progressValue = widget.value / 100;
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.2),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0),
        weight: 70,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0),
        weight: 20,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _controller.addListener(() {
      setState(() {
        _displayValue = _valueAnimation.value;
        _progressValue = _progressAnimation.value;
      });
    });
    
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _showChangeIndicator = false;
        });
      }
    });
    
    _setupAnimation();
  }
  
  void _setupAnimation() {
    final int startValue = widget.previousValue ?? widget.value;
    final double startProgress = startValue / 100;
    
    _valueAnimation = IntTween(
      begin: startValue,
      end: widget.value,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _progressAnimation = Tween<double>(
      begin: startProgress,
      end: widget.value / 100,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    if (widget.previousValue != null) {
      _changeAmount = widget.value - widget.previousValue!;
      _showChangeIndicator = _changeAmount != 0;
    }
  }

  @override
  void didUpdateWidget(AnimatedValueIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.animate && widget.previousValue != null && 
        widget.value != widget.previousValue) {
      _setupAnimation();
      _controller.forward(from: 0.0);
    } else if (widget.value != oldWidget.value && !widget.animate) {
      setState(() {
        _displayValue = widget.value;
        _progressValue = widget.value / 100;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: widget.color,
          ),
        ),
        const SizedBox(height: 4),
        Stack(
          alignment: Alignment.center,
          children: [
            // Value circle with animation
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: widget.animate ? _scaleAnimation.value : 1.0,
                  child: child,
                );
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: widget.color,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _displayValue.toString(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _getValueColor(_displayValue),
                    ),
                  ),
                ),
              ),
            ),
            
            // Change indicator
            if (_showChangeIndicator)
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Opacity(
                    opacity: _opacityAnimation.value,
                    child: child,
                  );
                },
                child: Positioned(
                  top: -15,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _changeAmount > 0 ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _changeAmount > 0 ? '+$_changeAmount' : '$_changeAmount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 60,
          height: 5,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2.5),
            child: LinearProgressIndicator(
              value: _progressValue,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(_getValueColor(_displayValue)),
            ),
          ),
        ),
      ],
    );
  }

  Color _getValueColor(int value) {
    if (value <= 20) {
      return Colors.red;
    } else if (value <= 40) {
      return Colors.orange;
    } else if (value <= 60) {
      return Colors.yellow[700]!;
    } else if (value <= 80) {
      return Colors.lightGreen;
    } else {
      return Colors.green;
    }
  }
}
