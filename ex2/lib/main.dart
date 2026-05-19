import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ex2 Controls',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F766E)),
        useMaterial3: true,
      ),
      home: const ControlsPage(),
    );
  }
}

enum LearningMode { read, review, quiz }

class ControlsPage extends StatefulWidget {
  const ControlsPage({super.key});

  @override
  State<ControlsPage> createState() => _ControlsPageState();
}

class _ControlsPageState extends State<ControlsPage> {
  final TextEditingController _nameController = TextEditingController();
  String _level = 'Beginner';
  LearningMode _mode = LearningMode.read;
  bool _policyAccepted = false;
  bool _remindersEnabled = false;
  bool _timelineFocus = false;
  double _confidence = 40;
  String _status = 'Applied status: waiting';
  String _summary =
      'Summary: Visitor | Beginner | Read | reminders off | policy pending | confidence 40 | timeline off';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _changeConfidence(double delta) {
    setState(() {
      _confidence = (_confidence + delta).clamp(0, 100);
    });
  }

  void _applySettings() {
    final displayName = _nameController.text.trim().isEmpty
        ? 'Visitor'
        : _nameController.text.trim();

    setState(() {
      _status =
          'Applied status: $displayName | $_level | ${_mode.label} | ${_confidence.round()}';
      _summary =
          'Summary: $displayName | $_level | ${_mode.label} | reminders ${_remindersEnabled ? 'on' : 'off'} | '
          'policy ${_policyAccepted ? 'accepted' : 'pending'} | confidence ${_confidence.round()} | '
          'timeline ${_timelineFocus ? 'on' : 'off'}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ex2: Controls Lab')),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Representative Flutter controls with Maestro-friendly semantics.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Profile'),
                    const SizedBox(height: 12),
                    Semantics(
                      container: true,
                      textField: true,
                      identifier: 'name-input',
                      label: 'Name input',
                      child: TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Learner name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Semantics(
                      container: true,
                      identifier: 'level-dropdown',
                      label: 'Level dropdown',
                      child: DropdownButtonFormField<String>(
                        initialValue: _level,
                        decoration: const InputDecoration(
                          labelText: 'Difficulty level',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Beginner',
                            child: Text('Beginner'),
                          ),
                          DropdownMenuItem(
                            value: 'Intermediate',
                            child: Text('Intermediate'),
                          ),
                          DropdownMenuItem(
                            value: 'Advanced',
                            child: Text('Advanced'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setState(() {
                            _level = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Learning mode'),
                    const SizedBox(height: 12),
                    SegmentedButton<LearningMode>(
                      showSelectedIcon: false,
                      segments: LearningMode.values
                          .map(
                            (mode) => ButtonSegment<LearningMode>(
                              value: mode,
                              label: Text(mode.label),
                            ),
                          )
                          .toList(),
                      selected: {_mode},
                      onSelectionChanged: (selection) {
                        setState(() {
                          _mode = selection.first;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Semantics(
                      button: true,
                      container: true,
                      identifier: 'agree-policy-checkbox',
                      label: 'Agree to policy checkbox',
                      child: CheckboxListTile(
                        value: _policyAccepted,
                        onChanged: (value) {
                          setState(() {
                            _policyAccepted = value ?? false;
                          });
                        },
                        title: const Text('Agree to policy'),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    Semantics(
                      button: true,
                      container: true,
                      identifier: 'enable-reminders-switch',
                      label: 'Enable reminders switch',
                      child: SwitchListTile(
                        value: _remindersEnabled,
                        onChanged: (value) {
                          setState(() {
                            _remindersEnabled = value;
                          });
                        },
                        title: const Text('Enable reminders'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Confidence: ${_confidence.round()}'),
                    Semantics(
                      container: true,
                      identifier: 'confidence-slider',
                      label: 'Confidence slider',
                      child: Slider(
                        value: _confidence,
                        min: 0,
                        max: 100,
                        divisions: 10,
                        label: _confidence.round().toString(),
                        onChanged: (value) {
                          setState(() {
                            _confidence = value;
                          });
                        },
                      ),
                    ),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Semantics(
                          button: true,
                          container: true,
                          identifier: 'decrease-confidence-button',
                          label: 'Decrease confidence button',
                          child: OutlinedButton(
                            onPressed: () => _changeConfidence(-10),
                            child: const Text('Decrease confidence'),
                          ),
                        ),
                        Semantics(
                          button: true,
                          container: true,
                          identifier: 'increase-confidence-button',
                          label: 'Increase confidence button',
                          child: OutlinedButton(
                            onPressed: () => _changeConfidence(10),
                            child: const Text('Increase confidence'),
                          ),
                        ),
                        Semantics(
                          button: true,
                          container: true,
                          identifier: 'timeline-focus-chip',
                          label: 'Timeline focus chip',
                          child: FilterChip(
                            label: const Text('Timeline focus'),
                            selected: _timelineFocus,
                            onSelected: (value) {
                              setState(() {
                                _timelineFocus = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Semantics(
              button: true,
              container: true,
              identifier: 'apply-settings-button',
              label: 'Apply settings button',
              child: FilledButton(
                onPressed: _applySettings,
                child: const Text('Apply settings'),
              ),
            ),
            const SizedBox(height: 16),
            Text(_status, key: const ValueKey('status-text')),
            const SizedBox(height: 16),
            Card(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(_summary, key: const ValueKey('summary-text')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension on LearningMode {
  String get label {
    switch (this) {
      case LearningMode.read:
        return 'Read';
      case LearningMode.review:
        return 'Review';
      case LearningMode.quiz:
        return 'Quiz';
    }
  }
}
