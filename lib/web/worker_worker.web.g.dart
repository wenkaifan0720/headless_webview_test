// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// Generator: WorkerGenerator 6.1.5
// **************************************************************************

import 'package:squadron/squadron.dart';

import 'worker_worker.dart';

void main() {
  /// Web entry point for WorkerWorker
  run($WorkerWorkerInitializer);
}

EntryPoint $getWorkerWorkerActivator(SquadronPlatformType platform) {
  if (platform.isJs) {
    return Squadron.uri('~/workers/worker_worker.web.g.dart.js');
  } else if (platform.isWasm) {
    return Squadron.uri('~/workers/worker_worker.web.g.dart.wasm');
  } else {
    throw UnsupportedError('${platform.label} not supported.');
  }
}
