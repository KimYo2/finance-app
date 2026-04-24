// === FILE: lib/services/ai_service.dart ===
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../models/transaction_model.dart';

class AiService {
  static AiService? _instance;
  late GenerativeModel _model;
  late ChatSession _chat;

  factory AiService() {
    _instance ??= AiService._internal();
    return _instance!;
  }

  AiService._internal();

  static const String _systemPrompt = '''
Kamu adalah asisten keuangan pribadi yang cerdas dalam aplikasi Personal Finance.
Tugasmu adalah membantu pengguna mencatat transaksi keuangan dari percakapan natural.

KEMAMPUANMU:
1. Ekstrak informasi transaksi dari teks natural bahasa Indonesia/Inggris
2. Tentukan apakah itu pemasukan (income) atau pengeluaran (expense)
3. Ekstrak nominal, kategori, dan catatan
4. Berikan saran keuangan sederhana jika diminta

KATEGORI YANG TERSEDIA:
- Pengeluaran: Makanan, Transportasi, Belanja, Hiburan, Kesehatan, Pendidikan, Tagihan, Lainnya
- Pemasukan: Gaji, Bonus, Usaha, Investasi, Hadiah, Lainnya

JIKA USER INGIN CATAT TRANSAKSI, balas dalam format JSON TEPAT ini:
{
  "action": "add_transaction",
  "data": {
    "type": "expense" atau "income",
    "amount": angka (tanpa titik/koma),
    "category": "nama kategori",
    "note": "deskripsi singkat",
    "date": "YYYY-MM-DD"
  },
  "message": "pesan konfirmasi dalam Bahasa Indonesia"
}

JIKA HANYA PERCAKAPAN BIASA atau PERTANYAAN, balas dengan:
{
  "action": "chat",
  "message": "respons dalam Bahasa Indonesia yang ramah dan helpful"
}

CONTOH:
User: "tadi makan siang 35rb"
Response: {"action":"add_transaction","data":{"type":"expense","amount":35000,"category":"Makanan","note":"makan siang","date":"2026-04-24"},"message":"Oke! Pengeluaran makan siang Rp 35.000 sudah dicatat 🍽️"}

User: "gajian 5 juta"  
Response: {"action":"add_transaction","data":{"type":"income","amount":5000000,"category":"Gaji","note":"gaji bulanan","date":"2026-04-24"},"message":"Mantap! Pemasukan gaji Rp 5.000.000 berhasil dicatat 💰"}

User: "berapa pengeluaran aku bulan ini?"
Response: {"action":"chat","message":"Untuk melihat total pengeluaran, kamu bisa cek tab Laporan ya!"}

PENTING: Selalu balas dalam format JSON valid. Jangan tambahkan teks di luar JSON.
''';

  bool _isInitialized = false;

  Future<void> initialize() async {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    
    if (apiKey.isEmpty) {
      debugPrint('WARNING: GEMINI_API_KEY tidak ditemukan di .env');
      return;
    }
    
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.3,
        maxOutputTokens: 512,
      ),
    );
    _chat = _model.startChat(
      history: [
        Content.system(_systemPrompt),
      ],
    );
    _isInitialized = true;
  }

  Future<AiResponse> sendMessage(String message, DateTime currentDate) async {
    if (!_isInitialized) {
      return AiResponse(
        action: AiAction.chat,
        message: 'API Key Gemini belum dikonfigurasi. '
                 'Tambahkan GEMINI_API_KEY di file .env ya! 🔑\n\n'
                 'Cara dapat API key gratis:\n'
                 '1. Buka aistudio.google.com\n'
                 '2. Klik "Get API Key"\n'
                 '3. Copy dan paste ke file .env',
      );
    }
    
    try {
      final messageWithContext =
          '$message\n[Tanggal hari ini: ${currentDate.toIso8601String().split('T')[0]}]';

      final response = await _chat.sendMessage(
        Content.text(messageWithContext),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception('Request timeout'),
      );

      final responseText = response.text ?? '';
      if (responseText.isEmpty) {
        throw Exception('Empty response from AI');
      }

      return _parseResponse(responseText);
    } on Exception catch (e) {
      debugPrint('AI Error: $e');
      String errorMsg = 'Maaf, AI sedang tidak tersedia. 😅';
      if (e.toString().contains('timeout')) {
        errorMsg = 'Koneksi AI timeout. Coba lagi ya! ⏱️';
      } else if (e.toString().contains('API_KEY')) {
        errorMsg = 'API Key tidak valid. Cek file .env kamu ya! 🔑';
      } else if (e.toString().contains('quota')) {
        errorMsg = 'Kuota API habis untuk hari ini. Coba besok! 📊';
      }
      return AiResponse(action: AiAction.chat, message: errorMsg);
    }
  }

  Future<AiResponse> parseOcrText(String ocrText, DateTime currentDate) async {
    try {
      final prompt =
          'Tolong analisis struk/nota berikut dan ekstrak informasi transaksi:\n\n'
          '$ocrText\n\n'
          'Tentukan: total nominal (dalam angka polos tanpa titik/koma), kategori yang paling tepat dari list ini: Makanan, Transportasi, Belanja, Hiburan, Kesehatan, Pendidikan, Tagihan, Lainnya, Gaji, Bonus, Usaha, Investasi, Hadiah, dan catatan singkat. Balas dalam format JSON saja.';

      final response = await _chat.sendMessage(
        Content.text(prompt),
      );

      final responseText = response.text ?? '';

      return _parseResponse(responseText);
    } catch (e) {
      return AiResponse(
        action: AiAction.chat,
        message: 'Gagal memproses struk. Coba lagi ya! 😅',
      );
    }
  }

  AiResponse _parseResponse(String responseText) {
    try {
      String cleaned = responseText
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      final json = jsonDecode(cleaned) as Map<String, dynamic>;
      final action = json['action'] as String;

      if (action == 'add_transaction') {
        final data = json['data'] as Map<String, dynamic>;
        final transaction = TransactionModel(
          title: data['category'] as String,
          amount: (data['amount'] as num).toDouble(),
          type: data['type'] as String,
          category: data['category'] as String,
          date: DateTime.parse(data['date'] as String),
          note: data['note'] as String? ?? '',
        );
        return AiResponse(
          action: AiAction.addTransaction,
          transaction: transaction,
          message: json['message'] as String,
        );
      } else {
        return AiResponse(
          action: AiAction.chat,
          message: json['message'] as String,
        );
      }
    } catch (e) {
      return AiResponse(
        action: AiAction.chat,
        message: responseText,
      );
    }
  }
}

enum AiAction { chat, addTransaction }

class AiResponse {
  final AiAction action;
  final String message;
  final TransactionModel? transaction;

  AiResponse({
    required this.action,
    required this.message,
    this.transaction,
  });
}