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
            DragTarget<Plan>(
              onAccept: (plan) {
                _movePlanToSpecificDay(plan);
              },
              builder: (context, candidateData, rejectedData) {
                return Container(
                  height: 80,
                  color: Colors.blue[50],
                  child: Center(
                    child: Text(
                      "Drop plans here",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),

            if (newPlans.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("New Plans (Drag to Add)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Container(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: newPlans.map((plan) {
                    return Draggable<Plan>(
                      data: plan,
                      feedback: Material(
                        color: Colors.transparent,
                        child: Container(
                          width: 150,
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _getPlanColor(plan).withOpacity(0.7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(plan.name, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              Text(plan.category, style: TextStyle(color: Colors.white70)),
                            ],
                          ),
                        ),
                      ),
                      child: Container(
                        width: 150,
                        padding: EdgeInsets.all(8),
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          color: _getPlanColor(plan).withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(plan.name, style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(plan.category),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2025, 12, 31),
                focusedDay: selectedDate,
                selectedDayPredicate: (day) {
                  return isSameDay(day, selectedDate);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    selectedDate = selectedDay;
                  });
                },
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, events) {
                    if (calendarPlans[day] != null && calendarPlans[day]!.isNotEmpty) {
                      return Positioned(
                        bottom: 1,
                        right: 1,
                        child: Icon(
                          Icons.circle,
                          size: 10,
                          color: Colors.blueAccent,
                        ),
                      );
                    }
                    return SizedBox.shrink();
                  },
                ),
              ),
            ),
