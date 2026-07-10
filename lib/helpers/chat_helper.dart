import '../models/message.dart';

/// Chat/messaging helpers ported from `ChatHelper` in the private app.
class ChatHelper {
  ChatHelper._();

  /// Shortens a message preview to [limit] characters, appending "...".
  static String truncateMessage(String message, {int limit = 20}) {
    return message.length <= limit
        ? message
        : '${message.substring(0, limit)}...';
  }

  /// Most recent message in a group's chat history, or `null` if empty.
  static Message? getLatestMessage(Group group) {
    if (group.chats.isEmpty) return null;

    final sorted = List<Message>.of(group.chats)
      ..sort((a, b) => b.time.compareTo(a.time));

    return sorted.first;
  }

  /// Whether two group snapshots are equivalent for UI-diffing purposes:
  /// same ids, names, and same latest-message timestamp, in order.
  static bool areGroupsEqual(List<Group> oldList, List<Group> newList) {
    if (oldList.length != newList.length) return false;

    for (var i = 0; i < oldList.length; i++) {
      if (oldList[i].id != newList[i].id) return false;
      if (oldList[i].name != newList[i].name) return false;

      final oldLatest = getLatestMessage(oldList[i])?.time;
      final newLatest = getLatestMessage(newList[i])?.time;
      if (oldLatest != newLatest) return false;
    }

    return true;
  }
}
