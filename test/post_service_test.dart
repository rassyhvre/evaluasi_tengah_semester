// ==========================================================
// Unit Test untuk fitur Post (PostService)
// Referensi: https://docs.flutter.dev/cookbook/testing/unit/mocking
// ==========================================================
//
// Fitur yang dipilih: Fetch Posts dari API (PostService)
//
// ┌──────────────────────────────────────────────────────────┐
// │  PENJELASAN MOCKING:                                     │
// │                                                          │
// │  Kita menggunakan Mockito untuk membuat MOCK dari        │
// │  http.Client. Dengan mock ini, kita TIDAK perlu          │
// │  memanggil API asli (https://dummyjson.com).             │
// │                                                          │
// │  Mock memungkinkan kita:                                 │
// │  - Mengontrol response yang dikembalikan                 │
// │  - Mensimulasikan error tanpa server down                │
// │  - Test berjalan cepat (tanpa network)                   │
// │  - Test konsisten (tidak flaky)                          │
// │                                                          │
// │  Yang di-mock: http.Client (via @GenerateNiceMocks)      │
// │  Yang di-test: PostService.fetchPosts()                  │
// └──────────────────────────────────────────────────────────┘

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:login_app/data/services/post_service.dart';
import 'package:login_app/models/post_model.dart';

// ══════════════════════════════════════════════════════════════
// 🔧 MOCKING: Generate MockHttpClient menggunakan Mockito
// Annotation ini akan membuat class MockHttpClient secara otomatis
// yang mengimplementasikan http.Client TANPA memanggil API asli.
// File yang di-generate: post_service_test.mocks.dart
// ══════════════════════════════════════════════════════════════
@GenerateNiceMocks([MockSpec<http.Client>()])
import 'post_service_test.mocks.dart';

