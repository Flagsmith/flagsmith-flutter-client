import 'package:flagsmith/flagsmith.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:test/test.dart';

import '../shared.dart';

const userIdentifier = 'test__user';

void main() {
  group('[Realtime updates]', () {
    late FlagsmithClient fs;
    late DioAdapter _adapter;

    setUp(() async {
      fs = setupSyncClientAdapter(StorageType.inMemory);
      setupAdapter(fs, cb: (config, adapter) {
        _adapter = adapter;
        _adapter.onGet(fs.config.identitiesURI, (server) {
          return server.reply(200, null);
        }, queryParameters: <String, dynamic>{
          'identifier': userIdentifier,
        });
      });
      await fs.initialize();
      await fs.getFeatureFlags();
    });

    tearDown(() {
      fs.close();
    });

    test(
        'If we receive an event that is not environment_updated getFeatureFlags should not be called',
        () async {
      final shouldGetFlags = await fs.onEventReceived(
        SSEModel(data: '', id: '', event: ''),
        0,
      );

      expect(shouldGetFlags, false);
    });

    test(
        'If we receive an event with an updated_at value greater than the last time we got flags, we should get flags',
        () async {
      final secondsSinceEpochNow = DateTime.now().secondsSinceEpoch;
      final shouldGetFlags = await fs.onEventReceived(
        SSEModel(
          data: '{"${FlagsmithClient.updatedAtKey}": $secondsSinceEpochNow}',
          id: '',
          event: FlagsmithClient.environmentUpdatedEvent,
        ),
        secondsSinceEpochNow - 10,
      );

      expect(shouldGetFlags, true);
    });

    test(
        'If we receive an event with an updated_at value less than the last time we got flags, we should not get flags',
        () async {
      final secondsSinceEpochNow = DateTime.now().secondsSinceEpoch;
      final shouldGetFlags = await fs.onEventReceived(
        SSEModel(
          data: '{"${FlagsmithClient.updatedAtKey}": $secondsSinceEpochNow}',
          id: '',
          event: FlagsmithClient.environmentUpdatedEvent,
        ),
        secondsSinceEpochNow + 10,
      );

      expect(shouldGetFlags, false);
    });

    test(
        'If we receive an event with null updated_at value, we should not get flags',
        () async {
      final secondsSinceEpochNow = DateTime.now().secondsSinceEpoch;
      final shouldGetFlags = await fs.onEventReceived(
        SSEModel(
          data: '{"${FlagsmithClient.updatedAtKey}": null}',
          id: '',
          event: FlagsmithClient.environmentUpdatedEvent,
        ),
        secondsSinceEpochNow,
      );

      expect(shouldGetFlags, false);
    });

    test('If we receive an event with invalid JSON, we should not get flags',
        () async {
      final secondsSinceEpochNow = DateTime.now().secondsSinceEpoch;
      final shouldGetFlags = await fs.onEventReceived(
        SSEModel(
          data: '{{"invalid"',
          id: '',
          event: FlagsmithClient.environmentUpdatedEvent,
        ),
        secondsSinceEpochNow,
      );

      expect(shouldGetFlags, false);
    });
  });
}
