import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:sqlitedb_demo/database/todo_db.dart';

import '../model/todoModel.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  Future<List<Todo>>? futureTodos;
  final todoDB = TodoDB();

  @override
  void initState() {
    fetchTodos();
    super.initState();
  }

  void fetchTodos() {
    setState(() {
      futureTodos = todoDB.fetchAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text('TodoList'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (_) => CreateWidget(onsubmit: (title) async {
                      await todoDB.create(title: title);
                      if (!mounted) return;
                      fetchTodos();
                      Navigator.pop(context);
                    }));
          },
          child: const Icon(Icons.add),
        ),
        body: FutureBuilder<List<Todo>>(
            future: futureTodos,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                final todos = snapshot.data;
                if (todos != null) {
                  return todos.isEmpty
                      ? const Center(
                          child: Text('No todos'),
                        )
                      : ListView.builder(
                          itemCount: todos.length,
                          itemBuilder: (context, index) {
                            final todo = todos[index];
                            final subtitle = DateFormat('yyyy/MM/dd').format(
                                DateTime.parse(
                                    todo.updatedAt ?? todo.createdAt));
                            return ListTile(
                              leading: IconButton(
                                  onPressed: () async {
                                    showDialog(
                                        context: context,
                                        builder: (_) => CreateWidget(
                                            todo: todo,
                                            onsubmit: (title) async {
                                              await todoDB.update(
                                                  id: todo.id, title: title);
                                              if (!mounted) return;
                                              fetchTodos();
                                              Navigator.pop(context);
                                            }));
                                  },
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    color: Colors.green,
                                  )),
                              title: Text(todo.title),
                              subtitle: Text(subtitle),
                              trailing: IconButton(
                                  onPressed: () async {
                                    await todoDB.delete(todo.id);
                                    fetchTodos();
                                  },
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  )),
                            );
                          },
                        );
                } else {
                  return const Center(child: Text("todo has no data"));
                }
              }
            }));
  }
}

class CreateWidget extends StatefulWidget {
  final Todo? todo;
  final ValueChanged<String> onsubmit;
  const CreateWidget({super.key, this.todo, required this.onsubmit});

  @override
  State<CreateWidget> createState() => _CreateWidgetState();
}

class _CreateWidgetState extends State<CreateWidget> {
  final controller = TextEditingController();
  final formkey = GlobalKey<FormState>();
  @override
  void initState() {
    controller.text = widget.todo?.title ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.todo != null;
    return AlertDialog(
      title: Text(isEditing ? 'Edit todo' : 'Add todo'),
      content: Form(
        key: formkey,
        child: TextFormField(
            autofocus: true,
            controller: controller,
            decoration: const InputDecoration(hintText: 'Title'),
            validator: (value) =>
                value != null && value.isEmpty ? 'Title is required' : null),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        TextButton(
            onPressed: () {
              if (formkey.currentState!.validate()) {
                widget.onsubmit(controller.text);
              }
            },
            child: const Text('OK')),
      ],
    );
  }
}
