import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drop/features/auth/presentation/pages/splash_page.dart';

/// Proves the cold-start splash lockup is TRUE-CENTERED — the logo box and the
/// loading bar share the window's horizontal centre — at a macOS window size.
/// This is a layout assertion against the real widget, not a claim.
void main() {
  Future<void> pumpSplashAt(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: SplashPage(onAnimationComplete: () {}, isBootstrapping: true),
      ),
    );
    // The Lottie asset can't load in the test harness → errorBuilder fires and
    // the DropLogo fallback renders. One frame is enough to lay it all out.
    await tester.pump();
  }

  testWidgets('logo ARTWORK (not just its frame box) is centered on a 1440×900 '
      'macOS window', (tester) async {
    await pumpSplashAt(tester, const Size(1440, 900));

    const screenCentre = Offset(1440 / 2, 900 / 2);

    // logoWidth = (1440 * 0.32).clamp(240, 440) = 440. Target that exact box —
    // robust against Flutter's many internal RepaintBoundary/SizedBox wrappers.
    final logoBox = tester.getRect(
      find.byWidgetPredicate(
        (w) => w is SizedBox && w.width == 440.0,
        description: 'logo SizedBox (width 440)',
      ),
    );
    final column = tester.getRect(find.byType(Column).first);

    expect(
      column.center.dx,
      moreOrLessEquals(screenCentre.dx, epsilon: 0.5),
      reason: 'Column centre must equal the window centre',
    );

    // The DROP artwork sits kLogoVisualCenterOffset (720×405 composition px)
    // away from the frame's geometric centre; the page compensates with the
    // inverse Transform.translate. Horizontally the ARTWORK must land on the
    // window centre: box centre + offset·scale == window centre.
    final scale = 440.0 / 720.0;
    expect(
      logoBox.center.dx + kLogoVisualCenterOffset.dx * scale,
      moreOrLessEquals(screenCentre.dx, epsilon: 0.5),
      reason: 'Artwork centre must equal the window centre (horizontal)',
    );

    // Vertically the logo is the column's top section (wordmark + bar sit
    // below), so the invariant is: the box was LIFTED from its natural layout
    // slot (column top + half box height) by exactly offset.dy·scale — which
    // puts the artwork, not the padded frame, where layout intended.
    const boxHeight = 440.0 * 9 / 16;
    final naturalCentreY = column.top + boxHeight / 2;
    expect(
      logoBox.center.dy,
      moreOrLessEquals(
        naturalCentreY - kLogoVisualCenterOffset.dy * scale,
        epsilon: 0.5,
      ),
      reason: 'Logo box must be lifted by the measured compensation',
    );
  });

  testWidgets('OPERATIONS glyphs (not the text box) are horizontally centered', (
    tester,
  ) async {
    await pumpSplashAt(tester, const Size(1440, 900));

    // This engine appends letterSpacing (12) after the LAST glyph too
    // (verified by TextPainter: width('AB', ls:12) - width('AB', ls:0) == 24),
    // so the glyph run sits 6px left of the text box centre. The page
    // compensates with a 12px leading pad; net: glyph centre == text box
    // centre − 6 == window centre.
    final textRect = tester.getRect(find.text('OPERATIONS'));
    final glyphCentreX = textRect.center.dx - 12 / 2;
    expect(
      glyphCentreX,
      moreOrLessEquals(1440 / 2, epsilon: 0.5),
      reason: 'OPERATIONS glyph run must be centred on the window',
    );
  });

  // The COMBINED visible bounding box — artwork top (not the Lottie frame's
  // padded top) down to the loading bar's bottom — must sit exactly
  // kSplashOpticalLift above the window's geometric centre. This is the
  // owner-specified framing: the whole lockup centred as ONE unit, lifted to
  // the optical centre.
  Future<void> expectLockupFraming(WidgetTester tester, Size window) async {
    await pumpSplashAt(tester, window);

    final logoWidth = (window.width * 0.32).clamp(240.0, 440.0);
    final logoBox = tester.getRect(
      find.byWidgetPredicate(
        (w) => w is SizedBox && w.width == logoWidth,
        description: 'logo SizedBox (width $logoWidth)',
      ),
    );
    final bar = tester.getRect(
      find.byWidgetPredicate(
        (w) =>
            w is Container &&
            w.constraints ==
                const BoxConstraints.tightFor(width: 240, height: 3.5),
        description: 'premium loading bar (240×3.5)',
      ),
    );

    // Artwork top inside the (already compensation-lifted) logo box.
    final boxH = logoWidth * 9 / 16;
    final artworkTop = logoBox.top + kLogoArtworkTop / 405 * boxH;
    final visibleCentreY = (artworkTop + bar.bottom) / 2;

    expect(
      visibleCentreY,
      moreOrLessEquals(window.height / 2 - kSplashOpticalLift, epsilon: 1.0),
      reason:
          'combined lockup bbox centre must sit kSplashOpticalLift above '
          'the window centre',
    );
  }

  testWidgets(
    'combined lockup bbox (logo artwork → bar) is framed at the optical '
    'centre on 1440×900',
    (tester) async => expectLockupFraming(tester, const Size(1440, 900)),
  );

  testWidgets(
    'combined lockup bbox keeps its framing at the minimum 1024×720 window',
    (tester) async => expectLockupFraming(tester, const Size(1024, 720)),
  );

  testWidgets('column stays horizontally centered at the minimum window', (
    tester,
  ) async {
    await pumpSplashAt(tester, const Size(1024, 720));
    final column = tester.getRect(find.byType(Column).first);
    expect(column.center.dx, moreOrLessEquals(1024 / 2, epsilon: 0.5));
  });
}
