// SPDX-FileCopyrightText: Copyright Logically Magic Inc. <hello@logicallymagic.com>
// SPDX-FileCopyrightText: Copyright Hamid Jahanzad <Hamid@Jahanzad.com>
// SPDX-FileCopyrightText: Copyright Contributors to the Exchange8:EExchange
// SPDX-License-Identifier: Apache-2.0

// Blotter: live order status via SSE /subscribe (market-data deltas +
// gateway order events). Lists cl_ord_id, status, qty, filled
// (DESIGN.md §4 consumption contract).

import 'package:flutter/material.dart';

import '../bff/bff_client.dart';

class BlotterPage extends StatelessWidget {
  const BlotterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bff = BffClientScope.of(context);
    return StreamBuilder<BffEvent>(
      stream: bff.subscribe('/subscribe/exchange8/orders'),
      builder: (context, snap) {
        final orders = bff.orderCache.values.toList()
          ..sort((a, b) => b.tsUs.compareTo(a.tsUs));
        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, i) {
            final o = orders[i];
            return ListTile(
              dense: true,
              leading: Text(o.clOrdId),
              title: Text('${o.qty} @ ${o.limitRaw ?? 'MKT'}'),
              trailing: Text(o.status),
            );
          },
        );
      },
    );
  }
}