import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jetokin/NavBarProvider.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final navBarProvider = Provider.of<NavBarProvider>(context);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF874D4F), Color(0xFFE5E5E5)], // Gradien warna
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8.0,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent, // Transparan untuk gradien
        elevation: 0, // Hilangkan bayangan bawaan
        currentIndex: navBarProvider.currentIndex,
        onTap: (index) {
          navBarProvider.updateIndex(index);
          _navigateToScreen(context, index);
        },
        items: [
          _buildNavItem(
            context,
            icon: Icons.home,
            label: 'Home',
            isActive: navBarProvider.currentIndex == 0,
          ),
          _buildNavItem(
            context,
            icon: Icons.quiz_outlined,
            label: 'Quiz',
            isActive: navBarProvider.currentIndex == 1,
          ),
          _buildNavItem(
            context,
            icon: Icons.list_rounded,
            label: 'Pahlawan',
            isActive: navBarProvider.currentIndex == 2,
          ),
          _buildNavItem(
            context,
            icon: Icons.account_circle_outlined,
            label: 'Profil',
            isActive: navBarProvider.currentIndex == 3,
          ),
        ],
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isActive,
  }) {
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(2.0),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Icon(
          icon,
          size: isActive ? 28 : 24,
          color: isActive ? Colors.red : Colors.grey,
        ),
      ),
      label: label,
    );
  }

  void _navigateToScreen(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushNamed(context, '/quiz');
        break;
      case 2:
        Navigator.pushNamed(context, '/daftar_pahlawan');
        break;
      case 3:
        Navigator.pushNamed(context, '/profil');
        break;
      default:
        break;
    }
  }
}
