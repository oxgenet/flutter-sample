import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ex2A List Lab',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F766E)),
        useMaterial3: true,
      ),
      home: const ListLabPage(),
    );
  }
}

enum ItemSort { updatedDesc, priorityDesc, titleAsc }

class Board {
  Board({
    required this.id,
    required this.name,
    required this.summary,
    required this.items,
  });

  final String id;
  final String name;
  final String summary;
  final List<BoardItem> items;
}

class BoardItem {
  BoardItem({
    required this.id,
    required this.title,
    required this.note,
    required this.priority,
    required this.updatedAt,
    this.done = false,
  });

  final String id;
  String title;
  String note;
  int priority;
  DateTime updatedAt;
  bool done;

  BoardItem copy() {
    return BoardItem(
      id: id,
      title: title,
      note: note,
      priority: priority,
      updatedAt: updatedAt,
      done: done,
    );
  }
}

class ListLabPage extends StatefulWidget {
  const ListLabPage({super.key});

  @override
  State<ListLabPage> createState() => _ListLabPageState();
}

class _ListLabPageState extends State<ListLabPage> {
  final TextEditingController _itemSearchController = TextEditingController();
  late final List<Board> _boards;
  String _selectedBoardId = 'gupta';
  bool _showDoneItems = true;
  bool _onlyHighPriority = false;
  ItemSort _itemSort = ItemSort.updatedDesc;
  String _status = 'Status: initialized';

  @override
  void initState() {
    super.initState();
    _boards = _seedBoards();
  }

  @override
  void dispose() {
    _itemSearchController.dispose();
    super.dispose();
  }

  Board get _selectedBoard =>
      _boards.firstWhere((board) => board.id == _selectedBoardId);

  List<BoardItem> get _filteredItems {
    final search = _itemSearchController.text.trim().toLowerCase();
    final items = _selectedBoard.items.where((item) {
      if (!_showDoneItems && item.done) {
        return false;
      }
      if (_onlyHighPriority && item.priority < 4) {
        return false;
      }
      if (search.isEmpty) {
        return true;
      }
      return item.title.toLowerCase().contains(search) ||
          item.note.toLowerCase().contains(search);
    }).toList();

    switch (_itemSort) {
      case ItemSort.updatedDesc:
        items.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      case ItemSort.priorityDesc:
        items.sort((a, b) => b.priority.compareTo(a.priority));
      case ItemSort.titleAsc:
        items.sort((a, b) => a.title.compareTo(b.title));
    }

    return items;
  }

  String _sortLabel(ItemSort sort) {
    switch (sort) {
      case ItemSort.updatedDesc:
        return 'updated';
      case ItemSort.priorityDesc:
        return 'priority';
      case ItemSort.titleAsc:
        return 'title';
    }
  }

  int _openCount(Board board) {
    return board.items.where((item) => !item.done).length;
  }

  Future<void> _openEditorPanel(BoardItem item) async {
    final edited = await showModalBottomSheet<BoardItem>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _BoardItemEditor(item: item.copy()),
    );
    if (edited == null) {
      return;
    }

