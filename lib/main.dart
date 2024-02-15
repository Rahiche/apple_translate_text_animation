import 'dart:ui';

import 'package:flutter/material.dart';

final List<String> texts = [
  "テをいただけますか？",
  "This is a long English text example for testing purposes.",
  "Per preparare questa ricetta italiana, avrai bisogno di pomodori freschi, basilico, aglio e olio d'oliva.",
  "Un autre texte en français, pour varier.",
  "Aquí tenemos un texto en español.",
];

void main() => runApp(const App());

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int wrapKey = 0;
  String currentText = "";
  int fullDurationInMs = 500;

  @override
  void initState() {
    super.initState();
    currentText = texts[0];
  }

  @override
  Widget build(BuildContext context) {
    int index = 0;

    return MaterialApp(
      theme: ThemeData.dark(useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Dynamic Wrap Key'),
          actions: [
            IconButton(
              onPressed: () async {
                while (true) {
                  setState(() => wrapKey++);
                  await Future.delayed(Duration(milliseconds: 100 * index));
                }
              },
              icon: const Icon(Icons.play_circle),
            ),
          ],
        ),
        backgroundColor: Colors.black,
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton.small(
              onPressed: () {
                fullDurationInMs = fullDurationInMs ~/ 2;
                setState(() {});
              },
              child: const Icon(Icons.remove),
            ),
            const SizedBox(height: 8),
            FloatingActionButton.small(
              onPressed: () {
                fullDurationInMs = fullDurationInMs * 2;
                setState(() {});
              },
              child: const Icon(Icons.add),
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(
                    key: ValueKey<int>(wrapKey),
                    alignment: WrapAlignment.start,
                    children:
                        currentText.split(' ').asMap().entries.map((entry) {
                      String word = entry.value;
                      String spacedWord = '$word ';

                      return Wrap(
                        children:
                            spacedWord.split("").asMap().entries.map((entry) {
                          String letter = entry.value;

                          index++;
                          return AnimatedText(
                            letter: letter,
                            index: index,
                            fullDurationInMs: fullDurationInMs,
                          );
                        }).toList(),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: texts.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          currentText = texts[index];
                          wrapKey++;
                        });
                      },
                      child: Text('${index + 1}'),
                    ),
                  );
                },
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class AnimatedText extends StatefulWidget {
  const AnimatedText({
    super.key,
    required this.letter,
    required this.index,
    required this.fullDurationInMs,
  });

  final String letter;
  final int index;
  final int fullDurationInMs;
  @override
  State<AnimatedText> createState() => _AnimatedTextState();
}

class _AnimatedTextState extends State<AnimatedText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _skewAnimation;
  late Animation<Color?> _colorAnimation;
  late Animation<Color?> _colorWhiteAnimation;

  @override
  void initState() {
    super.initState();
    final fullDurationInMs = widget.fullDurationInMs;

    _controller = AnimationController(
      duration: Duration(milliseconds: fullDurationInMs),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );

    _skewAnimation = Tween<double>(begin: 0, end: 0.4).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.ease),
      ),
    );

    _colorAnimation = ColorTween(
      begin: const Color(0xFF46AFC8),
      end: Colors.lightBlueAccent,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );

    _colorWhiteAnimation = ColorTween(
      begin: Colors.white24,
      end: Colors.white,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );
    Future.delayed(
      Duration(milliseconds: (fullDurationInMs ~/ 8) * widget.index),
      () async {
        if (mounted) {
          _controller.forward();
        }
        await Future.delayed(Duration(milliseconds: fullDurationInMs ~/ 2));
        if (mounted) {
          await _controller.reverse();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final skewed = Matrix4.identity();
        return Transform(
          alignment: Alignment.centerRight,
          transform: skewed
            ..setEntry(3, 2, 0.001)
            ..rotateY(_skewAnimation.value)
            ..scale(_scaleAnimation.value),
          child: Stack(
            children: [
              ImageFiltered(
                imageFilter: ImageFilter.blur(
                  sigmaX: 10,
                  sigmaY: 10,
                  tileMode: TileMode.decal,
                ),
                child: Transform.scale(
                  scale: 1.2,
                  alignment: Alignment.center,
                  child: Text(
                    widget.letter,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w600,
                      color: _colorAnimation.value,
                    ),
                  ),
                ),
              ),
              Text(
                widget.letter,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                  color: _colorAnimation.value,
                ),
              ),
              Text(
                widget.letter,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                  color: _colorWhiteAnimation.value,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
