// SPDX-FileCopyrightText: Copyright Logically Magic Inc. <hello@logicallymagic.com>
// SPDX-FileCopyrightText: Copyright Hamid Jahanzad <Hamid@Jahanzad.com>
// SPDX-FileCopyrightText: Copyright Contributors to the Exchange8:EExchange
// SPDX-License-Identifier: Apache-2.0

// BFF client wiring (trader/ops surfaces — DESIGN.md §2): Bff8ApiClient
// + scope map + SSE subscription surface + order/depth/tape caches the
// pages consume.
//
// All backend access routes through Sentin8:BFF /proxy/exchange8/... —
// no direct service calls (BFF pattern, DESIGN.md §1).

import 'dart:async';

import 'package:flutter/widgets.dart';

/// BFF transport errors surfaced to the UI.
class BffError implements Exception {
  final String message;
  BffError(this.message);
  @override
  String toString() => message;
}

/// One SSE event off /subscribe.
class BffEvent {
  final String channel;
  final Map<String, dynamic> data;
  BffEvent(this.channel, this.data);
}

/// Blotter row.
class OrderRow {
  final String clOrdId;
  final String status;
  final int qty;
  final int? limitRaw;
  final int tsUs;
  OrderRow(this.clOrdId, this.status, this.qty, this.limitRaw, this.tsUs);
}

/// The BFF client surface the pages use. The concrete HTTP/SSE transport
/// comes from `sdk/flutter/sentin8_flutter`'s Bff8ApiClient — this module
/// wraps it with exchange8's channels and caches.
class Bff8ApiClient {
  final Future<Map<String, dynamic>> Function(String method, String path, Map<String, dynamic>? body) _http;
  final Stream<BffEvent> Function(String channel) _sse;

  final Map<String, OrderRow> orderCache = {};
  final Map<String, _Book> _books = {};
  final Map<String, List<_Print>> _tapes = {};

  Bff8ApiClient(this._http, this._sse);

  Future<Map<String, dynamic>> get(String path) => _http('GET', path, null);
  Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? body}) =>
      _http('POST', path, body ?? {});

  Stream<BffEvent> subscribe(String channel) => _sse(channel);

  _Book depthCache(String symbol) => _books.putIfAbsent(symbol, _Book.new);
  List<_Print> tapeCache(String symbol) => _tapes.putIfAbsent(symbol, () => []);
}

class _Book {
  final List<_Level> asks = [];
  final List<_Level> bids = [];
  String get bboLabel =>
      '${bids.isEmpty ? '—' : bids.first.price} / ${asks.isEmpty ? '—' : asks.first.price}';
}

class _Level {
  final int price;
  final int qty;
  _Level(this.price, this.qty);
}

class _Print {
  final int tradeId;
  final int price;
  final int qty;
  _Print(this.tradeId, this.price, this.qty);
}

/// Inherited scope holder (the shell provides the authenticated client).
class BffClientScope extends InheritedWidget {
  final Bff8ApiClient client;
  const BffClientScope({super.key, required this.client, required super.child});

  static Bff8ApiClient of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<BffClientScope>()!.client;

  @override
  bool updateShouldNotify(BffClientScope old) => old.client != client;
}