void main() {
  // ══════════════════════════════════════════════════════════
  // 📋 Group: PostService.fetchPosts()
  // Fitur: Mengambil daftar post dari DummyJSON API
  // ══════════════════════════════════════════════════════════
  group('PostService - fetchPosts()', () {
    // Deklarasi variabel yang digunakan di setiap test
    late MockClient mockClient; // 🔧 MOCK: http.Client palsu
    late PostService postService;

    setUp(() {
      // 🔧 MOCKING: Membuat instance MockHttpClient
      // MockHttpClient ini MENGGANTIKAN http.Client asli
      // sehingga tidak ada request ke internet yang sesungguhnya
      mockClient = MockClient();

      // Inject mock client ke PostService
      // (bukan http.Client() asli)
      postService = PostService(client: mockClient);
    });

    // ══════════════════════════════════════════════════════════
    // ✅ TEST 1: SUCCESS CASE
    // Skenario: API mengembalikan response 200 dengan data valid
    // ══════════════════════════════════════════════════════════
    test('SUCCESS - mengembalikan List<PostModel> jika API response 200',
        () async {
      // 🔧 MOCKING: Mengatur mock agar mengembalikan response sukses
      // when() + thenAnswer() = atur behavior mock
      // Mock ini menggantikan panggilan HTTP asli ke dummyjson.com
      when(mockClient.get(Uri.parse('https://dummyjson.com/posts?limit=5')))
          .thenAnswer(
        (_) async => http.Response(
          '{"posts": [{"id": 1, "title": "Post Pertama", "body": "Isi post pertama"}, '
          '{"id": 2, "title": "Post Kedua", "body": "Isi post kedua"}]}',
          200, // Status code sukses
        ),
      );

      // Act: Panggil method yang ditest
      final result = await postService.fetchPosts();

      // Assert: Verifikasi hasilnya
      expect(result, isA<List<PostModel>>());
      expect(result.length, 2);
      expect(result[0].id, 1);
      expect(result[0].title, 'Post Pertama');
      expect(result[0].body, 'Isi post pertama');
      expect(result[1].id, 2);
      expect(result[1].title, 'Post Kedua');

      // 🔧 MOCKING: Verifikasi bahwa mock dipanggil tepat 1 kali
      verify(mockClient.get(Uri.parse('https://dummyjson.com/posts?limit=5')))
          .called(1);
    });

    // ══════════════════════════════════════════════════════════
    // ❌ TEST 2: ERROR CASE
    // Skenario: API mengembalikan response error (404, 500, dll)
    // ══════════════════════════════════════════════════════════
    test('ERROR - melempar Exception jika API response 404', () async {
      // 🔧 MOCKING: Mengatur mock agar mengembalikan response error
      // Di sini kita simulasikan server mengembalikan 404 Not Found
      // tanpa perlu server yang benar-benar down
      when(mockClient.get(Uri.parse('https://dummyjson.com/posts?limit=5')))
          .thenAnswer(
        (_) async => http.Response('Not Found', 404),
      );

      // Assert: Pastikan fetchPosts() melempar Exception
      expect(
        () => postService.fetchPosts(),
        throwsA(isA<Exception>()),
      );

      // 🔧 MOCKING: Verifikasi mock dipanggil
      verify(mockClient.get(Uri.parse('https://dummyjson.com/posts?limit=5')))
          .called(1);
    });

    // ══════════════════════════════════════════════════════════
    // ❌ TEST 2b: ERROR CASE - Server Error 500
    // Skenario: Internal Server Error
    // ══════════════════════════════════════════════════════════
    test('ERROR - melempar Exception jika API response 500', () async {
      // 🔧 MOCKING: Simulasi server error 500
      when(mockClient.get(Uri.parse('https://dummyjson.com/posts?limit=5')))
          .thenAnswer(
        (_) async => http.Response('Internal Server Error', 500),
      );

      // Assert
      expect(
        () => postService.fetchPosts(),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('500'),
          ),
        ),
      );
    });

    // ══════════════════════════════════════════════════════════
    // 🔶 TEST 3: EDGE CASE
    // Skenario: API response 200 tetapi data posts kosong (empty list)
    // Ini penting untuk memastikan app tidak crash
    // ketika belum ada post di database
    // ══════════════════════════════════════════════════════════
    test('EDGE CASE - mengembalikan list kosong jika API response posts kosong',
        () async {
      // 🔧 MOCKING: Response 200 tapi array posts kosong
      // Ini edge case karena server sukses tapi data nya kosong
      when(mockClient.get(Uri.parse('https://dummyjson.com/posts?limit=5')))
          .thenAnswer(
        (_) async => http.Response(
          '{"posts": []}', // Array kosong
          200,
        ),
      );

      // Act
      final result = await postService.fetchPosts();

      // Assert: Harus mengembalikan list kosong, BUKAN error
      expect(result, isA<List<PostModel>>());
      expect(result.length, 0);
      expect(result.isEmpty, true);

      // 🔧 MOCKING: Verifikasi mock dipanggil
      verify(mockClient.get(Uri.parse('https://dummyjson.com/posts?limit=5')))
          .called(1);
    });

    // ══════════════════════════════════════════════════════════
    // 🔶 TEST 3b: EDGE CASE - Network Exception (tidak ada internet)
    // Skenario: Client melempar exception (simulasi offline)
    // ══════════════════════════════════════════════════════════
    test('EDGE CASE - melempar Exception jika tidak ada koneksi internet',
        () async {
      // 🔧 MOCKING: Simulasi network failure
      // thenThrow() membuat mock melempar exception
      // seolah-olah device tidak punya koneksi internet
      when(mockClient.get(Uri.parse('https://dummyjson.com/posts?limit=5')))
          .thenThrow(
        Exception('No internet connection'),
      );

      // Assert: Pastikan exception dilempar
      expect(
        () => postService.fetchPosts(),
        throwsA(isA<Exception>()),
      );
    });
  });
}

// ══════════════════════════════════════════════════════════════
// 📌 RINGKASAN PENGGUNAAN MOCKING:
//
// 1. @GenerateNiceMocks([MockSpec<http.Client>()])
//    → Membuat class MockHttpClient otomatis via Mockito
//
// 2. mockClient = MockHttpClient()
//    → Instance mock yang menggantikan http.Client asli
//
// 3. PostService(client: mockClient)
//    → Inject mock ke PostService (bukan client asli)
//
// 4. when(mockClient.get(...)).thenAnswer(...)
//    → Mengatur response palsu yang dikembalikan mock
//
// 5. when(mockClient.get(...)).thenThrow(...)
//    → Mengatur mock untuk melempar exception
//
// 6. verify(mockClient.get(...)).called(1)
//    → Memastikan mock dipanggil sesuai ekspektasi
//
// SEMUA TEST DI ATAS MENGGUNAKAN MOCKING.
// Tidak ada satupun test yang memanggil API asli dummyjson.com.
// ══════════════════════════════════════════════════════════════
