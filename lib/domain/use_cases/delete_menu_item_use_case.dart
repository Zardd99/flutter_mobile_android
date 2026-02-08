import 'package:restaurant_mobile_app/core/errors/failure.dart';
import 'package:restaurant_mobile_app/core/errors/result.dart';
import 'package:restaurant_mobile_app/domain/repositories/menu_repository.dart';

class DeleteMenuItemUseCase {
  final MenuRepository _repository;

  DeleteMenuItemUseCase(this._repository);

  Future<Result<void>> execute({required String id, String? authToken}) async {
    if (id.isEmpty) {
      return ResultFailure(Failure.validation('Menu item ID is required'));
    }

    return await _repository.deleteMenuItem(id, authToken ?? '');
  }
}
