import 'package:ourbit_pos/src/data/objects/product.dart';
import 'package:ourbit_pos/src/data/repositories/management_repository.dart';

class GetAllProductsUseCase {
  final ManagementRepository _managementRepository;

  GetAllProductsUseCase(this._managementRepository);

  Future<List<Product>> execute() async {
    return await _managementRepository.getAllProducts();
  }
}
