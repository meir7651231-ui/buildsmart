// ✨ אטום-תצוגה מפורק (Layer C חי · נספח Conversation) · PureBubble — בועת-הודעה הלובשת ערכה מהחריץ.
// incoming=משטח-נייטרל≠outgoing=מילוי-אקצנט (tail א-סימטרי דרך BorderRadiusDirectional, מודע-RTL) ·
// system=מתאר מרוכז · sending=raised. timestamp LTR+tnum · read-tick=accent-מורף, delivered=שחור-רך.
// נייטרל/דיו קבועים (DsPure); רק האקצנט+הפונט זורמים דרך החריץ (DsSeam). התוכן מוזרק (חוק-5/6). material בלבד.
import 'package:flutter/material.dart';
import 'ds/ds_pure.dart';
import 'ds/ds_seam.dart';

enum PureBubbleKind { incoming, outgoing, system, sending }

enum PureReceipt { none, sent, delivered, read }

class PureBubble extends StatelessWidget {
  final String text;
  final String time;
  final PureBubbleKind kind;
  final PureReceipt receipt;
  const PureBubble({
    super.key,
    required this.text,
    this.time = '',
    this.kind = PureBubbleKind.incoming,
    this.receipt = PureReceipt.none,
  });

  @override
  Widget build(BuildContext context) {
    final theme = DsSeam.of(context); // ערכת-האקצנט הפעילה
    final fonts = DsSeam.fontsOf(context); // חבילת-הפונט הפעילה

    if (kind == PureBubbleKind.system) {
      return Align(
        alignment: Alignment.center,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            border: Border.all(color: DsPure.hair),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(text, style: TextStyle(color: DsPure.mut, fontSize: 11.5, fontFamily: fonts.grotesk)),
        ),
      );
    }

    final out = kind == PureBubbleKind.outgoing;
    final sending = kind == PureBubbleKind.sending;
    final endSide = out || sending;
    return Align(
      alignment: endSide ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        padding: const EdgeInsets.fromLTRB(13, 9, 13, 7),
        decoration: BoxDecoration(
          color: sending ? DsPure.raised : (out ? null : DsPure.surface),
          gradient: (out && !sending)
              ? LinearGradient(colors: [theme.aHi, theme.a], begin: Alignment.topLeft, end: Alignment.bottomRight)
              : null,
          border: out ? null : Border.all(color: DsPure.hair),
          borderRadius: BorderRadiusDirectional.only(
            topStart: Radius.circular(out ? 16 : 5),
            topEnd: Radius.circular(out ? 5 : 16),
            bottomStart: const Radius.circular(16),
            bottomEnd: const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                color: out ? DsPure.sunken : (sending ? DsPure.mut : DsPure.ink),
                fontSize: 13.5,
                height: 1.42,
                fontFamily: fonts.he,
              ),
            ),
            if (time.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      time,
                      textDirection: TextDirection.ltr,
                      style: TextStyle(
                        fontFamily: fonts.grotesk,
                        fontFeatures: const [FontFeature.tabularFigures()],
                        fontSize: 9.5,
                        color: out ? Colors.black54 : DsPure.faint,
                      ),
                    ),
                    if (out && receipt != PureReceipt.none) ...[
                      const SizedBox(width: 5),
                      Icon(
                        receipt == PureReceipt.sent ? Icons.done : Icons.done_all,
                        size: 13,
                        color: receipt == PureReceipt.read ? theme.a800 : Colors.black54,
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
