import 'package:flutter/material.dart';

import 'domain/models.dart';
import 'state/game_controller.dart';
import 'ui/screens/archive_page.dart';
import 'ui/screens/ending_page.dart';
import 'ui/screens/game_page.dart';
import 'ui/screens/home_page.dart';

class SoulWheelApp extends StatefulWidget {
  const SoulWheelApp({super.key, required this.controller});

  final GameController controller;

  @override
  State<SoulWheelApp> createState() => _SoulWheelAppState();
}

enum _AppPage { home, game, archive, ending }

class _SoulWheelAppState extends State<SoulWheelApp> {
  _AppPage _page = _AppPage.home;
  GameState? _archivedState;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_refresh);
  }

  @override
  void didUpdateWidget(covariant SoulWheelApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_refresh);
      widget.controller.addListener(_refresh);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _startFromEnding() async {
    final navigatorContext = _navigatorKey.currentContext;
    if (navigatorContext == null) return;
    if (_archivedState != null && widget.controller.canContinue) {
      final choice = await showDialog<String>(
        context: navigatorContext,
        builder: (dialogContext) => AlertDialog(
          title: const Text('当前人生尚未结束'),
          content: const Text('你正在查看旧档案。开启新人生前，请先决定如何处理仍在进行的人生。'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, 'continue'),
              child: const Text('继续当前人生'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, 'archive'),
              child: const Text('归档后开始'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, 'replace'),
              child: const Text('覆盖并开始'),
            ),
          ],
        ),
      );
      switch (choice) {
        case 'continue':
          if (mounted) {
            setState(() {
              _archivedState = null;
              _page = _AppPage.game;
            });
          }
          return;
        case 'archive':
          await widget.controller.abandonCurrentLife();
        case 'replace':
          break;
        default:
          return;
      }
    }
    await widget.controller.startNew();
    if (mounted) {
      setState(() {
        _archivedState = null;
        _page = _AppPage.game;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: '斗罗命运转盘',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xffb99046),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xff10131d),
      ),
      home: PopScope(
        canPop: _page == _AppPage.home,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _handleBack();
        },
        child: _buildPage(),
      ),
    );
  }

  Future<void> _handleBack() async {
    switch (_page) {
      case _AppPage.home:
        return;
      case _AppPage.archive:
        setState(() => _page = _AppPage.home);
        return;
      case _AppPage.ending:
        setState(() {
          _page = _archivedState == null ? _AppPage.home : _AppPage.archive;
          _archivedState = null;
        });
        return;
      case _AppPage.game:
        final navigatorContext = _navigatorKey.currentContext;
        if (navigatorContext == null) return;
        final leave = await showDialog<bool>(
          context: navigatorContext,
          builder: (dialogContext) => AlertDialog(
            title: const Text('返回首页？'),
            content: const Text('当前人生已经自动保存，返回首页后仍可继续。'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('留在当前人生'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('保存并返回'),
              ),
            ],
          ),
        );
        if (leave == true && mounted) setState(() => _page = _AppPage.home);
    }
  }

  Widget _buildPage() {
    switch (_page) {
      case _AppPage.home:
        return HomePage(
          controller: widget.controller,
          onStart: () async {
            await widget.controller.startNew();
            if (mounted) setState(() => _page = _AppPage.game);
          },
          onAbandonAndStart: () async {
            await widget.controller.abandonCurrentLife();
            await widget.controller.startNew();
            if (mounted) setState(() => _page = _AppPage.game);
          },
          onContinue: () async {
            await widget.controller.continueSavedLife();
            if (mounted) setState(() => _page = _AppPage.game);
          },
          onArchive: () => setState(() => _page = _AppPage.archive),
        );
      case _AppPage.game:
        return GamePage(
          controller: widget.controller,
          onFinished: () => setState(() => _page = _AppPage.ending),
        );
      case _AppPage.archive:
        return ArchivePage(
          archives: widget.controller.archives,
          onBack: () => setState(() => _page = _AppPage.home),
          onOpen: (state) => setState(() {
            _archivedState = state;
            _page = _AppPage.ending;
          }),
          onDelete: widget.controller.deleteArchive,
          onRename: widget.controller.renameArchive,
          onFavorite: widget.controller.setArchiveFavorite,
          onLock: widget.controller.setArchiveLocked,
          onExport: widget.controller.exportArchives,
          onImport: widget.controller.importArchives,
        );
      case _AppPage.ending:
        final archivedState = _archivedState;
        final state = archivedState ?? widget.controller.state;
        if (state == null) {
          return HomePage(
            controller: widget.controller,
            onStart: () async {
              await widget.controller.startNew();
              if (mounted) setState(() => _page = _AppPage.game);
            },
            onAbandonAndStart: () async {
              await widget.controller.abandonCurrentLife();
              await widget.controller.startNew();
              if (mounted) setState(() => _page = _AppPage.game);
            },
            onContinue: () async {
              await widget.controller.continueSavedLife();
              if (mounted) setState(() => _page = _AppPage.game);
            },
            onArchive: () => setState(() => _page = _AppPage.archive),
          );
        }
        return EndingPage(
          state: state,
          onRestart: _startFromEnding,
          onHome: () => setState(() {
            _archivedState = null;
            _page = _AppPage.home;
          }),
          onBackToArchive: archivedState == null
              ? null
              : () => setState(() {
                  _archivedState = null;
                  _page = _AppPage.archive;
                }),
          onDelete: archivedState == null
              ? null
              : () async {
                  await widget.controller.deleteArchive(archivedState);
                  if (mounted) {
                    setState(() {
                      _archivedState = null;
                      _page = _AppPage.archive;
                    });
                  }
                },
        );
    }
  }
}
