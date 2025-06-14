import 'dart:async';
import 'dart:math';

import 'package:alice/model/alice_http_call.dart';
import 'package:alice/ui/common/alice_navigation.dart';
import 'package:flutter/material.dart';

import 'alice_core.dart';
import 'expandable_fab.dart';

class DebugPopUp extends StatefulWidget {
  final VoidCallback onClicked;
  final Stream<List<AliceHttpCall>> callsSubscription;
  final AliceCore aliceCore;

  const DebugPopUp({
    super.key,
    required this.onClicked,
    required this.callsSubscription,
    required this.aliceCore,
  });

  @override
  State<DebugPopUp> createState() => _DebugPopUpState();
}

class _DebugPopUpState extends State<DebugPopUp> {
  final _expandedDistance = 80.0;
  late final Size _size = MediaQuery.of(context).size;
  late final double _rightSide = _expandedDistance + kToolbarHeight + 20;
  Offset _offset = Offset.zero;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _offset = Offset(
        _size.width - _rightSide,
        _size.height / 2 - _expandedDistance,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          Positioned(
            left: _offset.dx,
            top: _offset.dy,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() => _offset += details.delta);
              },
              child: _buildDraggyWidget(
                widget.onClicked,
                widget.callsSubscription,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraggyWidget(
    VoidCallback onClicked,
    Stream<List<AliceHttpCall>> stream,
  ) {
    return ExpandableFab(
      distance: _expandedDistance,
      bigButton: Opacity(
        opacity: 0.6,
        child: FloatingActionButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          onPressed: onClicked,
          mini: true,
          enableFeedback: true,
          child: StreamBuilder<List<AliceHttpCall>>(
            initialData: const [],
            stream: stream,
            builder: (_, sns) {
              final counter = min(sns.data?.length ?? 0, 99);
              return Text("$counter");
            },
          ),
        ),
      ),
      children: [
        ActionButton(
          onPressed: () {
            widget.aliceCore.removeCalls();
          },
          icon: const Icon(Icons.delete, color: Colors.white),
        ),
        ActionButton(
          onPressed: () {
            AliceNavigation.navigateToCallsList(core: widget.aliceCore);
          },
          icon: const Icon(Icons.insert_chart, color: Colors.white),
        ),
      ],
    );
  }
}
