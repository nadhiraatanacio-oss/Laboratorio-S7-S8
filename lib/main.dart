// ============================================================
//  App Alumnos - Sección A
//  Login -> Menú -> Listar Alumnos / Registrar Alumno / Perfil -> Logout
//  Todo en un solo archivo: lib/main.dart
// ============================================================
import 'package:flutter/material.dart';

void main() => runApp(const AppAlumnos());

// Color principal de la Sección A (morado)
const kMorado = Color(0xFF5B3FD1);
const kMoradoClaro = Color(0xFFEDE9FB);

// ------------------------------------------------------------
// MODELO: un alumno con nombre, apellido y nota
// ------------------------------------------------------------
class Alumno {
  final String nombre;
  final String apellido;
  final int nota;

  const Alumno(this.nombre, this.apellido, this.nota);

  // Getter: aprueba con nota mayor o igual a 11 (escala 0 - 20)
  bool get aprobado => nota >= 11;

  String get nombreCompleto => '$nombre $apellido';
}

// Datos de ejemplo (no se guardan, el registro es solo visual)
const List<Alumno> alumnos = [
  Alumno('Ana', 'Torres', 18),
  Alumno('Luis', 'García', 12),
  Alumno('María', 'López', 9),
  Alumno('Carlos', 'Ruiz', 15),
];

// Map: datos del perfil (clave -> valor)
const Map<String, String> datosPerfil = {
  'Nombre': 'María González',
  'Email': 'maria.gonzalez@correo.com',
  'Teléfono': '912345678',
  'Roles': 'Docente',
};

// Map: ícono que corresponde a cada dato del perfil
const Map<String, IconData> iconosPerfil = {
  'Nombre': Icons.person,
  'Email': Icons.email,
  'Teléfono': Icons.phone,
  'Roles': Icons.settings,
};

// Opciones del menú: se usan en la pantalla Menú y en el Drawer
class OpcionMenu {
  final IconData icono;
  final String titulo;
  final String ruta;
  const OpcionMenu(this.icono, this.titulo, this.ruta);
}

const List<OpcionMenu> opcionesMenu = [
  OpcionMenu(Icons.person_add_alt_1, 'Registrar Alumnos', '/registrar'),
  OpcionMenu(Icons.format_list_bulleted, 'Listar Alumnos', '/alumnos'),
  OpcionMenu(Icons.person, 'Perfil', '/perfil'),
];

// ------------------------------------------------------------
// APP: tema global y rutas con nombre
// ------------------------------------------------------------
class AppAlumnos extends StatelessWidget {
  const AppAlumnos({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Alumnos',
      debugShowCheckedModeBanner: false,
      // NO VISTO EN CLASE (1): ColorScheme.fromSeed genera toda la paleta
      // de Material 3 a partir de un solo color (kMorado)
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: kMorado, primary: kMorado),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: kMorado,
          foregroundColor: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      // La app arranca en el login
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/menu': (_) => const MenuScreen(),
        '/alumnos': (_) => const ListarAlumnosScreen(),
        '/registrar': (_) => const RegistrarAlumnoScreen(),
        '/perfil': (_) => const PerfilScreen(),
      },
    );
  }
}

// ------------------------------------------------------------
// FUNCIONES DE NAVEGACIÓN reutilizables
// ------------------------------------------------------------

// Va a una ruta; si ya estamos en esa pantalla no la apila otra vez
void irA(BuildContext context, String ruta) {
  final actual = ModalRoute.of(context)?.settings.name;
  if (actual != ruta) Navigator.pushNamed(context, ruta);
}

// NO VISTO EN CLASE (2): showDialog + AlertDialog esperan la respuesta
// del usuario y pushNamedAndRemoveUntil borra todo el historial
Future<void> cerrarSesion(BuildContext context) async {
  final confirmar = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Cerrar sesión'),
      content: const Text('¿Seguro que deseas salir?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Salir'),
        ),
      ],
    ),
  );
  // mounted evita usar un context que ya no existe
  if (confirmar == true && context.mounted) {
    // (route) => false elimina todas las pantallas anteriores
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }
}

