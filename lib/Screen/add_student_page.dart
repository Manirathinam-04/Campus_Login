import 'package:flutter/material.dart';

class AddStudentPage extends StatefulWidget {
  final Map<String, String>? student;

  const AddStudentPage({super.key, this.student});

  @override
  State<AddStudentPage> createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  final _formKey = GlobalKey<FormState>();

  final nameCtrl = TextEditingController();
  final rollCtrl = TextEditingController();
  final deptCtrl = TextEditingController();

  DateTime? selectedDob;

  @override
  void initState() {
    super.initState();

    // If editing existing student
    if (widget.student != null) {
      nameCtrl.text = widget.student!['name'] ?? '';
      rollCtrl.text = widget.student!['roll'] ?? '';
      deptCtrl.text = widget.student!['dept'] ?? '';

      // restore DOB if exists
      if (widget.student!['dob'] != null) {
        selectedDob = DateTime.parse(widget.student!['dob']!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.student == null ? "Add Student" : "Edit Student"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // NAME
              TextFormField(
                controller: nameCtrl,
                validator: (v) => v == null || v.isEmpty ? "Enter name" : null,
                decoration: const InputDecoration(labelText: "Name"),
              ),

              const SizedBox(height: 10),

              // ROLL
              TextFormField(
                controller: rollCtrl,
                validator: (v) =>
                    v == null || v.isEmpty ? "Enter roll number" : null,
                decoration: const InputDecoration(labelText: "Roll No"),
              ),

              const SizedBox(height: 10),

              // DEPARTMENT
              TextFormField(
                controller: deptCtrl,
                validator: (v) =>
                    v == null || v.isEmpty ? "Enter department" : null,
                decoration: const InputDecoration(labelText: "Department"),
              ),

              const SizedBox(height: 12),

              // DOB PICKER
              InkWell(
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDob ?? DateTime(2005),
                    firstDate: DateTime(1990),
                    lastDate: DateTime.now(),
                  );

                  if (pickedDate != null) {
                    setState(() {
                      selectedDob = pickedDate;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: "Date of Birth",
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    selectedDob == null
                        ? "Select Date of Birth"
                        : "${selectedDob!.day}-${selectedDob!.month}-${selectedDob!.year}",
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // SAVE BUTTON ✅ (THIS IS WHAT YOU ASKED ABOUT)
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  child: const Text("SAVE"),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // DOB validation
                      if (selectedDob == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please select Date of Birth"),
                          ),
                        );
                        return;
                      }

                      Navigator.pop(context, {
                        'roll': rollCtrl.text,
                        'name': nameCtrl.text,
                        'dob': selectedDob!.toIso8601String(),
                        'dept': deptCtrl.text,
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
