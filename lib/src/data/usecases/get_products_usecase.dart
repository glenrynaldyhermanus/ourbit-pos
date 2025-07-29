import 'package:ourbit_pos/src/data/objects/product.dart';
import 'package:ourbit_pos/src/data/repositories/pos_repository.dart';

class GetProductsUseCase {
  final PosRepository _posRepository;

  GetProductsUseCase(this._posRepository);

  Future<List<Product>> call() async {
    return await _posRepository.getProducts();
  }
}
