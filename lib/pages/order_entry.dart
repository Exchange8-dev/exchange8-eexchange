// SPDX-FileCopyrightText: Copyright Logically Magic Inc. <hello@logicallymagic.com>
// SPDX-FileCopyrightText: Copyright Hamid Jahanzad <Hamid@Jahanzad.com>
// SPDX-FileCopyrightText: Copyright Contributors to the Exchange8:EExchange
// SPDX-License-Identifier: Apache-2.0

// Order entry ticket: symbol, side, qty, limit, TIF →
// POST /proxy/exchange8/v1/orders via Bff8ApiClient. Scope:
// exchange8:gateway:orders:write. Idempotent on cl_ord_id (DESIGN.md §4).

import 'package:flutter/material.dart';

import '../bff/bff_client.dart';

class OrderEntryPage extends StatefulWidget {
  const OrderEntryPage({super.key});

  @override
  State<OrderEntryPage> createState() => _OrderEntryPageState();
}

class _OrderEntryPageState extends State<OrderEntryPage> {
  final _symbol = TextEditingController(text: 'EX8A');
  final _qty = TextEditingController(text: '100');
  final _limit = TextEditingController(text: '');
  bool _bid = true;
  String _tif = '0'; // day
  String? _error;

  Future<void> _submit(Bff8ApiClient bff) async {
    setState(() => _error = null);
    try {
      await bff.post('/proxy/exchange8/v1/orders', body: {
        'cl_ord_id': DateTime.now().millisecondsSinceEpoch.toString(),
        'symbol': _symbol.text,
        'side': _bid ? 'B' : 'S',
        'qty': int.tryParse(_qty.text) ?? 0,
        if (_limit.text.isNotEmpty) 'limit_raw': int.tryParse(_limit.text),
        'tif': _tif,
      });
    } on BffError catch (e) {
      setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bff = BffClientScope.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(controller: _symbol, decoration: const InputDecoration(labelText: 'Symbol')),
        const SizedBox(height: 8),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: true, label: Text('Buy')),
            ButtonSegment(value: false, label: Text('Sell')),
          ],
          selected: {_bid},
          onSelectionChanged: (s) => setState(() => _bid = s.first),
        ),
        const SizedBox(height: 8),
        TextField(controller: _qty, decoration: const InputDecoration(labelText: 'Quantity')),
        const SizedBox(height: 8),
        TextField(controller: _limit, decoration: const InputDecoration(labelText: 'Limit (blank = market*)')),
        const SizedBox(height: 8),
        DropdownButton<String>(
          value: _tif,
          items: const [
            DropdownMenuItem(value: '0', child: Text('Day')),
            DropdownMenuItem(value: '3', child: Text('IOC')),
            DropdownMenuItem(value: '4', child: Text('FOK')),
          ],
          onChanged: (v) => setState(() => _tif = v!),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(_error!, style: const TextStyle(color: Colors.red)),
          ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => _submit(bff),
          icon: const Icon(Icons.send),
          label: const Text('Submit'),
        ),
      ],
    );
  }
}