// Muestra un mensaje corto en la parte inferior
void mostrarMensaje(BuildContext context, String texto) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
}

// ------------------------------------------------------------
// 1. LOGIN
// ------------------------------------------------------------
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _ocultarPassword = true; // controla el ícono del ojo

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(Icons.school, size: 90, color: kMorado),
                const SizedBox(height: 16),
                const Text(
                  'Iniciar Sesión',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ingresa tus credenciales para continuar',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 32),
                const TextField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    prefixIcon: Icon(Icons.mail_outline),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  obscureText: _ocultarPassword,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    // Botón del ojo: muestra u oculta la contraseña
                    suffixIcon: IconButton(
                      icon: Icon(_ocultarPassword
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () =>
                          setState(() => _ocultarPassword = !_ocultarPassword),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    // pushReplacement: al volver atrás no regresa al login
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, '/menu'),
                    child: const Text('LOGIN'),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () =>
                      mostrarMensaje(context, 'Función no disponible'),
                  child: const Text(
                    '¿Olvidaste tu contraseña?',
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// NO VISTO EN CLASE (3): Drawer, menú lateral que se abre con el ícono ☰.
// Al poner drawer: en el Scaffold, Flutter agrega el ícono solo
// ------------------------------------------------------------
class MenuLateral extends StatelessWidget {
  const MenuLateral({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: kMorado),
            child: Row(
              children: [
                Icon(Icons.school, color: Colors.white, size: 40),
                SizedBox(width: 12),
                Text('App Alumnos',
                    style: TextStyle(color: Colors.white, fontSize: 20)),
              ],
            ),
          ),
          // Recorremos la lista de opciones para crear cada fila
          for (final op in opcionesMenu)
            ListTile(
              leading: Icon(op.icono, color: kMorado),
              title: Text(op.titulo),
              onTap: () {
                Navigator.pop(context); // primero cierra el drawer
                irA(context, op.ruta);
              },
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout'),
            // No cerramos el drawer antes: el diálogo necesita este context
            onTap: () => cerrarSesion(context),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------
// 2. MENÚ
// ------------------------------------------------------------
class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menú')),
      drawer: const MenuLateral(),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // La primera opción va resaltada, como en el diseño
          for (int i = 0; i < opcionesMenu.length; i++)
            _ItemMenu(
              icono: opcionesMenu[i].icono,
              titulo: opcionesMenu[i].titulo,
              destacado: i == 0,
              onTap: () => irA(context, opcionesMenu[i].ruta),
            ),
          _ItemMenu(
            icono: Icons.logout,
            titulo: 'Logout',
            colorIcono: Colors.red,
            onTap: () => cerrarSesion(context),
          ),
        ],
      ),
    );
  }
}

