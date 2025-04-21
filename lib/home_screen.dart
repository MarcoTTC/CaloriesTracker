import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum MealType { breakfast, lunch, dinner, snack, other }

class FoodItem {
  final String name;
  final int calories;

  FoodItem({required this.name, required this.calories});
}

class LoggedFoodEntry {
  final FoodItem foodItem;
  final double quantity;
  final MealType mealType;
  final DateTime timestamp;

  LoggedFoodEntry({
    required this.foodItem,
    required this.quantity,
    required this.mealType,
    required this.timestamp,
  });

  int get totalCalories => (foodItem.calories * quantity).round();
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final double dailyGoal = 2000;

  List<LoggedFoodEntry> loggedEntries = [
    LoggedFoodEntry(
      foodItem: FoodItem(name: 'Oatmeal', calories: 150),
      quantity: 1.0,
      mealType: MealType.breakfast,
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    LoggedFoodEntry(
      foodItem: FoodItem(name: 'Banana', calories: 105),
      quantity: 1.0,
      mealType: MealType.breakfast,
      timestamp: DateTime.now().subtract(const Duration(hours: 4, minutes: 30)),
    ),
    LoggedFoodEntry(
      foodItem: FoodItem(name: 'Grilled Chicken Salad', calories: 350),
      quantity: 1.0,
      mealType: MealType.lunch,
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    LoggedFoodEntry(
      foodItem: FoodItem(name: 'Apple', calories: 95),
      quantity: 1.0,
      mealType: MealType.snack,
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
  ];

  int get totalConsumedCalories {
    return loggedEntries.fold(
      0,
          (sum, entry) => sum + entry.totalCalories,
    );
  }

  int get remainingCalories {
    return (dailyGoal - totalConsumedCalories).round();
  }

  Map<MealType, List<LoggedFoodEntry>> get entriesGroupedByMeal {
    final Map<MealType, List<LoggedFoodEntry>> grouped = {};
    for (var entry in loggedEntries) {
      grouped.putIfAbsent(entry.mealType, () => []).add(entry);
    }
    return grouped;
  }

  String getMealTypeName(MealType type) {
    switch (type) {
      case MealType.breakfast: return 'Breakfast';
      case MealType.lunch: return 'Lunch';
      case MealType.dinner: return 'Dinner';
      case MealType.snack: return 'Snack';
      case MealType.other: return 'Other';
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final formatter = DateFormat('EEEE, MMMM d');

    final groupedEntries = entriesGroupedByMeal;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calorie Tracker'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formatter.format(today),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),

            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: CircularProgressIndicator(
                      value: totalConsumedCalories / dailyGoal,
                      strokeWidth: 12,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        remainingCalories >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$totalConsumedCalories',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: remainingCalories >= 0 ? Colors.green[700] : Colors.red[700], // Color based on remaining
                        ),
                      ),
                      Text(
                        'of $dailyGoal kcal',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '${remainingCalories >= 0 ? remainingCalories : remainingCalories.abs()} kcal ${remainingCalories >= 0 ? 'left' : 'over'}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: remainingCalories >= 0 ? Colors.green[700] : Colors.red[700],
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            Text(
              'Today\'s Log',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),

            Expanded(
              child: ListView(
                children: groupedEntries.entries.map((entry) {
                  entry.value.sort((a, b) => a.timestamp.compareTo(b.timestamp));

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          getMealTypeName(entry.key),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Column(
                        children: entry.value.map((foodEntry) {
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0),
                            child: ListTile(
                              title: Text(foodEntry.foodItem.name),
                              trailing: Text(
                                '${foodEntry.totalCalories} kcal',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to Add Food Screen
          print('Add Food Button Pressed');
        },
        tooltip: 'Add Food',
        child: const Icon(Icons.add),
      ),
    );
  }
}