// SPDX-FileCopyrightText: Copyright Logically Magic Inc. <hello@logicallymagic.com>
// SPDX-FileCopyrightText: Copyright Hamid Jahanzad <Hamid@Jahanzad.com>
// SPDX-FileCopyrightText: Copyright Contributors to the Exchange8:EExchange
// SPDX-License-Identifier: Apache-2.0

// Trade tape: SSE trade prints from /subscribe/exchange8/md
// (DESIGN.md §4).

import 'package:flutter/material.dart';

import '../bff/bff_client.dart';

class TapePage extends StatelessWidget {
  const TapePage({super.key});

  @override
  Widget build(BuildContext context) {
    final bff = BffClientScope.of(context);
    return StreamBuilder<BffEvent>(
      stream: bff.subscribe('/subscribe/exchange8/md/EX8A'),
      builder: (context, snap) {
        final prints = bff.tapeCache('EX8A').take(50).toList();
        return ListView.builder(
          itemCount: prints.length,
          itemBuilder: (context, i) {
            final t = prints[i];
            return ListTile(
              dense: true,
              title: Text('${t.price} × ${t.qty}'),
              trailing: Text('#${t.tradeId}'),
            );
          },
        );
      },
    );
  }
}