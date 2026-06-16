import 'package:klimatrack_app/domain/core/result.dart';

abstract class UseCase<T, Params> {
  Future<Result<T>> call(Params params);
}
