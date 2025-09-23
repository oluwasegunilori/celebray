import 'package:uuid/uuid.dart';

final Uuid uuid = Uuid();

String uniqueId() {
  return uuid.v4().toString();
}
