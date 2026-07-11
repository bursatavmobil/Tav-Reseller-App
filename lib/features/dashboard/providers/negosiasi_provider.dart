import 'package:flutter/material.dart';
import 'package:reseller_app_tav/features/dashboard/models/negosiasi_chat_response_model.dart';
import 'package:reseller_app_tav/features/dashboard/models/negosiasi_counter_response_model.dart';
import 'package:reseller_app_tav/features/dashboard/models/negosiasi_response_model.dart';
import 'package:reseller_app_tav/features/dashboard/services/negosiasi_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class NegotiationProvider extends ChangeNotifier {
  final NegotiationService _negotiationService = NegotiationService();

  late IO.Socket socket;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  NegotiationResult? _selectedNegotiationDetail;
  NegotiationResult? get selectedNegotiationDetail =>
      _selectedNegotiationDetail;

  bool _isDetailLoading = false;
  bool get isDetailLoading => _isDetailLoading;

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
    socket = IO.io('https://xbc.tavmobil.co.id', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.onConnect((_) {
      debugPrint('✅ Terhubung ke Socket Server');
    });

    socket.on('new_message', (data) {
      final newMessage = NegotiationChatItem.fromJson(data);
      _chatMessages.insert(0, newMessage); // Masukkan ke urutan teratas
      notifyListeners();
    });
  }

  void joinRoom(int negotiationId) {
    socket.emit('join_room', {'negotiation_id': negotiationId});
  }

  void sendChatMessageRealtime({
    required int negotiationId,
    required String pesan,
  }) {
    socket.emit('send_message', {
      'negotiation_id': negotiationId,
      'pesan': pesan,
    });
  }

  @override
  void dispose() {
    socket.disconnect();
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

  Future<bool> submitNegotiation({
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
        await fetchAllNegotiations(isRefresh: true);
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
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
      debugPrint('[COUNTER ERROR]: ${e.toString()}');
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
    _isChatLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final List<NegotiationChatItem> chatList = await _negotiationService
          .getNegotiationChats(negotiationId);

      _chatMessages = List<NegotiationChatItem>.from(chatList.reversed);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }
    {
      _isChatLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendChatMessage({
    required int negotiationId,
    String? pesan,
    int? nominal,
  }) async {
    try {
      final responseData = await _negotiationService.sendNegotiationChat(
        negotiationId: negotiationId,
        pesan: pesan,
        nominal: nominal,
      );

      if (responseData['status'] == true && responseData['data'] != null) {
        final newChatItem = NegotiationChatItem.fromJson(responseData['data']);
        onMessageReceived(newChatItem);
      } else {
        await fetchRoomChats(negotiationId);
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  void onMessageReceived(NegotiationChatItem newMessage) {
    final isExist = _chatMessages.any((msg) => msg.id == newMessage.id);
    if (isExist) return;

    _chatMessages.insert(0, newMessage);
    notifyListeners();
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
        // Update status log baca untuk agen menjadi true secara reaktif tanpa re-fetch API
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
        // Perbarui juga data counter notifikasi global di latar belakang jika ada
        await fetchNegotiationCounter();
      }
    } catch (e) {
      debugPrint('❌ [READ CHAT ERROR]: ${e.toString()}');
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
}
