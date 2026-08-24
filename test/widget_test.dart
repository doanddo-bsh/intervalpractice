// Smoke test for the real app entry point (`IntervalPracticeApp` in
// lib/app.dart).
//
// `IntervalPracticeApp` wires up ChangeNotifierProvider<AdCounter> +
// ScreenUtilInit + MaterialApp, with `LoadingPage` hardwired as `home`.
// `LoadingPage` starts a 1500ms `Timer` in initState() that
// pushReplacement-navigates to `InitializeScreen`. Naively pumping
// `IntervalPracticeApp` once and stopping there fails testWidgets teardown
// ("A Timer is still pending even after the widget tree was disposed"),
// because that Timer is never cancelled in LoadingPage's dispose().
//
// So this test pumps *past* the timer deliberately instead of avoiding it.
// `InitializeScreen` itself only navigates on to `HomePage` (which builds a
// real AdMob `BannerAd`/`AdWidget`, unsafe under `flutter test`) *after* an
// `await` on the AdMob consent SDK's
// `ConsentInformation.instance.requestConsentInfoUpdate(...)`, which talks
// to a MethodChannel. Under `flutter test`, with no handler registered for
// that channel, that call's completer never resolves, so the second
// navigation never happens — we settle on `InitializeScreen` and stay
// there. This was verified empirically: pumping substantially past the
// timer (many extra seconds of virtual time) never produces a BannerAd/
// AdWidget or any caught exception, across repeated runs.
//
// Coverage: this exercises IntervalPracticeApp's real theme setup, its
// ChangeNotifierProvider<AdCounter> (asserted reachable via Provider.of
// below), and the LoadingPage -> InitializeScreen navigation — it fails if
// any of those break. It deliberately STOPS at InitializeScreen (blocked on
// the AdMob consent call, by design — see above), so it does NOT build or
// exercise anything past that point: HomePage and every screen reachable
// only from there (quiz screens, settings, etc.) are untested here.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import 'package:intervalpractice/app.dart';
import 'package:intervalpractice/state/ad_counter.dart';

void main() {
  testWidgets(
      'IntervalPracticeApp builds, shows LoadingPage, and transitions to '
      'InitializeScreen without touching AdMob', (WidgetTester tester) async {
    await tester.pumpWidget(const IntervalPracticeApp());
    await tester.pump();

    // The real provider/theme shell builds a single MaterialApp.
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(tester.takeException(), isNull);

    // LoadingPage (IntervalPracticeApp's home) is showing.
    expect(find.text('음 정 박 사'), findsOneWidget);

    // Let LoadingPage's 1500ms Timer fire, then let the pushReplacement
    // route transition animation settle.
    await tester.pump(const Duration(milliseconds: 1600));
    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.takeException(), isNull);

    // We've navigated off LoadingPage to InitializeScreen.
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('음 정 박 사'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(AdWidget), findsNothing);

    // The real AdCounter provider from IntervalPracticeApp is reachable
    // from this point in the tree — fails if the ChangeNotifierProvider
    // wrapper in IntervalPracticeApp.build() is ever removed or broken.
    final providerContext =
        tester.element(find.byType(CircularProgressIndicator));
    expect(Provider.of<AdCounter>(providerContext, listen: false), isNotNull);

    // Pump substantially more virtual time: InitializeScreen's post-frame
    // callback awaits an AdMob consent MethodChannel call with no handler
    // registered, so it should never resolve and never navigate on to
    // HomePage (which would build a real BannerAd/AdWidget).
    await tester.pump(const Duration(seconds: 5));
    expect(tester.takeException(), isNull);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(AdWidget), findsNothing);
  });
}
