import 'package:flutter/material.dart';

import 'package:fittracker_source/Screens/active_screen/journal/controllers/food_search_controller.dart';
import 'package:fittracker_source/Screens/active_screen/journal/meal_summary_screen.dart';
import 'package:fittracker_source/models/food.dart';
import 'package:fittracker_source/models/meal_type.dart';

class SearchFoodScreen extends StatefulWidget {
  final MealType mealType;

  const SearchFoodScreen({super.key, required this.mealType});

  @override
  State<SearchFoodScreen> createState() => _SearchFoodScreenState();
}

class _SearchFoodScreenState extends State<SearchFoodScreen> {
  late final FoodSearchController _controller;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = FoodSearchController(mealType: widget.mealType)..load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveAndReview() async {
    await _controller.saveSelection();
    if (!mounted) return;

    final shouldRefresh = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => MealSummaryScreen(
          meal: _controller.currentMeal,
          mealTargets: _controller.mealTargets,
          onAddMore: () => Navigator.of(context).pop(),
          onDone: () => Navigator.of(context).pop(true),
        ),
      ),
    );

    if (!mounted) return;
    Navigator.of(context).pop(shouldRefresh == true);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: Text('Search food • ${widget.mealType.label}')),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  onChanged: _controller.updateKeyword,
                  decoration: const InputDecoration(
                    hintText: 'Search food by name or description',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              if (_controller.isLoading)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _controller.visibleFoods.length,
                    itemBuilder: (context, index) {
                      final food = _controller.visibleFoods[index];
                      final quantity = _controller.quantityOf(food.id);
                      return _FoodTile(
                        food: food,
                        quantity: quantity,
                        onIncrease: () => _controller.increase(food),
                        onDecrease: () => _controller.decrease(food),
                      );
                    },
                  ),
                ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _controller.isSaving ? null : _saveAndReview,
                      child: Text(
                        _controller.isSaving
                            ? 'Saving...'
                            : 'Save ${widget.mealType.label} (${_controller.currentMeal.entries.length} items)',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FoodTile extends StatelessWidget {
  final Food food;
  final int quantity;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const _FoodTile({
    required this.food,
    required this.quantity,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.orange.shade50,
              child: const Icon(Icons.restaurant_menu, color: Colors.orange),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(food.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('${food.calories} Cal · P${food.protein} F${food.fat} C${food.carb}'),
                  if (food.description.trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        food.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(onPressed: onDecrease, icon: const Icon(Icons.remove_circle_outline)),
                Text('$quantity'),
                IconButton(onPressed: onIncrease, icon: const Icon(Icons.add_circle_outline)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
