import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'ai_service.dart';

/// Generates professional PDF resumes from AI-tailored content.
/// Uses only ASCII-safe characters for PdfStandardFont compatibility.
class PdfService {
  PdfService._();

  // ─── Brand colors ────────────────────────────────────────
  static final PdfColor _primaryColor = PdfColor(102, 126, 234);
  static final PdfColor _accentColor = PdfColor(99, 102, 241);
  static final PdfColor _darkText = PdfColor(30, 30, 50);
  static final PdfColor _mutedText = PdfColor(100, 110, 140);
  static final PdfColor _sectionBg = PdfColor(245, 247, 255);
  static final PdfColor _white = PdfColor(255, 255, 255);

  /// Sanitize text to only contain characters supported by PdfStandardFont.
  /// Replaces common Unicode symbols with ASCII equivalents and strips
  /// any remaining non-Latin-1 characters.
  static String _sanitize(String text) {
    return text
        .replaceAll('\u2022', '-')    // bullet •
        .replaceAll('\u25B8', '-')    // ▸
        .replaceAll('\u25CF', '-')    // ●
        .replaceAll('\u25CB', 'o')    // ○
        .replaceAll('\u2013', '-')    // en dash –
        .replaceAll('\u2014', '--')   // em dash —
        .replaceAll('\u2018', "'")    // left single quote '
        .replaceAll('\u2019', "'")    // right single quote '
        .replaceAll('\u201C', '"')    // left double quote "
        .replaceAll('\u201D', '"')    // right double quote "
        .replaceAll('\u2026', '...')  // ellipsis …
        .replaceAll('\u2010', '-')    // hyphen ‐
        .replaceAll('\u2011', '-')    // non-breaking hyphen ‑
        .replaceAll('\u2012', '-')    // figure dash ‒
        .replaceAll('\u00A0', ' ')    // non-breaking space
        .replaceAll('\u200B', '')     // zero-width space
        .replaceAll('\u200E', '')     // LTR mark
        .replaceAll('\u200F', '')     // RTL mark
        .replaceAll('\uFEFF', '')     // BOM
        .replaceAll(RegExp(r'[^\x00-\xFF]'), '?'); // strip anything beyond Latin-1
  }

  /// Build a polished PDF from a [TailoredResume] for the given [jobTitle].
  static Uint8List generate({
    required TailoredResume resume,
    required String jobTitle,
    String candidateName = 'Your Name',
  }) {
    final document = PdfDocument();
    document.pageSettings.margins.all = 40;
    document.pageSettings.size = PdfPageSize.a4;

    PdfPage currentPage = document.pages.add();
    PdfGraphics graphics = currentPage.graphics;
    final pageWidth = currentPage.getClientSize().width;
    double y = 0;

    // ── Fonts ──────────────────────────────────────────────
    final nameFont = PdfStandardFont(PdfFontFamily.helvetica, 22, style: PdfFontStyle.bold);
    final sectionTitleFont = PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold);
    final subHeaderFont = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold);
    final bodyFont = PdfStandardFont(PdfFontFamily.helvetica, 10);
    final smallFont = PdfStandardFont(PdfFontFamily.helvetica, 9);
    final linkColor = PdfColor(0, 0, 238);

    // ── Helper: check if we need a new page ───────────────
    void checkPageBreak(double neededHeight) {
      if (y + neededHeight > currentPage.getClientSize().height - 40) {
        currentPage = document.pages.add();
        graphics = currentPage.graphics;
        y = 0;
      }
    }

    // ── Helper: draw wrapped text and advance y ───────────
    double drawText(String text, PdfFont font, {PdfColor? color, double indent = 0, PdfTextAlignment alignment = PdfTextAlignment.left, bool isLink = false}) {
      final safe = _sanitize(text);
      final format = PdfStringFormat(
        lineSpacing: 3, 
        alignment: alignment,
      );
      final layoutResult = font.measureString(
        safe,
        layoutArea: Size(pageWidth - indent - 10, 0),
        format: format,
      );
      graphics.drawString(
        safe,
        font,
        brush: PdfSolidBrush(color ?? _darkText),
        bounds: Rect.fromLTWH(indent, y, pageWidth - indent - 10, layoutResult.height + 10),
        format: format,
      );
      
      final height = layoutResult.height + 2;
      y += height;
      return height;
    }

    if (resume.fullResumeText.isNotEmpty) {
      final cleanedLines = resume.fullResumeText
          .replaceAll(RegExp(r'\n{2,}'), '\n\n')
          .trim();
      final lines = cleanedLines.split('\n');

      bool inNameContactSection = false;
      int contactLineIndex = 0;

      for (int i = 0; i < lines.length; i++) {
        final line = lines[i];
        final trimmed = line.trim();
        
        if (trimmed.isEmpty) {
          y += 6; // controlled spacing
          inNameContactSection = false;
          continue;
        }

        checkPageBreak(25);
        
        const validHeaders = {
          'PROFESSIONAL SUMMARY',
          'SKILLS',
          'TECHNICAL SKILLS',
          'TOOLS & TECHNOLOGIES',
          'EXPERIENCE',
          'PROJECTS',
          'EDUCATION',
          'CERTIFICATIONS',
          'ACHIEVEMENTS & LEADERSHIP',
          'NAME & CONTACT'
        };

        final isHeader = validHeaders.contains(trimmed);
        
        if (isHeader) {
          if (trimmed == 'NAME & CONTACT') {
            inNameContactSection = true;
            contactLineIndex = 0;
            continue; // Don't print the words "NAME & CONTACT"
          }

          y += 12; // before header
          checkPageBreak(30);

          // Left Border section (Premium Look)
          graphics.drawRectangle(
            bounds: Rect.fromLTWH(0, y - 2, 3, 16),
            brush: PdfSolidBrush(_primaryColor),
          );

          drawText(trimmed, sectionTitleFont, color: _darkText, indent: 8);
          
          // Draw thin divider line
          graphics.drawLine(
            PdfPen(PdfColor(150, 150, 150), width: 0.5),
            Offset(8, y),
            Offset(pageWidth - 8, y),
          );
          y += 8; // after header
          continue;
        }

        // Deal with Name & Contact specially
        if (inNameContactSection) {
          if (contactLineIndex == 0) {
            drawText(trimmed, nameFont, alignment: PdfTextAlignment.center);
            y += 4;
          } else {
            drawText(trimmed, smallFont, alignment: PdfTextAlignment.center, color: _mutedText);
          }
          contactLineIndex++;
          continue;
        }

        final isBullet = RegExp(r'^[-*•>>]').hasMatch(trimmed);
        if (isBullet) {
          final text = trimmed.replaceFirst(RegExp(r'^[-*•>>]+\s*'), '').trim();
          
          graphics.drawEllipse(
            Rect.fromLTWH(0, y + 5, 3, 3),
            brush: PdfSolidBrush(_darkText),
          );
          
          drawText(text, bodyFont, indent: 12);
        } else {
          bool isSubHeader = trimmed.contains('|') || trimmed.contains('Tech Stack') || trimmed.contains(' - ');
          
          drawText(
            trimmed,
            isSubHeader ? subHeaderFont : bodyFont,
            color: _darkText,
            indent: 0,
          );
        }
      }
    }

    // ── Save ──────────────────────────────────────────────
    final bytes = Uint8List.fromList(document.saveSync());
    document.dispose();
    return bytes;
  }
}
