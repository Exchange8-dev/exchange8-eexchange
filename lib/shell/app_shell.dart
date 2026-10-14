// SPDX-FileCopyrightText: Copyright Logically Magic Inc. <hello@logicallymagic.com>
// SPDX-FileCopyrightText: Copyright Hamid Jahanzad <Hamid@Jahanzad.com>
// SPDX-FileCopyrightText: Copyright Contributors to the Exchange8:EExchange
// SPDX-License-Identifier: Apache-2.0

// App shell — navigation across the trader/ops surfaces (blotter,
// ticket, depth, tape, ops — DESIGN.md §2). The BFF client scope wraps
// the tree.

import 'package:flutter/material.dart';

import '../bff/bff_client.dart';
import '../pages/blotter.dart';
import '../pages/depth_ladder.dart';
import '../pages/ops.dart';
import '../pages/order_entry.dart';
import '../pages/tape.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    // The sentin8_flutter bootstrap injects the authenticated transport;
    // the scaffold wires it into the scope for the pages.
    final bff = Bff8ApiClient(
      (method, path, body) async => throw BffError('transport bootstrap pending (DESIGN.md §10)'),
      (channel) => const Stream.empty(),
    );
    return BffClientScope(
      client: bff,
      child: Scaffold(
        appBar: AppBar(title: const Text('eExchange')),
        body: IndexedStack(
          index: _tab,
          children: const [
            BlotterPage(),
            OrderEntryPage(),
            DepthLadderPage(),
            TapePage(),
            OpsPage(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: (i) => setState(() => _tab = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.list), label: 'Blotter'),
            NavigationDestination(icon: Icon(Icons.send), label: 'Ticket'),
            NavigationDestination(icon: Icon(Icons.stacked_bar_chart), label: 'Depth'),
            NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Tape'),
            NavigationDestination(icon: Icon(Icons.admin_panel_settings), label: 'Ops'),
          ],
        ),
      ),
    );
  }
}