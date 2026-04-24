// === FILE: lib/services/ocr_service.dart ===
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class OcrService {
  final TextRecognizer _textRecognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );
  final ImagePicker _imagePicker = ImagePicker();

  Future<File?> pickImage({bool fromCamera = true}) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
      );
      if (image == null) return null;
      return File(image.path);
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  Future<String> extractText(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText =
          await _textRecognizer.processImage(inputImage);
      return recognizedText.text;
    } catch (e) {
      throw Exception('Gagal membaca teks dari gambar: $e');
    }
  }

  String buildOcrPrompt(String extractedText) {
    return 'Tolong analisis struk/nota berikut dan ekstrak informasi transaksi:\n\n'
        '$extractedText\n\n'
        'Tentukan: total nominal (dalam angka polos tanpa titik/koma), kategori yang '
        'paling tepat dari list ini: Makanan, Transportasi, Belanja, Hiburan, '
        'Kesehatan, Pendidikan, Tagihan, Lainnya, Gaji, Bonus, Usaha, Investasi, '
        'Hadiah, dan catatan singkat. Balas dalam format JSON saja.';
  }

  void dispose() {
    _textRecognizer.close();
  }
}