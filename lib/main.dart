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
  List<Plan> newPlans = []; // Holds newly created plans before dragging into the list
  Map<DateTime, List<Plan>> calendarPlans = {}; // Maps dates to plans
  DateTime selectedDate = DateTime.now(); // Tracks selected date for calendar
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
      newPlans.remove(plan); // Remove from new plans after it's dragged
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
