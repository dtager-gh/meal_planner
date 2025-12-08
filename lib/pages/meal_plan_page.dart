import 'package:flutter/material.dart';
import '../models/week_plan.dart';
import 'shopping_list_page.dart';
import '../services/shopping_list.dart';


class MealPlanPage extends StatelessWidget {
  final WeekPlan plan; // The WeekPlan data passed into this page

  const MealPlanPage({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Allows the background gradient to show behind the AppBar
      extendBodyBehindAppBar: true,

      // Transparent AppBar that sits on top of the gradient
      appBar: AppBar(
        title: const Text(
          "Weekly Meal Plan",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // Main background of the entire screen (green gradient)
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,

            // Your gradient colors
            colors: [
              Colors.green.shade300,
              Colors.teal.shade400,
              Colors.green.shade700,
            ],
          ),
        ),

        child: SafeArea(
          child: Column(
            children: [

              // HEADER SECTION

              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(16),

                  // Semi-transparent card over the gradient
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),

                  child: Row(
                    children: [
                      // Calendar icon box
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.calendar_today,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Text inside header
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '7-Day Meal Plan',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            // Automatically calculates meal count
                            Text(
                              '${plan.days.length * 2} delicious meals planned',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // LIST OF DAYS

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: plan.days.length, // Always 7
                  itemBuilder: (context, index) {
                    final day = plan.days[index];

                    // Day names for display
                    final dayNames = [
                      'Monday', 'Tuesday', 'Wednesday',
                      'Thursday', 'Friday', 'Saturday', 'Sunday'
                    ];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),

                      // White rounded card background for each day
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            offset: const Offset(0, 4),
                            blurRadius: 12,
                          ),
                        ],
                      ),

                      child: Column(
                        children: [

                          // DAY HEADER (Orange gradient)

                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.orange.shade300,
                                  Colors.deepOrange.shade400,
                                ],
                              ),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),

                            child: Row(
                              children: [
                                // Number badge
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 12),

                                // Day name label
                                Text(
                                  dayNames[index % 7],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // LUNCH + DINNER SECTION

                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                // LUNCH
                                _buildMealSection(
                                  icon: Icons.wb_sunny,
                                  iconColor: Colors.amber.shade600,
                                  title: 'Lunch',
                                  meat: day.lunch.meat,
                                  sides: day.lunch.sides,
                                ),

                                const SizedBox(height: 16),
                                Divider(color: Colors.grey.shade300),
                                const SizedBox(height: 16),

                                // DINNER
                                _buildMealSection(
                                  icon: Icons.nightlight_round,
                                  iconColor: Colors.indigo.shade400,
                                  title: 'Dinner',
                                  meat: day.dinner.meat,
                                  sides: day.dinner.sides,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      // SHOPPING LIST BUTTON

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Generates all ingredients for the week into one shopping list
          final shoppingList = generateShoppingList(plan);

          // Opens the ShoppingListPage
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ShoppingListPage(shoppingList: shoppingList),
            ),
          );
        },
        icon: const Icon(Icons.shopping_cart),
        label: const Text('Shopping List'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // SMALL HELPER WIDGET TO DISPLAY LUNCH / DINNER SECTIONS

  Widget _buildMealSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String meat,
    required List<String> sides,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side icon box
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ),

        const SizedBox(width: 12),

        // Right side text content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // "Lunch" or "Dinner"
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 6),

              // Displays main meat item
              Text(
                meat,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 4),

              // Displays list of sides in rounded chips
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: sides.map((side) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      side,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
