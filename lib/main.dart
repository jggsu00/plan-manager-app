import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(PlanManagerApp());
}

class PlanManagerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plan Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PlanManagerScreen(),
    );
  }
}

class Plan {
  String name;
  String description;
  String category;
  bool isCompleted;

  Plan({
    required this.name,
    required this.description,
    required this.category,
    this.isCompleted = false,
  });
}

class PlanManagerScreen extends StatefulWidget {
  @override
  _PlanManagerScreenState createState() => _PlanManagerScreenState();
}

class _PlanManagerScreenState extends State<PlanManagerScreen> {
  List<Plan> newPlans = [];
  Map<DateTime, List<Plan>> calendarPlans = {};
  DateTime selectedDate = DateTime.now();
  Plan? _selectedPlanForEdit;

  void _addPlan(String name, String description, String category) {
    setState(() {
      newPlans.add(Plan(name: name, description: description, category: category));
    });
  }

  void _movePlanToSpecificDay(Plan plan) {
    setState(() {
      if (calendarPlans[selectedDate] == null) {
        calendarPlans[selectedDate] = [];
      }
      calendarPlans[selectedDate]!.add(plan);
      newPlans.remove(plan);
    });
  }

  void _toggleComplete(int index) {
    setState(() {
      calendarPlans[selectedDate]![index].isCompleted = !calendarPlans[selectedDate]![index].isCompleted;
    });
  }

  void _deletePlan(int index) {
    setState(() {
      calendarPlans[selectedDate]!.removeAt(index);
    });
  }

  void _showCreatePlanDialog({Plan? plan}) {
    String name = plan?.name ?? "";
    String description = plan?.description ?? "";
    String category = plan?.category ?? "Adoption";

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(plan == null ? "Create New Plan" : "Edit Plan"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(labelText: "Plan Name"),
                    controller: TextEditingController(text: name),
                    onChanged: (value) => name = value,
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: "Description"),
                    controller: TextEditingController(text: description),
                    onChanged: (value) => description = value,
                  ),
                  DropdownButton<String>(
                    value: category,
                    onChanged: (value) {
                      setDialogState(() {
                        category = value!;
                      });
                    },
                    items: ["Adoption", "Travel"].map((String category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (name.isNotEmpty) {
                      if (plan == null) {
                        _addPlan(name, description, category);
                      } else {
                        setState(() {
                          plan.name = name;
                          plan.description = description;
                          plan.category = category;
                        });
                      }
                    }
                    Navigator.of(context).pop();
                  },
                  child: Text(plan == null ? "Add" : "Update"),
                )
              ],
            );
          },
        );
      },
    );
  }

  Color _getPlanColor(Plan plan) {
    if (plan.isCompleted) {
      return plan.category == "Adoption" ? Colors.green : Colors.green;
    } else {
      return plan.category == "Adoption" ? Colors.orange : Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Plan Manager")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: ElevatedButton(
                onPressed: () => _showCreatePlanDialog(),
                child: Text("Create Plan"),
              ),
            ),
