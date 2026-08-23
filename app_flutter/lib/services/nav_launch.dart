// SERVER-SWAP — navigation launch sheet (#111 · Wave-2 contract 3).
//
// [openNavSheet] shows an RTL bottom sheet with two buttons — "פתח ב-Waze" and
// "פתח ב-Google Maps" — each launching an external URL to the destination.
//
// Launch reuse: this hands the Uri to the SAME injectable seam the contact
// 📞/💬 buttons use — [urlLauncherProvider] (widgets/contact_actions.dart →
// state/url_launcher_seam.dart). Production = the real `launchUrl(...,
// externalApplication)` (the OS picks the Waze/Maps app, or the browser on
// web); tests `overrideWithValue` a capturing fake to assert the exact Uri.
// We reach the provider via [ProviderScope.containerOf] so this stays a plain
// `BuildContext` helper (no WidgetRef needed at the call sites).
//
// Targeting: when [lat]/[lng] are given we navigate to the exact coordinate;
// otherwise we fall back to a text [label] search query. No coordinate is ever
// invented — a label-only call produces a label-only URL.
//
// SERVER-SWAP (embedded map): an in-sheet interactive map preview is NOT
// implemented — it needs a Google Maps / Mapbox API key + billing. Until that
// key exists we only deep-link out to the installed nav apps (honest, no
// fake/blank map tile).

import 'package:buildsmart/state/url_launcher_seam.dart';
import 'package:buildsmart/theme/app_theme.dart' show bsOnAccent;
import 'package:buildsmart/theme/tokens.dart';
import 'package:buildsmart/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// True when both coordinates are present (a real point to navigate to).
bool _hasCoords(double? lat, double? lng) => lat != null && lng != null;

/// Waze deep link — `ll=lat,lng&navigate=yes` for a point, else `q=<label>`.
Uri _wazeUri({required String label, double? lat, double? lng}) =>
    _hasCoords(lat, lng)
        ? Uri.parse('https://waze.com/ul?ll=$lat,$lng&navigate=yes')
        : Uri.https('waze.com', '/ul', {'q': label});

/// Google Maps deep link — directions to a point, else a search by [label].
/// Uses the documented `?api=1` universal-URL form (resolves to the app when
/// installed, the browser otherwise).
Uri _googleMapsUri({required String label, double? lat, double? lng}) =>
    _hasCoords(lat, lng)
        ? Uri.https('www.google.com', '/maps/dir/', {
            'api': '1',
            'destination': '$lat,$lng',
          })
        : Uri.https('www.google.com', '/maps/search/', {
            'api': '1',
            'query': label,
          });

/// Opens the RTL navigation sheet for [label] (optionally at [lat]/[lng]).
///
/// Two ≥48dp buttons launch Waze / Google Maps via [urlLauncherProvider]. On a
/// launch failure (no handler / blocked) an honest toast is shown; the sheet
/// closes once a target is chosen.
Future<void> openNavSheet(
  BuildContext context, {
  required String label,
  double? lat,
  double? lng,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetCtx) => Directionality(
      textDirection: TextDirection.rtl,
      child: _NavSheet(label: label, lat: lat, lng: lng),
    ),
  );
}

class _NavSheet extends StatelessWidget {
  const _NavSheet({required this.label, this.lat, this.lng});

  final String label;
  final double? lat;
  final double? lng;

  /// Reuses the contact-buttons launch seam (real launcher in prod, fake in
  /// tests) reached through the surrounding ProviderScope — no WidgetRef here.
  Future<void> _launch(BuildContext context, Uri uri) async {
    final launcher = ProviderScope.containerOf(context, listen: false)
        .read(urlLauncherProvider);
    final ok = await launcher(uri);
    if (!context.mounted) return;
    Navigator.of(context).pop();
    if (!ok) showToast(context, 'לא ניתן לפתוח אפליקציית ניווט');
  }

  @override
  Widget build(BuildContext context) {
    final title = label.trim().isEmpty ? 'ניווט ליעד' : 'ניווט אל $label';
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.all(BsTokens.space3),
        padding: const EdgeInsets.all(BsTokens.space5),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(BsTokens.radiusCard),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: BsTokens.typeSubhead,
                fontWeight: FontWeight.w700,
                color: BsTokens.inkLight,
              ),
            ),
            const SizedBox(height: BsTokens.space4),
            _NavButton(
              label: 'פתח ב-Waze',
              icon: Icons.navigation,
              onTap: () => _launch(
                context,
                _wazeUri(label: label, lat: lat, lng: lng),
              ),
            ),
            const SizedBox(height: BsTokens.space3),
            _NavButton(
              label: 'פתח ב-Google Maps',
              icon: Icons.map,
              onTap: () => _launch(
                context,
                _googleMapsUri(label: label, lat: lat, lng: lng),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A full-width ≥48dp accent button — `bsOnAccent` foreground over the brand
/// fill so label/icon stay legible in either theme.
class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = bsOnAccent(context);
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: fg, size: BsTokens.dialIconSize),
        label: Text(
          label,
          style: TextStyle(
            color: fg,
            fontSize: BsTokens.typeBody,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: BsTokens.brand,
          foregroundColor: fg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(BsTokens.radiusCard),
          ),
        ),
      ),
    );
  }
}