// Fila reutilizable del menú (ícono + texto + flecha)
class _ItemMenu extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final VoidCallback onTap;
  final bool destacado;
  final Color colorIcono;

  const _ItemMenu({
    required this.icono,
    required this.titulo,
    required this.onTap,
    this.destacado = false, // parámetros opcionales con valor por defecto
    this.colorIcono = kMorado,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        tileColor: destacado ? kMoradoClaro : null,
        leading: Icon(icono, color: colorIcono),
        title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

// ------------------------------------------------------------
// 3. LISTAR ALUMNOS (con buscador)
// ------------------------------------------------------------
class ListarAlumnosScreen extends StatefulWidget {
  const ListarAlumnosScreen({super.key});

  @override
  State<ListarAlumnosScreen> createState() => _ListarAlumnosScreenState();
}

class _ListarAlumnosScreenState extends State<ListarAlumnosScreen> {
  String _busqueda = '';

  @override
  Widget build(BuildContext context) {
    // Filtra la lista cada vez que cambia el texto del buscador
    final filtrados = alumnos
        .where((a) =>
            a.nombreCompleto.toLowerCase().contains(_busqueda.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alumnos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Registrar alumno',
            onPressed: () => irA(context, '/registrar'),
          ),
        ],
      ),
      drawer: const MenuLateral(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (texto) => setState(() => _busqueda = texto),
              decoration: InputDecoration(
                hintText: 'Buscar alumno...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: filtrados.isEmpty
                ? const Center(child: Text('No se encontraron alumnos'))
                // ListView.builder crea solo las filas que se ven en pantalla
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: filtrados.length,
                    itemBuilder: (context, i) =>
                        _AlumnoTile(alumno: filtrados[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

// Fila de un alumno: avatar, nombre, nota, estado y menú de 3 puntos
class _AlumnoTile extends StatelessWidget {
  final Alumno alumno;
  const _AlumnoTile({required this.alumno});

  @override
  Widget build(BuildContext context) {
    // Card: tarjeta con sombra y bordes redondeados para cada alumno
    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: kMoradoClaro,
          child: Icon(Icons.school, color: kMorado),
        ),
        title: Text(alumno.nombreCompleto,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        // padLeft muestra 09 en vez de 9
        subtitle: Text('Nota: ${alumno.nota.toString().padLeft(2, '0')}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _EstadoBadge(aprobado: alumno.aprobado),
            // NO VISTO EN CLASE (4): PopupMenuButton crea el botón de 3 puntos
            // y un menú flotante; onSelected recibe la opción elegida
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (opcion) =>
                  mostrarMensaje(context, '$opcion: ${alumno.nombreCompleto}'),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'Editar', child: Text('Editar')),
                PopupMenuItem(value: 'Eliminar', child: Text('Eliminar')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Etiqueta verde (Aprobado) o roja (Desaprobado)
class _EstadoBadge extends StatelessWidget {
  final bool aprobado;
  const _EstadoBadge({required this.aprobado});

  @override
  Widget build(BuildContext context) {
    final MaterialColor color = aprobado ? Colors.green : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.shade50,
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        aprobado ? 'Aprobado' : 'Desaprobado',
        style: TextStyle(color: color.shade700, fontSize: 12),
      ),
    );
  }
}

// ------------------------------------------------------------
// 4. REGISTRAR ALUMNO (solo visual, no guarda datos)
// ------------------------------------------------------------
class RegistrarAlumnoScreen extends StatelessWidget {
  const RegistrarAlumnoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Al llegar con pushNamed, el AppBar pone la flecha ← sola
      appBar: AppBar(title: const Text('Registrar Alumno')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const TextField(
              decoration: InputDecoration(hintText: 'Nombre del alumno'),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(hintText: 'Apellido'),
            ),
            const SizedBox(height: 16),
            const TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Nota (0 - 20)',
                suffixIcon: Icon(Icons.school_outlined),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  mostrarMensaje(context, 'Alumno registrado');
                  Navigator.pop(context); // regresa a la pantalla anterior
                },
                child: const Text('GUARDAR'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// 5. PERFIL
// ------------------------------------------------------------
class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Stack: pone el botón de lápiz encima del avatar
            Stack(
              children: [
                const CircleAvatar(
                  radius: 55,
                  backgroundColor: kMoradoClaro,
                  child: Icon(Icons.person, size: 70, color: kMorado),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: CircleAvatar(
                    radius: 17,
                    backgroundColor: kMorado,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      iconSize: 18,
                      icon: const Icon(Icons.edit, color: Colors.white),
                      onPressed: () => mostrarMensaje(context, 'Cambiar foto'),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('María González',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Text('maria.gonzalez@correo.com',
                style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 20),
            // Recorremos el Map: cada entrada (clave, valor) es una fila
            for (final dato in datosPerfil.entries)
              _FilaDato(
                icono: iconosPerfil[dato.key] ?? Icons.info,
                etiqueta: dato.key,
                valor: dato.value,
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: kMorado),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => mostrarMensaje(context, 'Editar perfil'),
                child: const Text('EDITAR PERFIL'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Fila de dato del perfil: ícono + etiqueta a la izquierda, valor a la derecha
class _FilaDato extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final String valor;
  const _FilaDato(
      {required this.icono, required this.etiqueta, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Icon(icono, color: Colors.black54, size: 20),
          const SizedBox(width: 12),
          Text(etiqueta, style: const TextStyle(fontWeight: FontWeight.w600)),
          const Spacer(),
          Flexible(child: Text(valor, textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}