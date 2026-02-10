import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../log_page/login_page.dart';
import 'add_student_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Box studentsBox;

  bool selectionMode = false;
  final Set<int> selectedIndexes = {};

  @override
  void initState() {
    super.initState();
    studentsBox = Hive.box('students');
  }

  int calculateAge(DateTime dob) {
    final today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age;
  }

  void _deleteSelected() {
    final sortedIndexes = selectedIndexes.toList()..sort((a, b) => b - a);
    for (final index in sortedIndexes) {
      studentsBox.deleteAt(index);
    }
    setState(() {
      selectedIndexes.clear();
      selectionMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🟣 APP BAR
      appBar: AppBar(
        title: Text(
          selectionMode ? "${selectedIndexes.length} selected" : "Student Data",
        ),
        centerTitle: true,

        // 🔥 THREE DOT MENU (TOP LEFT)
        leading: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            if (value == 'select') {
              setState(() {
                selectionMode = true;
                selectedIndexes.clear();
              });
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'select', child: Text("Select")),
          ],
        ),

        // ❌ EXIT SELECTION / LOGOUT
        actions: [
          if (selectionMode)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  selectionMode = false;
                  selectedIndexes.clear();
                });
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
            ),
        ],
      ),

      // ➕ ADD BUTTON (hidden in selection mode)
      floatingActionButton: selectionMode
          ? null
          : FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddStudentPage()),
                );
                if (result != null) {
                  studentsBox.add(result);
                }
              },
            ),

      // 🧹 REMOVE BUTTON (only when selecting)
      bottomNavigationBar: selectionMode
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(45),
                  ),
                  icon: const Icon(Icons.delete),
                  label: const Text("Remove Selected"),
                  onPressed: selectedIndexes.isEmpty ? null : _deleteSelected,
                ),
              ),
            )
          : null,

      // 📋 STUDENT LIST
      body: ValueListenableBuilder(
        valueListenable: studentsBox.listenable(),
        builder: (context, Box box, _) {
          if (box.isEmpty) {
            return const Center(child: Text("No students found"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: box.length,
            itemBuilder: (context, index) {
              final student = box.getAt(index);
              final isSelected = selectedIndexes.contains(index);

              return GestureDetector(
                onTap: () {
                  if (!selectionMode) return;

                  setState(() {
                    if (isSelected) {
                      selectedIndexes.remove(index);
                    } else {
                      selectedIndexes.add(index);
                    }
                  });
                },
                child: Card(
                  elevation: isSelected ? 8 : 4,
                  color: isSelected ? Colors.deepPurple.shade50 : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: isSelected
                        ? const BorderSide(color: Colors.deepPurple, width: 2)
                        : BorderSide.none,
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student['name'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text("Roll No : ${student['roll']}"),
                        Text(
                          student['dob'] == null
                              ? "Age : N/A"
                              : "Age : ${calculateAge(DateTime.parse(student['dob']))}",
                        ),
                        Text("Department : ${student['dept']}"),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
