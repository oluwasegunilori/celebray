// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(EventNotifier)
final eventProvider = EventNotifierProvider._();

final class EventNotifierProvider
    extends $StreamNotifierProvider<EventNotifier, List<EventModel>> {
  EventNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'eventProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$eventNotifierHash();

  @$internal
  @override
  EventNotifier create() => EventNotifier();
}

String _$eventNotifierHash() => r'fc870b65d75aab3e40723906a7972db3ff8c0fa0';

abstract class _$EventNotifier extends $StreamNotifier<List<EventModel>> {
  Stream<List<EventModel>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<EventModel>>, List<EventModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<EventModel>>, List<EventModel>>,
              AsyncValue<List<EventModel>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
