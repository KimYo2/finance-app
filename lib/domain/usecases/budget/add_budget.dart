import '../../entities/budget.dart';
import '../../repositories/budget_repository.dart';

class AddBudget {
  final BudgetRepository repository;

  AddBudget(this.repository);

  Future<void> call(Budget budget) async {
    await repository.setBudget(budget);
  }
}
