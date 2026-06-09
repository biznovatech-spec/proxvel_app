import os

base_dir = r"c:\Users\danie\Documents\Proyectos\proxvell_app\lib"

# Fix favorites_screen.dart
fav_path = os.path.join(base_dir, "views/favorites/favorites_screen.dart")
with open(fav_path, "w", encoding="utf-8") as f:
    f.write("""import 'package:flutter/material.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      body: const Center(child: Text('Lista de favoritos')),
    );
  }
}
""")

# Fix app.dart (hide SearchController from material.dart)
app_path = os.path.join(base_dir, "app.dart")
with open(app_path, "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart' hide SearchController;")

with open(app_path, "w", encoding="utf-8") as f:
    f.write(content)

print("Fixes aplicados.")
