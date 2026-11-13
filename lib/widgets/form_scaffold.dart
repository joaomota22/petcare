import 'package:flutter/material.dart';

import '../app_theme.dart';

/// Ecrã de formulário com cabeçalho índigo e uma folha de conteúdo arredondada.
class FormScaffold extends StatelessWidget {
  const FormScaffold({
    super.key,
    required this.title,
    required this.child,
    this.actions = const [],
  });

  final String title;
  final Widget child;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.primary,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 20),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_rounded, color: context.palette.onPrimary),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: context.palette.onPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ),
                  ...actions.map(
                    (a) => IconTheme.merge(
                      data: IconThemeData(color: context.palette.onPrimary),
                      child: a,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: context.palette.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  child: child,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
