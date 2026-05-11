import '../../entities/budget.dart';
import '../../repositories/budget_repository.dart';

class GetBudgets {
  final BudgetRepository repository;

  GetBudgets(this.repository);

  Future<List<Budget>> call() async {
    return await repository.getBudgets();
  }
}
