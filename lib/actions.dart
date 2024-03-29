import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

// Action to update the theme of the app (dark mode or light mode)
class UpdateThemeAction {
  final bool isDarkMode;

  UpdateThemeAction(this.isDarkMode);
}

// Action to update the visibility of the send button based on the text field content
class UpdateSendButtonVisibilityAction {
  final bool isVisible;

  UpdateSendButtonVisibilityAction(this.isVisible);
}

// Action to update the selected index of the bottom navigation bar
class UpdateSelectedIndexAction {
  final int selectedIndex;

  UpdateSelectedIndexAction(this.selectedIndex);
}

// Action to reset the chat ID when starting a new chat session
class ResetChatIdAction {}

// Action to set the chat ID for the current chat session
class SetChatIdAction {
  final String? chatId;

  SetChatIdAction(this.chatId);
}

// Action to add a new message to the chat
class AddMessageAction {
  final types.Message message;

  AddMessageAction(this.message);
}

// Action to update the list of messages in the chat
class UpdateMessagesAction {
  final List<types.Message> messages;

  UpdateMessagesAction(this.messages);
}

// Action to update image details in the state after generating an image
class UpdateImageDetailsAction {
  final int imageId;
  final String imageUrl;
  final String fileName;
  final int fileSize;

  UpdateImageDetailsAction(this.imageId, this.imageUrl, this.fileName, this.fileSize);
}
