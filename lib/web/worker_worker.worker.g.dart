// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'worker_worker.dart';

// **************************************************************************
// Generator: WorkerGenerator 6.1.5
// **************************************************************************

/// WorkerService class for WorkerWorker
base class _$WorkerWorkerWorkerService extends WorkerWorker
    implements WorkerService {
  _$WorkerWorkerWorkerService() : super();

  @override
  late final Map<int, CommandHandler> operations =
      Map.unmodifiable(<int, CommandHandler>{
    _$calculateSumId: ($) =>
        calculateSum(_$X.$impl.$dsr0($.args[0]), _$X.$impl.$dsr0($.args[1])),
    _$getDataAsyncId: ($) => getDataAsync(_$X.$impl.$dsr0($.args[0])),
    _$sayHelloId: ($) => sayHello(),
  });

  static const int _$calculateSumId = 1;
  static const int _$getDataAsyncId = 2;
  static const int _$sayHelloId = 3;
}

/// Service initializer for WorkerWorker
WorkerService $WorkerWorkerInitializer(WorkerRequest $$) =>
    _$WorkerWorkerWorkerService();

/// Worker for WorkerWorker
base class WorkerWorkerWorker extends Worker implements WorkerWorker {
  WorkerWorkerWorker(
      {PlatformThreadHook? threadHook, ExceptionManager? exceptionManager})
      : super($WorkerWorkerActivator(Squadron.platformType));

  WorkerWorkerWorker.js(
      {PlatformThreadHook? threadHook, ExceptionManager? exceptionManager})
      : super($WorkerWorkerActivator(SquadronPlatformType.js),
            threadHook: threadHook, exceptionManager: exceptionManager);

  WorkerWorkerWorker.wasm(
      {PlatformThreadHook? threadHook, ExceptionManager? exceptionManager})
      : super($WorkerWorkerActivator(SquadronPlatformType.wasm));

  @override
  Future<int> calculateSum(int a, int b) =>
      send(_$WorkerWorkerWorkerService._$calculateSumId, args: [a, b])
          .then(_$X.$impl.$dsr0);

  @override
  Future<String> getDataAsync(int id) =>
      send(_$WorkerWorkerWorkerService._$getDataAsyncId, args: [id])
          .then(_$X.$impl.$dsr1);

  @override
  Future<String> sayHello() =>
      send(_$WorkerWorkerWorkerService._$sayHelloId).then(_$X.$impl.$dsr1);

  @override
  void _ensureInitialized() => throw UnimplementedError();

  @override
  // ignore: unused_element
  bool get _initialized => throw UnimplementedError();

  @override
  // ignore: unused_element
  set _initialized(void value) => throw UnimplementedError();
}

/// Worker pool for WorkerWorker
base class WorkerWorkerWorkerPool extends WorkerPool<WorkerWorkerWorker>
    implements WorkerWorker {
  WorkerWorkerWorkerPool(
      {ConcurrencySettings? concurrencySettings,
      PlatformThreadHook? threadHook,
      ExceptionManager? exceptionManager})
      : super(
          (ExceptionManager exceptionManager) => WorkerWorkerWorker(
              threadHook: threadHook, exceptionManager: exceptionManager),
          concurrencySettings: concurrencySettings,
        );

  WorkerWorkerWorkerPool.js(
      {ConcurrencySettings? concurrencySettings,
      PlatformThreadHook? threadHook,
      ExceptionManager? exceptionManager})
      : super(
          (ExceptionManager exceptionManager) => WorkerWorkerWorker.js(
              threadHook: threadHook, exceptionManager: exceptionManager),
          concurrencySettings: concurrencySettings,
        );

  WorkerWorkerWorkerPool.wasm(
      {ConcurrencySettings? concurrencySettings,
      PlatformThreadHook? threadHook,
      ExceptionManager? exceptionManager})
      : super(
          (ExceptionManager exceptionManager) => WorkerWorkerWorker.wasm(
              threadHook: threadHook, exceptionManager: exceptionManager),
          concurrencySettings: concurrencySettings,
        );

  @override
  Future<int> calculateSum(int a, int b) =>
      execute((w) => w.calculateSum(a, b));

  @override
  Future<String> getDataAsync(int id) => execute((w) => w.getDataAsync(id));

  @override
  Future<String> sayHello() => execute((w) => w.sayHello());

  @override
  void _ensureInitialized() => throw UnimplementedError();

  @override
  // ignore: unused_element
  bool get _initialized => throw UnimplementedError();

  @override
  // ignore: unused_element
  set _initialized(void value) => throw UnimplementedError();
}

final class _$X {
  _$X._();

  static _$X? _impl;

  static _$X get $impl {
    if (_impl == null) {
      Squadron.onConverterChanged(() => _impl = _$X._());
      _impl = _$X._();
    }
    return _impl!;
  }

  late final $dsr0 = Squadron.converter.value<int>();
  late final $dsr1 = Squadron.converter.value<String>();
}
