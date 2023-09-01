import 'package:flutter/material.dart';
import 'my_list_title.dart';

class MyDrawer extends StatelessWidget {
  final void Function()? onSignOut;

  const MyDrawer({super.key, required this.onSignOut});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey[900],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              //header
              const DrawerHeader(
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 64,
                ),
              ),

              //home list title
              MyListTitle(
                icon: Icons.home,
                text: 'H O M E',
                onTap: () => Navigator.pop(context),
              ),

              MyListTitle(
                icon: Icons.logout,
                text: 'L O G O U T',
                onTap: onSignOut,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
