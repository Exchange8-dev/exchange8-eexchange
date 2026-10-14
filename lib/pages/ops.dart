// SPDX-FileCopyrightText: Copyright Logically Magic Inc. <hello@logicallymagic.com>
// SPDX-FileCopyrightText: Copyright Hamid Jahanzad <Hamid@Jahanzad.com>
// SPDX-FileCopyrightText: Copyright Contributors to the Exchange8:EExchange
// SPDX-License-Identifier: Apache-2.0

// Operations surfaces: halts, bust/amend, alerts. Step-up auth for
// bust is enforced server-side; admin scope gates halts (DESIGN.md §4).

import 'package:flutter/material.dart';

import '../bff/bff_client.dart';

class OpsPage extends StatelessWidget {
  const OpsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bff = BffClientScope.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _Card(
          title: 'Market control',
          child: Column(
            children: [
              OutlinedButton(
                onPressed: () => bff.post('/proxy/exchange8/v1/admin/instruments/EX8A/state', body: {'status': 'H'}),
                child: const Text('Halt EX8A'),
              ),
              OutlinedButton(
                onPressed: () => bff.post('/proxy/exchange8/v1/admin/instruments/EX8A/state', body: {'status': 'O'}),
                child: const Text('Resume EX8A'),
              ),
            ],
          ),
        ),
        _Card(
          title: 'Bust trade (step-up)',
          child: const BustForm(),
        ),
        _Card(
          title: 'Alerts',
          child: const AlertsList(),
        ),
      ],
    );
  }
}

class BustForm extends StatefulWidget {
  const BustForm({super.key});

  @override
  State<BustForm> createState() => _BustFormState();
}

class _BustFormState extends State<BustForm> {
  final _tradeId = TextEditingController();
  String? _result;

  Future<void> _bust(Bff8ApiClient bff) async {
    try {
      await bff.post('/proxy/exchange8/v1/trades/bust', body: {
        'trade_id': int.tryParse(_tradeId.text) ?? 0,
      });
      setState(() => _result = 'busted');
    } on BffError catch (e) {
      setState(() => _result = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bff = BffClientScope.of(context);
    return Row(
      children: [
        Expanded(child: TextField(controller: _tradeId, decoration: const InputDecoration(labelText: 'Trade ID'))),
        const SizedBox(width: 8),
        FilledButton(onPressed: () => _bust(bff), child: const Text('Bust')),
        if (_result != null) Padding(padding: const EdgeInsets.only(left: 8), child: Text(_result!)),
      ],
    );
  }
}

class AlertsList extends StatelessWidget {
  const AlertsList({super.key});

  @override
  Widget build(BuildContext context) {
    final bff = BffClientScope.of(context);
    return FutureBuilder(
      future: bff.get('/proxy/exchange8/v1/surveillance/cases'),
      builder: (context, snap) {
        final cases = (snap.data?['cases'] as List?) ?? [];
        return Column(
          children: [
            for (final c in cases)
              ListTile(dense: true, title: Text('${c['detector']}'), subtitle: Text('${c['severity']}')),
          ],
        );
      },
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final Widget child;
  const _Card({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text(title, style: Theme.of(context).textTheme.titleSmall), const SizedBox(height: 8), child],
        ),
      ),
    );
  }
}