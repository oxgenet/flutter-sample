import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef ExitHandler = void Function();

void defaultAppExitHandler() {
  exit(0);
}

ExitHandler appExitHandler = defaultAppExitHandler;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'India History Explorer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7C2D12)),
        useMaterial3: true,
      ),
      home: const SignInPage(),
    );
  }
}

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _authenticate({required bool isSignUp}) {
    if (_passwordController.text.trim() != 'pass') {
      SystemNavigator.pop();
      Future<void>.delayed(const Duration(milliseconds: 200), () {
        appExitHandler();
      });
      return;
    }

    final fallbackName = isSignUp ? 'New Guest' : 'Guest';
    final username = _userController.text.trim().isEmpty
        ? fallbackName
        : _userController.text.trim();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => OverviewPage(username: username)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Mock Sign In / Sign Up',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                const Text('Sign in / Sign up only works when password is "pass".'),
                const SizedBox(height: 24),
                Semantics(
                  container: true,
                  textField: true,
                  identifier: 'username-input',
                  label: 'Username input',
                  child: TextField(
                    controller: _userController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Semantics(
                  container: true,
                  textField: true,
                  identifier: 'password-input',
                  label: 'Password input',
                  child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Semantics(
                  button: true,
                  container: true,
                  identifier: 'sign-in-button',
                  label: 'Sign in button',
                  child: FilledButton(
                    onPressed: () => _authenticate(isSignUp: false),
                    child: const Text('Sign in'),
                  ),
                ),
                const SizedBox(height: 12),
                Semantics(
                  button: true,
                  container: true,
                  identifier: 'sign-up-button',
                  label: 'Sign up button',
                  child: OutlinedButton(
                    onPressed: () => _authenticate(isSignUp: true),
                    child: const Text('Sign up'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key, required this.username});

  final String username;

  @override
  Widget build(BuildContext context) {
    final periods = historyPeriods.map((period) => period.name).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('ex3: Sign-in Check')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, $username',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Check the list of periods, then proceed to the India History Explorer.',
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: periods.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(periods[index]),
                    subtitle: Text(historyPeriods[index].years),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Semantics(
              button: true,
              container: true,
              identifier: 'go-to-history-explorer-button',
              label: 'India History Explorer button',
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(
                      builder: (_) => HistoryHomePage(username: username),
                    ),
                  );
                },
                child: const Text('Go to India History Explorer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HistoryHomePage extends StatefulWidget {
  const HistoryHomePage({super.key, required this.username});

  final String username;

  @override
  State<HistoryHomePage> createState() => _HistoryHomePageState();
}

class _HistoryHomePageState extends State<HistoryHomePage> {
  bool _ascending = true;
  String _selectedPeriodName = historyPeriods.first.name;

  List<HistoryPeriod> get _orderedPeriods {
    final items = List<HistoryPeriod>.from(historyPeriods);
    if (_ascending) {
      return items;
    }
    return items.reversed.toList();
  }

  HistoryPeriod get _selectedPeriod =>
      historyPeriods.firstWhere((period) => period.name == _selectedPeriodName);

  void _toggleSort() {
    setState(() {
      _ascending = !_ascending;
      final names = _orderedPeriods.map((period) => period.name).toList();
      if (!names.contains(_selectedPeriodName)) {
        _selectedPeriodName = names.first;
      }
    });
  }

  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const SignInPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final periods = _orderedPeriods;
    final selectedEntries = _selectedPeriod.entries;

    return Scaffold(
      appBar: AppBar(
        title: const Text('India History Explorer'),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Open account menu',
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem<String>(value: 'logout', child: Text('Log out')),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Signed in: ${widget.username}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Semantics(
              button: true,
              container: true,
              identifier: 'sort-periods-button',
              label: 'Sort button',
              child: InkWell(
                onTap: _toggleSort,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    _ascending ? 'Order: oldest first' : 'Order: newest first',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(12),
                            child: Text('Periods'),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: periods.length,
                              itemBuilder: (context, index) {
                                final period = periods[index];
                                final selected =
                                    period.name == _selectedPeriodName;
                                return ListTile(
                                  title: Text(period.name),
                                  subtitle: Text(period.years),
                                  selected: selected,
                                  onTap: () {
                                    setState(() {
                                      _selectedPeriodName = period.name;
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              'Key items of ${_selectedPeriod.name}',
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: selectedEntries.length,
                              itemBuilder: (context, index) {
                                final entry = selectedEntries[index];
                                return ListTile(
                                  title: Text(entry.title),
                                  subtitle: Text(entry.subtitle),
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) => DetailPage(
                                          periodName: _selectedPeriod.name,
                                          entry: entry,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  const DetailPage({super.key, required this.periodName, required this.entry});

  final String periodName;
  final HistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Semantics(
          button: true,
          container: true,
          identifier: 'history-explorer-back-button',
          label: 'Back button',
          child: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        title: const Text('Entry Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(periodName, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Text(entry.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              entry.subtitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Text(entry.description),
          ],
        ),
      ),
    );
  }
}

class HistoryPeriod {
  const HistoryPeriod({
    required this.name,
    required this.years,
    required this.entries,
  });

  final String name;
  final String years;
  final List<HistoryEntry> entries;
}

class HistoryEntry {
  const HistoryEntry({
    required this.title,
    required this.subtitle,
    required this.description,
  });

  final String title;
  final String subtitle;
  final String description;
}

const List<HistoryPeriod> historyPeriods = [
  HistoryPeriod(
    name: 'Indus Valley Civilization',
    years: '2600-1900 BCE',
    entries: [
      HistoryEntry(
        title: 'Mohenjo-daro',
        subtitle: 'Urban planning pioneer',
        description:
            'Mohenjo-daro was one of the largest cities of the Indus Valley Civilization, featuring advanced drainage systems and grid-layout streets.',
      ),
      HistoryEntry(
        title: 'Harappan Script',
        subtitle: 'Undeciphered writing system',
        description:
            'The Harappan script remains undeciphered and is one of the great unsolved mysteries in archaeology, found on thousands of seals and tablets.',
      ),
    ],
  ),
  HistoryPeriod(
    name: 'Vedic Period',
    years: '1500-500 BCE',
    entries: [
      HistoryEntry(
        title: 'Rigveda',
        subtitle: 'Ancient hymns and knowledge',
        description:
            'The Rigveda is one of the oldest known religious texts, containing hymns to various deities and forming the foundation of Vedic religion and philosophy.',
      ),
      HistoryEntry(
        title: 'Upanishads',
        subtitle: 'Philosophical inquiry',
        description:
            'The Upanishads represent the philosophical culmination of Vedic thought, exploring concepts such as Brahman, Atman, and the nature of consciousness.',
      ),
    ],
  ),
  HistoryPeriod(
    name: 'Maurya Empire',
    years: '322-185 BCE',
    entries: [
      HistoryEntry(
        title: 'Chandragupta Maurya',
        subtitle: 'Founder of the empire',
        description:
            'Chandragupta Maurya unified the subcontinent for the first time, establishing a centralized administration guided by the Arthashastra principles.',
      ),
      HistoryEntry(
        title: 'Ashoka the Great',
        subtitle: 'Buddhist spread and edicts',
        description:
            'After the Kalinga War, Ashoka embraced Buddhism and spread its teachings through rock and pillar edicts across the empire.',
      ),
    ],
  ),
  HistoryPeriod(
    name: 'Gupta Empire',
    years: '320-550 CE',
    entries: [
      HistoryEntry(
        title: 'Kalidasa',
        subtitle: 'Sanskrit literary genius',
        description:
            'Kalidasa is considered the greatest writer in the Sanskrit language, celebrated for works such as Abhijnanasakuntalam and Meghaduta.',
      ),
      HistoryEntry(
        title: 'Aryabhata',
        subtitle: 'Mathematical and astronomical advances',
        description:
            'Aryabhata introduced the concept of zero, calculated pi, and proposed that the Earth rotates on its axis, centuries ahead of his time.',
      ),
    ],
  ),
  HistoryPeriod(
    name: 'Delhi Sultanate',
    years: '1206-1526',
    entries: [
      HistoryEntry(
        title: 'Qutub Minar',
        subtitle: 'Symbol of Islamic architecture',
        description:
            'Built by Qutb ud-Din Aibak, the Qutub Minar is a UNESCO World Heritage Site and stands as a landmark of early Indo-Islamic architecture.',
      ),
      HistoryEntry(
        title: 'Alauddin Khalji',
        subtitle: 'Market reform and defense',
        description:
            'Alauddin Khalji implemented price-control reforms and successfully repelled multiple Mongol invasions, strengthening the sultanate.',
      ),
    ],
  ),
  HistoryPeriod(
    name: 'Mughal Empire',
    years: '1526-1857',
    entries: [
      HistoryEntry(
        title: 'Akbar the Great',
        subtitle: 'Religious tolerance and administration',
        description:
            'Akbar expanded the empire and promoted religious tolerance through his policy of Sulh-i-kul, building a multi-ethnic administrative structure.',
      ),
      HistoryEntry(
        title: 'Taj Mahal',
        subtitle: 'Monument to eternal love',
        description:
            'Commissioned by Shah Jahan in memory of Mumtaz Mahal, the Taj Mahal is a masterpiece of Mughal architecture and a UNESCO World Heritage Site.',
      ),
    ],
  ),
  HistoryPeriod(
    name: 'British India',
    years: '1858-1947',
    entries: [
      HistoryEntry(
        title: 'Mahatma Gandhi',
        subtitle: 'Non-violent independence movement',
        description:
            'Gandhi led the Indian independence movement through non-violent civil disobedience, inspiring movements for civil rights worldwide.',
      ),
      HistoryEntry(
        title: 'Indian Independence',
        subtitle: 'Partition and freedom',
        description:
            'On 15 August 1947, India gained independence from British rule, accompanied by the partition into India and Pakistan.',
      ),
    ],
  ),
];
