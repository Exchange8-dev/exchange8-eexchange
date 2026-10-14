// SPDX-FileCopyrightText: Copyright Logically Magic Inc. <hello@logicallymagic.com>
// SPDX-FileCopyrightText: Copyright Hamid Jahanzad <Hamid@Jahanzad.com>
// SPDX-FileCopyrightText: Copyright Contributors to the Exchange8:EExchange
// SPDX-License-Identifier: Apache-2.0

// eExchange — Exchange8 trading app entry.
//
// BFF-only client (sentin8_flutter shell): every backend call routes
// through Bff8ApiClient → Sentin8:BFF /proxy/exchange8/...; no direct
// service access (BFF pattern — DESIGN.md §1).
//
// The trader/ops surfaces mount into this shell; the scope map and
// SSE subscription wiring live in bff/ (DESIGN.md §2).

import 'package:flutter/material.dart';

import 'shell/app_shell.dart';

void main() {
  runApp(const EExchangeApp());
}

class EExchangeApp extends StatelessWidget {
  const EExchangeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'eExchange',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD4AF37), // Royal Gold (design system)
        ),
        fontFamily: 'Inter',
      ),
      home: const AppShell(),
    );
  }
}