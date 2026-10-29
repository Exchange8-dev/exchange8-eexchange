// SPDX-FileCopyrightText: Copyright Logically Magic Inc. <hello@logicallymagic.com>
// SPDX-FileCopyrightText: Copyright Hamid Jahanzad <Hamid@Jahanzad.com>
// SPDX-FileCopyrightText: Copyright Contributors to the Exchange8:EExchange
// SPDX-License-Identifier: Apache-2.0

// Depth ladder + BBO: SSE deltas from /subscribe/exchange8/md  - 
// snapshot join then incremental levels (md snapshot contract;
// DESIGN.md §4).

import 'package:flutter/material.dart';

import '../bff/bff_client.dart';

class DepthLadderPage extends StatelessWidget {
  const DepthLadderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bff = BffClientScope.of(context);
    return StreamBuilder<BffEvent>(
      stream: bff.subscribe('/subscribe/exchange8/md/EX8A'),
      builder: (context, snap) {
        final book = bff.depthCache('EX8A');
        final asks = book.asks.take(10).toList().reversed.toList();
        final bids = book.bids.take(10).toList();
        return Column(
          children: [
            _row('BBO', book.bboLabel, bold: true),
            const Divider(height: 1),
            ...asks.map((l) => _row('A', '${l.price} × ${l.qty}')),
            const Divider(height: 1),
            ...bids.map((l) => _row('B', '${l.price} × ${l.qty}')),
          ],
        );
      },
    );
  }

  Widget _row(String side, String text, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              child: Text(side,
                  style: TextStyle(
                      fontWeight: bold ? FontWeight.bold : FontWeight.w500,
                      color: side == 'B' ? Colors.green : Colors.red)),
            ),
            Expanded(child: Text(text, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal))),
          ],
        ),
      );
}