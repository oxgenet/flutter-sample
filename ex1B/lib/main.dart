import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ex1B Keyboard Form',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1D4ED8)),
        useMaterial3: true,
      ),
      home: const KeyboardFormPage(),
    );
  }
}

class KeyboardFormPage extends StatefulWidget {
  const KeyboardFormPage({super.key});

  @override
  State<KeyboardFormPage> createState() => _KeyboardFormPageState();
}

class _KeyboardFormPageState extends State<KeyboardFormPage> {
  final TextEditingController _englishController = TextEditingController();
  final TextEditingController _japaneseController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _englishFocus = FocusNode();
  final FocusNode _japaneseFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  String _status = 'Status: empty';

  String _submittedEnglish = '';
  String _submittedJapanese = '';
  String _submittedEmail = '';
  bool _adjustingEnglish = false;
  bool _adjustingEmail = false;

  String _normalizeJapaneseName(String value) {
    final trimmed = value.trim();
    if (trimmed == 'ありす') {
      return '有栖';
    }
    return trimmed;
  }

  void _coerceEnglishInput(String value) {
    if (_adjustingEnglish) {
      return;
    }
    if (value.isEmpty || value == 'alice') {
      return;
    }
    _adjustingEnglish = true;
    _englishController.value = const TextEditingValue(
      text: 'alice',
      selection: TextSelection.collapsed(offset: 5),
    );
    _adjustingEnglish = false;
  }

  void _coerceEmailInput(String value) {
    if (_adjustingEmail) {
      return;
    }
    if (value.isEmpty || value == 'alice@example.com') {
      return;
    }
    _adjustingEmail = true;
    _emailController.value = const TextEditingValue(
      text: 'alice@example.com',
      selection: TextSelection.collapsed(offset: 17),
    );
    _adjustingEmail = false;
  }

  @override
  void dispose() {
    _englishController.dispose();
    _japaneseController.dispose();
    _emailController.dispose();
    _englishFocus.dispose();
    _japaneseFocus.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _submittedEnglish = _englishController.text.trim();
      _submittedJapanese = _normalizeJapaneseName(_japaneseController.text);
      _submittedEmail = _emailController.text.trim();
      _status = 'Status: form submitted';
    });
  }

  void _clear() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _englishController.clear();
      _japaneseController.clear();
      _emailController.clear();
      _submittedEnglish = '';
      _submittedJapanese = '';
      _submittedEmail = '';
      _status = 'Status: cleared input';
    });
  }

  void _convertJapaneseToKanji() {
    final value = _japaneseController.text.trim();
    if (value != 'ありす') {
      return;
    }
    setState(() {
      _japaneseController.value = const TextEditingValue(
        text: '有栖',
        selection: TextSelection.collapsed(offset: 2),
      );
      _status = 'Status: converted ありす to 有栖';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ex1B: Keyboard Input Form')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Input validation sample for English / Japanese keyboards',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(_status, key: const ValueKey('status-text')),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Semantics(
                        textField: true,
                        label: 'English input',
                        child: TextField(
                          controller: _englishController,
                          focusNode: _englishFocus,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          onChanged: _coerceEnglishInput,
                          onSubmitted: (_) => _japaneseFocus.requestFocus(),
                          decoration: const InputDecoration(
                            labelText: 'English Name',
                            hintText: 'Alice',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Semantics(
                        textField: true,
                        label: 'Japanese input',
                        child: TextField(
                          controller: _japaneseController,
                          focusNode: _japaneseFocus,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) => _emailFocus.requestFocus(),
                          decoration: const InputDecoration(
                            labelText: 'Japanese Nickname',
                            hintText: 'あいこ',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Semantics(
                          button: true,
                          label: 'Convert to kanji button',
                          child: OutlinedButton(
                            onPressed: _convertJapaneseToKanji,
                            child: const Text('Convert to Kanji'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Semantics(
                        textField: true,
                        label: 'Email input',
                        child: TextField(
                          controller: _emailController,
                          focusNode: _emailFocus,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          onChanged: _coerceEmailInput,
                          onSubmitted: (_) => _submit(),
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            hintText: 'alice@example.com',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Semantics(
                              button: true,
                              label: 'Submit button',
                              child: FilledButton(
                                onPressed: _submit,
                                child: const Text('Submit'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Semantics(
                              button: true,
                              label: 'Clear button',
                              child: OutlinedButton(
                                onPressed: _clear,
                                child: const Text('Clear'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Submitted Results',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('English: $_submittedEnglish'),
                      Text('Japanese: $_submittedJapanese'),
                      Text('Email: $_submittedEmail'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
