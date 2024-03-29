import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class AppState {
  final bool isDarkMode;
  final bool isSendButtonVisible;
  final int selectedIndex;
  final String? chatId;
  final List<types.Message> messages;
  final int? imageId;
  final String? imageUrl;
  final String? fileName;
  final int? fileSize;

  AppState({
    required this.isDarkMode,
    required this.isSendButtonVisible,
    required this.selectedIndex,
    this.chatId,
    required this.messages,
    this.imageId,
    this.imageUrl,
    this.fileName,
    this.fileSize,
  });

  AppState.initial()
      : isDarkMode = false,
        isSendButtonVisible = false,
        selectedIndex = 0,
        chatId = null,
        messages = [],
        imageId = null,
        imageUrl = null,
        fileName = null,
        fileSize = null;

  AppState copyWith({
    bool? isDarkMode,
    bool? isSendButtonVisible,
    int? selectedIndex,
    String? chatId,
    List<types.Message>? messages,
    int? imageId,
    String? imageUrl,
    String? fileName,
    int? fileSize,
  }) {
    return AppState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isSendButtonVisible: isSendButtonVisible ?? this.isSendButtonVisible,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      chatId: chatId ?? this.chatId,
      messages: messages ?? this.messages,
      imageId: imageId ?? this.imageId,
      imageUrl: imageUrl ?? this.imageUrl,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
    );
  }
}
