import '../entities/budget.dart';

abstract class BudgetRepository {
  Future<void> initialize();
  Future<List<Budget>> getBudgets();
  Future<void> setBudget(Budget budget);
  Future<void> deleteBudget(String id);
}
