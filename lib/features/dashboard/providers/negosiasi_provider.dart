import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reseller_app_tav/features/dashboard/models/negosiasi_chat_response_model.dart';
import 'package:reseller_app_tav/features/dashboard/models/negosiasi_counter_response_model.dart';
import 'package:reseller_app_tav/features/dashboard/models/negosiasi_response_model.dart';
import 'package:reseller_app_tav/features/dashboard/models/transaksi_response_model.dart';
import 'package:reseller_app_tav/features/dashboard/services/negosiasi_service.dart';
import 'package:reseller_app_tav/features/dashboard/services/socket_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NegotiationProvider extends ChangeNotifier {
  final NegotiationService _negotiationService = NegotiationService();
  final SocketService _socketService = SocketService();
  final Map<int, String> _localImageCache = {};
  final List<int> _selectedChatIds = [];
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  NegotiationResult? _selectedNegotiationDetail;
  NegotiationResult? get selectedNegotiationDetail =>
      _selectedNegotiationDetail;

  NegotiationService get negotiationService => _negotiationService;

  bool _isDetailLoading = false;
  bool get isDetailLoading => _isDetailLoading;
  bool _isDeleteMode = false;
  bool get isDeleteMode => _isDeleteMode;

  bool _isTransactionLoading = false;
  bool get isTransactionLoading => _isTransactionLoading;

  List<NegotiationResult> _transactions = [];
  List<NegotiationResult> get transactions => _transactions;

  List<int> get selectedChatIds => _selectedChatIds;

  List<NegotiationResult> _negotiations = [];
  List<NegotiationResult> get negotiations => _negotiations;
  List<NegotiationCounterItem> _counters = [];
  List<NegotiationCounterItem> get counters => _counters;
  List<NegotiationChatItem> _chatMessages = [];
  List<NegotiationChatItem> get chatMessages => _chatMessages;

  bool _isChatLoading = false;
  bool get isChatLoading => _isChatLoading;

  int _currentPage = 1;
  int _lastPage = 1;
  bool _hasMoreData = true;
  bool get hasMoreData => _hasMoreData;

  final Set<int> _requestedPaymentIds = {};
  Set<int> get requestedPaymentIds => _requestedPaymentIds;

  int get totalNewNegotiations {
    final newItem = _counters.firstWhere(
      (element) => element.status.toUpperCase() == 'NEW',
      orElse: () => NegotiationCounterItem(status: 'NEW', total: 0),
    );
    return newItem.total;
  }

  NegotiationProvider() {
    _initSocket();
  }

  void _initSocket() {
    _socketService.init("https://socket-erp.tavmobil.co.id");
    _socketService.connect();
    _socketService.clearChatListeners();
  }

  void listenNegotiationChat(int negotiationId, int currentUserId) {
    debugPrint(
      '[SOCKET] Menjalankan setupSocket untuk Room ID: $negotiationId dan user Id: $currentUserId',
    );

    _socketService.joinRoom(negotiationId.toString(), currentUserId.toString());
    _socketService.clearChatListeners();

    // ================= 1. LISTEN RECEIVE MESSAGE (MENERIMA DARI ADMIN) =================
    _socketService.onReceiveMessage((data) {
      debugPrint('===[SOCKET] REALTIME SIGNAL DETECTED ===');
      try {
        final dynamic rawRoomId = data['room_id'];
        final int socketRoomId = int.tryParse(rawRoomId?.toString() ?? '') ?? 0;

        if (socketRoomId != negotiationId) return;

        String determinedType = data['type_user'] ?? data['type'] ?? 'admin';
        final dynamic rawUserId = data['user_id'];
        final int? socketUserId = int.tryParse(rawUserId?.toString() ?? '');

        final dynamic rawChatId = data['chat_id'] ?? data['id'];
        final String socketChatIdStr = rawChatId?.toString() ?? '';

        final String? incomingPesan = data['pesan'];
        final int? socketNominal = data['nominal'] is String
            ? int.tryParse(data['nominal'])
            : data['nominal'];

        if (incomingPesan == null && socketNominal == null) return;

        final chatItem = NegotiationChatItem(
          id:
              int.tryParse(socketChatIdStr) ??
              DateTime.now().millisecondsSinceEpoch,
          negotiationId: socketRoomId,
          userIdPengirim: socketUserId ?? 0,
          pengirimName: data['pengirim_name'] ?? "Admin",
          pesan: incomingPesan,
          nominal: socketNominal,
          typeUser: determinedType.toLowerCase(),
          waktu: data['waktu'] ?? DateFormat('HH:mm').format(DateTime.now()),
          logNegotiationChat: [],
        );

        final bool isAlreadyExists = _chatMessages.any((element) {
          final String localIdStr = element.id.toString();

          if (localIdStr == socketChatIdStr) return true;

          if (incomingPesan != null && element.pesan == incomingPesan) {
            return true;
          }

          if (incomingPesan != null &&
              incomingPesan.contains('||TEXT_MSG:') &&
              element.pesan != null) {
            final String incomingTextOnly = incomingPesan.split(
              '||TEXT_MSG:',
            )[1];
            if (element.pesan!.contains(incomingTextOnly)) return true;
          }

          return false;
        });

        if (!isAlreadyExists) {
          _chatMessages = [chatItem, ..._chatMessages];
          notifyListeners();
          debugPrint(
            '[FLUTTER UI RENDER] Dipaksa menggambar ulang halaman chat.',
          );
        } else {
          debugPrint(
            '[SOCKET FILTER] Sinyal diabaikan karena data gambar/teks sudah dirender oleh UI.',
          );
        }
      } catch (e) {
        debugPrint(' Gagal render socket: $e');
      }
    });

    // ================= 2. LISTEN UPDATE NOMINAL =================
    _socketService.onUpdateNominal((data) {
      debugPrint('SOCKET: Event update_nominal terdeteksi');
      fetchDetailNegotiation(negotiationId);
    });

    // ================= 3. LISTEN RECEIVE APPROVAL & REJECTION =================
    _socketService.onReceiveApproval((data) {
      debugPrint('SOCKET: Event receive_approval / reject terdeteksi');
      try {
        final String chatIdFromSocket = data['chat_id']?.toString() ?? '';
        final String actionFromSocket =
            data['action']?.toString() ?? ''; // 'approve' atau 'reject'

        for (int i = 0; i < _chatMessages.length; i++) {
          if (_chatMessages[i].id.toString() == chatIdFromSocket) {
            _chatMessages[i] = _chatMessages[i].copyWith(
              isApprove: actionFromSocket == 'approve',
            );
            notifyListeners();
            break;
          }
        }

        // 🟢 Panggil fungsi ini agar selectedNegotiationDetail.status diperbarui ke REJECT_COO/CEO secara realtime
        fetchDetailNegotiation(negotiationId);
        fetchAllNegotiations(isRefresh: true);
      } catch (e) {
        debugPrint('APPROVAL/REJECT SOCKET ERROR: $e');
      }
    });

    // ================= 4. LISTEN REALTIME READ STATUS (ADMIN JOIN ROOM) =================
    _socketService.onCustomEvent("user_read", (data) {
      debugPrint('===[SOCKET] ADMIN JOINED/READ ROOM DETECTED ===');
      try {
        final dynamic rawRoomId = data['room_id'];
        final int socketRoomId = int.tryParse(rawRoomId?.toString() ?? '') ?? 0;

        if (socketRoomId != negotiationId) return;

        for (int i = 0; i < _chatMessages.length; i++) {
          if (_chatMessages[i].typeUser.toLowerCase() == 'agen') {
            _chatMessages[i] = _chatMessages[i].copyWith(
              logNegotiationChat: [
                LogNegotiationChat(
                  id: DateTime.now().millisecondsSinceEpoch,
                  negotiationChatId: _chatMessages[i].id,
                  userId: 0,
                  typeUser: 'admin', // Agar terdeteksi oleh ChatCardWidget
                  isRead: true, // Status dibaca aktif
                  name: 'Admin', // Nama pembaca
                  status: 'READ', // Tanda status
                ),
              ],
            );
          }
        }

        notifyListeners();
        debugPrint(
          '[SOCKET READ] Berhasil mengubah status seluruh pesan menjadi centang dua.',
        );
      } catch (e) {
        debugPrint('Gagal memproses realtime read status: $e');
      }
    });
  }

  void joinRoom(int negotiationId, int currentUserId) {
    _socketService.joinRoom(negotiationId.toString(), currentUserId.toString());
    debugPrint(
      'SOCKET EMIT: Gabung ke Room Negosiasi ID: $negotiationId oleh User: $currentUserId',
    );
  }

  void sendChatMessageRealtime({
    required int negotiationId,
    required int currentUserId,
    required String pesan,
    required String pengirimName,
    required String chatId,
    int? nominal,
  }) {
    debugPrint('SOCKET EMIT: Mengirim socket payload via SocketService');

    final String now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    final bool isNominal = nominal != null && nominal > 0;

    final Map<String, dynamic> socketPayload = {
      "room_id": negotiationId.toString(),
      "user_id": currentUserId.toString(),
      "pesan": isNominal ? "" : pesan,
      "approval_by": "",
      "waktu": now,
      "created_at": now,
      "type": isNominal ? "nominal" : "text",
      "pengirim_name": pengirimName,
      "chat_id": chatId,
    };

    if (isNominal) {
      socketPayload["nominal"] = nominal.toDouble();
    }

    _socketService.sendChatMessage(socketPayload);
    debugPrint(
      '[SIMULATOR LOKAL TEST] Mematuk langsung fungsi receive secara internal...',
    );

    // Pura-pura menerima sinyal balik dari socket
    final Map<String, dynamic> mockIncomingData = {
      "room_id": negotiationId,
      "user_id": currentUserId,
      "chat_id": int.tryParse(chatId) ?? 0,
      "pesan": isNominal ? "Menawarkan harga baru" : pesan,
      "nominal": nominal,
      "type_user": "agen",
      "pengirim_name": pengirimName,
      "waktu": DateFormat('HH:mm').format(DateTime.now()),
    };

    // Panggil paksa handler internal Anda
    handleIncomingSocketMessage(mockIncomingData);
  }

  @override
  void dispose() {
    _socketService.disconnect();
    super.dispose();
  }

  Future<void> fetchAllNegotiations({
    bool isRefresh = false,
    int? page,
    int perPage = 10,
    String? filterSingleStatus,
    List<String>? filterMultipleStatus,
    String? startDate,
    String? endDate,
    String? searchCarOrBidder,
  }) async {
    if (page != null) {
      _currentPage = page;
    } else if (isRefresh) {
      _currentPage = 1;
      _negotiations = [];
      _hasMoreData = true;
    }

    if (!_hasMoreData && !isRefresh && page == null) return;

    _isLoading = true;
    _errorMessage = null;
    if (isRefresh) notifyListeners();

    try {
      final response = await _negotiationService.getAllNegotiation(
        page: _currentPage,
        perPage: perPage,
        filterSingleStatus: filterSingleStatus,
        filterMultipleStatus: filterMultipleStatus,
        startDate: startDate,
        endDate: endDate,
        searchCarOrBidder: searchCarOrBidder,
      );

      if (response.status) {
        final dataResult = response.data.result;

        if (isRefresh || page != null) {
          _negotiations = dataResult;
        } else {
          _negotiations.addAll(dataResult);
        }

        _lastPage = response.data.lastPage;

        if (_currentPage >= _lastPage) {
          _hasMoreData = false;
        } else {
          _hasMoreData = true;
          if (page == null) _currentPage++;
        }

        await fetchNegotiationCounter();
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<NegotiationResult?> submitNegotiation({
    int? id,
    required int carId,
    required String bidder,
    required String bidderPhone,
    required int negotiatedPrice,
    required String paymentType,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _negotiationService.upsertNegotiation(
        id: id,
        carId: carId,
        bidder: bidder,
        bidderPhone: bidderPhone,
        negotiatedPrice: negotiatedPrice,
        paymentType: paymentType,
      );

      if (result['status'] == true) {
        // 1. Refresh list data agar data dengan relasi mobil lengkap ditarik dari API server
        await fetchAllNegotiations(isRefresh: true);

        final targetRoom = _negotiations.firstWhere(
          (element) => element.carId == carId && element.bidder == bidder,
          orElse: () =>
              _negotiations.first, // Fallback ke item pertama jika tidak ketemu
        );

        return targetRoom;
      }
      return null;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchNegotiationCounter() async {
    try {
      final response = await _negotiationService.getNegotiationCounter();
      if (response.status) {
        _counters = response.data;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('COUNTER ERROR: ${e.toString()}');
    }
  }

  Future<void> fetchDetailNegotiation(int id) async {
    _isDetailLoading = true;
    _errorMessage = null;
    _selectedNegotiationDetail = null;
    notifyListeners();

    try {
      final detailData = await _negotiationService.getDetailNegotiation(id);
      _selectedNegotiationDetail = detailData;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isDetailLoading = false;
      notifyListeners();
    }
  }

  void clearDetailData() {
    _selectedNegotiationDetail = null;
    notifyListeners();
  }

  void clearChats() {
    _chatMessages = [];
    _isChatLoading = false;
    notifyListeners();
  }

  void prepareNewChatRoom() {
    _chatMessages = [];
    _isChatLoading = true;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> fetchRoomChats(int negotiationId) async {
    try {
      final List<NegotiationChatItem> fetchedChats = await _negotiationService
          .getNegotiationChats(negotiationId);

      final prefs = await SharedPreferences.getInstance();
      final List<NegotiationChatItem> processedChats = [];

      for (var chat in fetchedChats) {
        String? finalPesan = chat.pesan;

        // 1. Cek cache lokal terlebih dahulu jika dia bernilai null/empty
        if (finalPesan == null || finalPesan.isEmpty) {
          final cachedPath = prefs.getString('img_cache_${chat.id}');
          if (cachedPath != null) {
            finalPesan = cachedPath;
          }
        }

        // 2. Pengaman Tambahan: Jika chat memiliki field gambar terpisah dari API (sesuaikan field-nya)
        // jika struktur JSON dari getNegotiationChats menyediakan properti seperti chat.gambar / chat.file
        // finalPesan = finalPesan ?? chat.gambar;

        processedChats.add(chat.copyWith(pesan: finalPesan));
      }

      _chatMessages = processedChats.reversed.toList();
      notifyListeners();
    } catch (e) {
      debugPrint("Error memuat chat: $e");
    }
  }

  Future<void> _saveImageToCache(int chatId, String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('img_cache_$chatId', path);
  }

  Future<void> sendChatMessage({
    required int negotiationId,
    required int currentUserId,
    required String pengirimName,
    String? pesan,
    int? nominal,
    File? gambarFile,
  }) async {
    debugPrint("=== [START TRIGGER SEND MESSAGE] ===");

    final String waktuSekarang = DateFormat('HH:mm').format(DateTime.now());

    // Ini string payload lokal untuk kebutuhan Optimistic UI Anda sendiri
    String localPayloadText = pesan ?? "";
    final int temporaryChatId = DateTime.now().millisecondsSinceEpoch;

    if (gambarFile != null) {
      localPayloadText =
          "LOCAL_FILE:${gambarFile.path}${pesan != null ? '||TEXT_MSG:$pesan' : ''}";
      _localImageCache[temporaryChatId] = localPayloadText;
    }

    if (localPayloadText.isEmpty && nominal == null) return;

    // 1. RENDER OPTIMISTIC UI (Hanya untuk layar internal HP Agen agar responsif instan)
    final localPlaceholder = NegotiationChatItem(
      id: temporaryChatId,
      negotiationId: negotiationId,
      userIdPengirim: currentUserId,
      pengirimName: pengirimName,
      pesan:
          localPayloadText, // Membawa path lokal agar gambar langsung ter-render di UI Anda
      nominal: nominal,
      typeUser: 'agen',
      waktu: waktuSekarang,
      logNegotiationChat: [],
    );

    _chatMessages.insert(0, localPlaceholder);
    notifyListeners();

    try {
      String? finalPesanToSend = pesan;

      // 2. PROSES UPLOAD FILE KE SERVER ASSET S3
      if (gambarFile != null) {
        debugPrint(" [API UPLOAD] Mengunggah file ke bucket S3...");

        final uploadResponse = await _negotiationService.uploadChatFile(
          path: "negotiation",
          file: gambarFile,
        );

        if (uploadResponse != null && uploadResponse['status'] == true) {
          final String uploadedFilePath =
              uploadResponse['data'][0]['file_url'] ?? '';

          if (uploadedFilePath.isNotEmpty) {
            finalPesanToSend = pesan != null && pesan.isNotEmpty
                ? "$uploadedFilePath||TEXT_MSG:$pesan"
                : uploadedFilePath;

            debugPrint("[API UPLOAD] Sukses dapat path S3: $finalPesanToSend");
          }
        } else {
          throw Exception("Gagal mengunggah gambar ke server asset.");
        }
      }

      // 3. KIRIM PESAN DENGAN PATH DARI SERVER KE API HTTP CHAT UTAMA
      final responseData = await _negotiationService.sendNegotiationChat(
        negotiationId: negotiationId,
        pesan: finalPesanToSend, // Jalur asset S3 / teks murni yang valid
        nominal: nominal,
        gambarFile:
            null, // Set null karena file fisik sudah sukses di-upload terpisah
      );

      if (responseData != null &&
          responseData['status'] == true &&
          responseData['data'] != null) {
        final Map<String, dynamic> dataJson = responseData['data'];
        final int? serverChatId = int.tryParse(
          dataJson['id']?.toString() ?? '',
        );

        if (serverChatId != null) {
          final index = _chatMessages.indexWhere(
            (msg) => msg.id == temporaryChatId,
          );

          if (index != -1) {
            // Update placeholder lokal Anda dengan ID resmi server
            _chatMessages[index] = _chatMessages[index].copyWith(
              id: serverChatId,
              pesan: gambarFile != null
                  ? localPayloadText
                  : (finalPesanToSend ?? ""),
            );

            if (gambarFile != null) {
              _localImageCache[serverChatId] = localPayloadText;
              await _saveImageToCache(serverChatId, localPayloadText);
            }

            notifyListeners();
            debugPrint(
              "✅ UI Placeholder berhasil diperbarui dengan ID Server: $serverChatId",
            );
          }

          debugPrint(
            " [SOCKET EMIT REALTIME] Menyiarkan data asset resmi ke Admin...",
          );
          sendChatMessageRealtime(
            negotiationId: negotiationId,
            currentUserId: currentUserId,
            pesan: finalPesanToSend ?? "", //
            pengirimName: pengirimName,
            chatId: serverChatId.toString(), // Gunakan ID resmi server
            nominal: nominal,
          );
        }
      }
    } catch (e) {
      debugPrint("Terjadi kegagalan upload/pencatatan chat: $e");
      _chatMessages.removeWhere((msg) => msg.id == temporaryChatId);
      notifyListeners();
    }
  }

  void handleIncomingSocketMessage(Map<String, dynamic> socketData) {
    debugPrint("SOCKET: Event receive_message terdeteksi");

    final int? chatId = int.tryParse(socketData['chat_id']?.toString() ?? '');
    final String? rawPesan = socketData['pesan'];
    final int? nominal = int.tryParse(socketData['nominal']?.toString() ?? '');

    if (rawPesan == null ||
        rawPesan.toString().trim() == 'null' ||
        rawPesan.toString().trim().isEmpty) {
      if (nominal == null) {
        debugPrint(
          " SOCKET FILTER: Mengabaikan broadcast rusak (Pesan & Nominal NULL).",
        );
        return;
      }
    }

    if (chatId != null) {
      bool isAlreadyExists = _chatMessages.any((msg) => msg.id == chatId);
      if (isAlreadyExists) {
        debugPrint(
          "SOCKET FILTER: Data sudah dirender via Optimistic UI. Skip.",
        );
        return;
      }
    }

    try {
      final String determinedTypeUser =
          socketData['type_user'] ?? socketData['type'] ?? 'admin';

      final incomingItem = NegotiationChatItem(
        id: chatId ?? DateTime.now().millisecondsSinceEpoch,
        negotiationId:
            int.tryParse(socketData['room_id']?.toString() ?? '') ?? 0,
        userIdPengirim:
            int.tryParse(socketData['user_id']?.toString() ?? '') ?? 0,
        pengirimName: socketData['pengirim_name'] ?? "Admin",
        pesan: rawPesan ?? "",
        nominal: nominal,
        typeUser: determinedTypeUser,
        waktu: DateFormat('HH:mm').format(DateTime.now()),
        logNegotiationChat: [],
      );

      _chatMessages.insert(0, incomingItem);
      notifyListeners();
      debugPrint(
        "UI RENDER: Pesan baru dari lawan bicara berhasil ditambahkan.",
      );
    } catch (e) {
      debugPrint("Error parsing socket data: $e");
    }
  }

  void onMessageReceived(
    NegotiationChatItem newMessage, {
    bool isFromSocket = false,
  }) {
    // Ambil info pengirim dari payload socket
    final String serverTypeUser = (newMessage.typeUser ?? '').toLowerCase();
    final int? socketUserId = newMessage.userIdPengirim;

    if (isFromSocket) {
      if (serverTypeUser == 'admin' ||
          serverTypeUser == 'system' ||
          socketUserId == null ||
          socketUserId == 0) {
        debugPrint(
          '📩 [SOCKET RECEIVE]: Menerima pesan realtime baru dari Admin/Sistem.',
        );
      } else {
        // Tapis hanya jika pesan ini datang dari sisi Agen (pengguna aplikasi ini sendiri)
        final String socketIdStr = newMessage.id.toString().trim();
        final int? socketNominal = newMessage.nominal;

        final bool isDuplicate = _chatMessages.any((msg) {
          final String localIdStr = msg.id.toString().trim();

          // TAPISAN 1: Berdasarkan ID Sementara
          if (socketIdStr != 'null' &&
              socketIdStr != '0' &&
              localIdStr != 'null') {
            if (localIdStr == socketIdStr) {
              return true;
            }
          }

          // TAPISAN 2: Berdasarkan Nominal yang sama di waktu yang sama
          if (socketNominal != null &&
              socketNominal > 0 &&
              msg.nominal == socketNominal) {
            if (msg.userIdPengirim == socketUserId &&
                msg.negotiationId == newMessage.negotiationId) {
              return true;
            }
          }

          return false;
        });

        if (isDuplicate) {
          debugPrint(
            '⏭️ [SOCKET IGNORED]: Mengabaikan pantulan socket milik sendiri.',
          );
          return; // Blokir duplikasi milik sendiri
        }
      }
    }

    // Masukkan pesan ke dalam list UI
    // _chatMessages.insert(0, newMessage);
    debugPrint(
      'UI RENDER: Berhasil menambahkan pesan baru. Total chat: ${_chatMessages.length}',
    );
    _chatMessages = [newMessage, ..._chatMessages];
    notifyListeners();
  }

  void toggleDeleteMode(bool enable) {
    _isDeleteMode = enable;
    if (!enable) _selectedChatIds.clear();
    notifyListeners();
  }

  void toggleSelectMessage(int chatId) {
    if (_selectedChatIds.contains(chatId)) {
      _selectedChatIds.remove(chatId);
    } else {
      _selectedChatIds.add(chatId);
    }
    notifyListeners();
  }

  void selectAllMessages(int currentUserId) {
    // Hanya pilih pesan yang dikirim oleh Agen itu sendiri
    final myChatIds = _chatMessages
        .where(
          (msg) =>
              msg.userIdPengirim == currentUserId &&
              msg.typeUser.toLowerCase() == 'agen',
        )
        .map((msg) => msg.id)
        .toList();

    if (_selectedChatIds.length == myChatIds.length) {
      _selectedChatIds.clear();
    } else {
      _selectedChatIds.clear();
      _selectedChatIds.addAll(myChatIds);
    }
    notifyListeners();
  }

  Future<bool> deleteSelectedMessages(int negotiationId) async {
    if (_selectedChatIds.isEmpty) return false;
    _isLoading = true;
    notifyListeners();

    try {
      bool allSuccess = true;
      // Copy array agar tidak memicu concurrent modification error saat looping data
      final idsToDelete = List<int>.from(_selectedChatIds);

      for (int chatId in idsToDelete) {
        final success = await _negotiationService.deleteNegotiationChat(
          negotiationId: negotiationId,
          chatId: chatId,
        );
        if (success) {
          _chatMessages.removeWhere((element) => element.id == chatId);
        } else {
          allSuccess = false;
        }
      }

      toggleDeleteMode(false);
      return allSuccess;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> readChatMessage({
    required int negotiationId,
    required int chatId,
  }) async {
    try {
      final isSuccess = await _negotiationService.readNegotiationChat(
        negotiationId: negotiationId,
        chatId: chatId,
      );

      if (isSuccess) {
        final index = _chatMessages.indexWhere(
          (element) => element.id == chatId,
        );
        if (index != -1) {
          for (var log in _chatMessages[index].logNegotiationChat) {
            if (log.typeUser.toLowerCase() == 'agen') {
              _chatMessages[index] = _chatMessages[index];
              break;
            }
          }
        }
        await fetchNegotiationCounter();
      }
    } catch (e) {
      debugPrint('READ CHAT ERROR: ${e.toString()}');
    }
  }

  Future<bool> deleteChatMessage({
    required int negotiationId,
    required int chatId,
  }) async {
    _errorMessage = null;
    notifyListeners();
    try {
      final isSuccess = await _negotiationService.deleteNegotiationChat(
        negotiationId: negotiationId,
        chatId: chatId,
      );

      if (isSuccess) {
        _chatMessages.removeWhere((element) => element.id == chatId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchTransactions({
    bool isRefresh = false,
    int page = 1,
    int perPage = 10,
    String? searchCarOrBidder,
  }) async {
    _isTransactionLoading = true;
    _errorMessage = null;
    if (isRefresh) {
      _transactions = [];
      notifyListeners();
    }

    try {
      final response = await _negotiationService.getAllTransactions(
        page: page,
        perPage: perPage,
        searchCarOrBidder: searchCarOrBidder,
      );

      if (response.status) {
        _transactions = response.data.result;
        _lastPage = response.data.lastPage;
        _hasMoreData = page < _lastPage;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isTransactionLoading = false;
      notifyListeners();
    }
  }

  bool _isSendingPayment = false;
  bool get isSendingPayment => _isSendingPayment;

  // 🟢 PERBAIKAN SINKRONISASI PENGANGKAPAN EROR DIO PADA PROVIDER
  // 🟢 PERBAIKAN: Gunakan flag khusus kirim agar tidak memblokir screen utama
  Future<Map<String, dynamic>> requestTransactionPayment({
    required int transactionId,
    required int customerId,
  }) async {
    // ❌ SEBELUMNYA: _isTransactionLoading = true; (Ini yang bikin layar abu-abu penuh)
    _isSendingPayment = true; // 🟢 Menggunakan flag khusus pengiriman
    notifyListeners();

    try {
      final res = await _negotiationService.sendPaymentRequest(
        transactionId: transactionId,
        customerId: customerId,
      );

      final resModel = TransaksiResponseModel.fromJson(res.data);

      if (resModel.status) {
        _requestedPaymentIds.add(transactionId);

        // Panggil fetch tanpa loading screen penuh (opsional/tetap aman)
        await fetchTransactions(page: 1, isRefresh: false);
        return {'success': true, 'message': resModel.text};
      }
      return {'success': false, 'message': resModel.text};
    } on DioException catch (e) {
      String errorMessage = "Terjadi kesalahan jaringan.";
      if (e.response?.data != null) {
        try {
          final errorData = TransaksiResponseModel.fromJson(e.response!.data);
          errorMessage = errorData.text.isNotEmpty
              ? errorData.text
              : "Error ${errorData.code}";
        } catch (_) {
          if (e.response?.data is Map) {
            errorMessage =
                e.response?.data['text'] ?? "Terjadi kesalahan server.";
          }
        }
      }
      return {'success': false, 'message': errorMessage};
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
      };
    } finally {
      _isSendingPayment = false; // 🟢 Matikan loading khusus pengiriman
      notifyListeners();
    }
  }
}