    setState(() {
      item.title = edited.title;
      item.note = edited.note;
      item.priority = edited.priority;
      item.done = edited.done;
      item.updatedAt = DateTime.now();
      _status = 'Status: updated ${item.title}';
    });
  }

  void _toggleDone(BoardItem item, bool? value) {
    setState(() {
      item.done = value ?? false;
      item.updatedAt = DateTime.now();
      _status =
          'Status: ${item.title} marked ${item.done ? 'done' : 'open'}';
    });
  }

  void _removeItem(BoardItem item) {
    final board = _selectedBoard;
    final index = board.items.indexWhere((x) => x.id == item.id);
    if (index < 0) {
      return;
    }

    setState(() {
      board.items.removeAt(index);
      _status = 'Status: deleted ${item.title}';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted ${item.title}'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              board.items.insert(index, item);
              _status = 'Status: restored ${item.title}';
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredItems;

    return Scaffold(
      appBar: AppBar(title: const Text('ex2A: Dual List Lab')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(_status, key: const ValueKey('status-text')),
            const SizedBox(height: 8),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                            child: Row(
                              children: [
                                const Text('Upper list: Board'),
                                const Spacer(),
                                Semantics(
                                  button: true,
                                  label: 'High priority filter',
                                  child: FilterChip(
                                    label: const Text('High priority only'),
                                    selected: _onlyHighPriority,
                                    onSelected: (value) {
                                      setState(() {
                                        _onlyHighPriority = value;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1),
                          Expanded(
                            child: ListView.builder(
                              itemCount: _boards.length,
                              itemBuilder: (context, index) {
                                final board = _boards[index];
                                final selected = board.id == _selectedBoardId;
                                return Semantics(
                                  button: true,
                                  label: 'board:${board.name}',
                                  child: ListTile(
                                    key: ValueKey('board-tile-${board.id}'),
                                    selected: selected,
                                    title: Text(
                                      '${board.name} (${_openCount(board)})',
                                    ),
                                    subtitle: Text(board.summary),
                                    onTap: () {
                                      setState(() {
                                        _selectedBoardId = board.id;
                                        _status =
                                            'Status: selected ${board.name}';
                                      });
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text('Lower list: ${_selectedBoard.name}'),
                                SegmentedButton<ItemSort>(
                                  segments: const [
                                    ButtonSegment<ItemSort>(
                                      value: ItemSort.updatedDesc,
                                      label: Text('Updated'),
                                    ),
                                    ButtonSegment<ItemSort>(
                                      value: ItemSort.priorityDesc,
                                      label: Text('Priority'),
                                    ),
                                    ButtonSegment<ItemSort>(
                                      value: ItemSort.titleAsc,
                                      label: Text('Title'),
                                    ),
                                  ],
                                  selected: {_itemSort},
                                  showSelectedIcon: false,
                                  onSelectionChanged: (selection) {
                                    setState(() {
                                      _itemSort = selection.first;
                                      _status =
                                          'Status: sorted lower list by ${_sortLabel(_itemSort)}';
                                    });
                                  },
                                ),
                                Semantics(
                                  button: true,
                                  label: 'Show done filter',
                                  child: FilterChip(
                                    label: const Text('Show done'),
                                    selected: _showDoneItems,
                                    onSelected: (value) {
                                      setState(() {
                                        _showDoneItems = value;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                            child: Semantics(
                              textField: true,
                              label: 'Item search input',
                              child: TextField(
                                controller: _itemSearchController,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  labelText: 'Search items',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (_) {
                                  setState(() {});
                                },
                              ),
                            ),
                          ),
                          const Divider(height: 1),
                          Expanded(
                            child: ListView.builder(
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                final item = items[index];
                                return Semantics(
                                  button: true,
                                  label: 'item:${item.title}',
                                  child: ListTile(
                                    title: Text(item.title),
                                    subtitle: Text(
                                      'priority:${item.priority} | ${item.note}',
                                    ),
                                    leading: Semantics(
                                      button: true,
                                      label: 'toggle done ${item.title}',
                                      child: Checkbox(
                                        value: item.done,
                                        onChanged: (value) =>
                                            _toggleDone(item, value),
                                      ),
                                    ),
                                    trailing: IconButton(
                                      tooltip: 'delete ${item.title}',
                                      onPressed: () => _removeItem(item),
                                      icon: const Icon(Icons.delete_outline),
                                    ),
                                    onTap: () => _openEditorPanel(item),
                                  ),
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

  List<Board> _seedBoards() {
    return [
      Board(
        id: 'maurya',
        name: 'Maurya Empire Board',
        summary: 'Imperial unification and Buddhist expansion',
        items: [
          BoardItem(
            id: 'maurya-1',
            title: "Ashoka's Edicts note",
            note: 'Check primary sources',
            priority: 4,
            updatedAt: DateTime(2026, 4, 8),
          ),
          BoardItem(
            id: 'maurya-2',
            title: 'Arthashastra summary',
            note: 'Review original text',
            priority: 5,
            updatedAt: DateTime(2026, 4, 9),
          ),
        ],
      ),
      Board(
        id: 'gupta',
        name: 'Gupta Empire Board',
        summary: 'Classical arts and science',
        items: [
          BoardItem(
            id: 'gupta-1',
            title: 'Kalidasa works draft',
            note: 'Compare Act I',
            priority: 5,
            updatedAt: DateTime(2026, 4, 10, 10, 30),
          ),
          BoardItem(
            id: 'gupta-2',
            title: 'Gupta dynasty timeline',
            note: 'Chandra lineage',
            priority: 4,
            updatedAt: DateTime(2026, 4, 9, 9, 10),
          ),
          BoardItem(
            id: 'gupta-3',
            title: 'Iron Pillar sketch',
            note: 'Replace diagram',
            priority: 2,
            updatedAt: DateTime(2026, 4, 8, 18, 20),
            done: true,
          ),
        ],
      ),
      Board(
        id: 'mughal',
        name: 'Mughal Empire Board',
        summary: 'Administrative systems and social change',
        items: [
          BoardItem(
            id: 'mughal-1',
            title: "Akbar's Sulh-i-kul cost estimate",
            note: 'Convert to modern context',
            priority: 3,
            updatedAt: DateTime(2026, 4, 7, 15, 0),
          ),
          BoardItem(
            id: 'mughal-2',
            title: 'Grand Trunk Road map',
            note: 'Verify waypoints',
            priority: 4,
            updatedAt: DateTime(2026, 4, 10, 8, 0),
          ),
        ],
      ),
    ];
  }
}

class _BoardItemEditor extends StatefulWidget {
  const _BoardItemEditor({required this.item});

  final BoardItem item;

  @override
  State<_BoardItemEditor> createState() => _BoardItemEditorState();
}

class _BoardItemEditorState extends State<_BoardItemEditor> {
  late final TextEditingController _titleController;
  late final TextEditingController _noteController;
  late int _priority;
  late bool _done;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item.title);
    _noteController = TextEditingController(text: widget.item.note);
    _priority = widget.item.priority;
    _done = widget.item.done;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Item editor panel',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: 'Note',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            initialValue: _priority,
            decoration: const InputDecoration(
              labelText: 'Priority',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 1, child: Text('1')),
              DropdownMenuItem(value: 2, child: Text('2')),
              DropdownMenuItem(value: 3, child: Text('3')),
              DropdownMenuItem(value: 4, child: Text('4')),
              DropdownMenuItem(value: 5, child: Text('5')),
            ],
            onChanged: (value) {
              if (value == null) {
                return;
              }
              setState(() {
                _priority = value;
              });
            },
          ),
          CheckboxListTile(
            value: _done,
            onChanged: (value) {
              setState(() {
                _done = value ?? false;
              });
            },
            contentPadding: EdgeInsets.zero,
            title: const Text('Mark done'),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    final edited = widget.item.copy()
                      ..title = _titleController.text.trim().isEmpty
                          ? widget.item.title
                          : _titleController.text.trim()
                      ..note = _noteController.text.trim()
                      ..priority = _priority
                      ..done = _done;
                    Navigator.of(context).pop(edited);
                  },
                  child: const Text('Save and close'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
