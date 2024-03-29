import 'package:redux/redux.dart';
import 'app_state.dart';
import 'actions.dart';

// The main reducer function that combines all the reducers for the AppState
AppState appReducer(AppState state, dynamic action) {
  return AppState(
    isDarkMode: _updateThemeReducer(state.isDarkMode, action),
    isSendButtonVisible: _updateSendButtonVisibilityReducer(state.isSendButtonVisible, action),
    selectedIndex: _updateSelectedIndexReducer(state.selectedIndex, action),
    chatId: _setChatIdReducer(state.chatId, action),
    messages: _updateMessagesReducer(state.messages, action),
    imageId: _updateImageDetailsReducer(state.imageId, action, ImageDetailType.imageId),
    imageUrl: _updateImageDetailsReducer(state.imageUrl, action, ImageDetailType.imageUrl),
    fileName: _updateImageDetailsReducer(state.fileName, action, ImageDetailType.fileName),
    fileSize: _updateImageDetailsReducer(state.fileSize, action, ImageDetailType.fileSize),
  );
}

// Reducer functions for each action
bool _updateThemeReducer(bool isDarkMode, dynamic action) {
  if (action is UpdateThemeAction) {
    return action.isDarkMode;
  }
  return isDarkMode;
}

bool _updateSendButtonVisibilityReducer(bool isVisible, dynamic action) {
  if (action is UpdateSendButtonVisibilityAction) {
    return action.isVisible;
  }
  return isVisible;
}

int _updateSelectedIndexReducer(int selectedIndex, dynamic action) {
  if (action is UpdateSelectedIndexAction) {
    return action.selectedIndex;
  }
  return selectedIndex;
}

String? _setChatIdReducer(String? chatId, dynamic action) {
  if (action is SetChatIdAction) {
    return action.chatId;
  } else if (action is ResetChatIdAction) {
    return null;
  }
  return chatId;
}

List<types.Message> _updateMessagesReducer(List<types.Message> messages, dynamic action) {
  if (action is AddMessageAction) {
    return List.from(messages)..add(action.message);
  } else if (action is UpdateMessagesAction) {
    return action.messages;
  }
  return messages;
}

enum ImageDetailType { imageId, imageUrl, fileName, fileSize }

dynamic _updateImageDetailsReducer(dynamic value, dynamic action, ImageDetailType type) {
  if (action is UpdateImageDetailsAction) {
    switch (type) {
      case ImageDetailType.imageId:
        return action.imageId;
      case ImageDetailType.imageUrl:
        return action.imageUrl;
      case ImageDetailType.fileName:
        return action.fileName;
      case ImageDetailType.fileSize:
        return action.fileSize;
    }
  }
  return value;
}
