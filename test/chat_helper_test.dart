import 'package:flutter_test/flutter_test.dart';
import 'package:droovo_mobile_public/helpers/chat_helper.dart';
import 'package:droovo_mobile_public/models/message.dart';

import 'helpers/test_data.dart';

void main() {
  group('ChatHelper.truncateMessage', () {
    test('leaves short messages untouched', () {
      expect(ChatHelper.truncateMessage('hello'), equals('hello'));
    });

    test('truncates long messages and appends an ellipsis', () {
      final result = ChatHelper.truncateMessage(
        'This message is definitely too long',
        limit: 10,
      );
      expect(result, equals('This messa...'));
      expect(result.length, equals(13)); // 10 chars + '...'
    });
  });

  group('ChatHelper.getLatestMessage', () {
    test('returns the message with the most recent timestamp', () {
      final group = TestData.groupByUid('group-001');
      final latest = ChatHelper.getLatestMessage(group);

      expect(latest?.uid, equals('msg-003'));
    });

    test('returns null for a group with no chat history', () {
      final group = TestData.groupByUid('group-002');
      expect(ChatHelper.getLatestMessage(group), isNull);
    });
  });

  group('ChatHelper.areGroupsEqual', () {
    test('true when ids, names, and latest message timestamps match', () {
      final groups = TestData.groups;
      expect(ChatHelper.areGroupsEqual(groups, groups), isTrue);
    });

    test('false when a new message arrives in one of the groups', () {
      final original = TestData.groups;
      final updated = TestData.groups.map((g) {
        if (g.id != 'group-001') return g;
        return Group(
          id: g.id,
          name: g.name,
          chats: [
            ...g.chats,
            Message(
              uid: 'msg-004',
              senderId: 'user-passenger-1',
              message: 'On est presque arrives !',
              time: DateTime.parse('2030-01-15T08:10:00.000Z'),
            ),
          ],
        );
      }).toList();

      expect(ChatHelper.areGroupsEqual(original, updated), isFalse);
    });

    test('false when the list lengths differ', () {
      final groups = TestData.groups;
      expect(ChatHelper.areGroupsEqual(groups, [groups.first]), isFalse);
    });
  });
}
