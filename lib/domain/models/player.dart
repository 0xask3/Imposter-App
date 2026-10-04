final class Player {
  Player({required String id, required String name})
    : id = id.trim(),
      name = name.trim();

  final String id;
  final String name;
}
