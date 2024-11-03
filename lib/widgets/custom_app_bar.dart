import 'package:flutter/material.dart';
import '../pages/notifications_page.dart';
import '../pages/profile_page.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget> actions;
  final PreferredSizeWidget? bottom;
  final String userId;
  final String userRole;
  final String userPhotoUrl;

  const CustomAppBar({
    Key? key,
    required this.title,
    required this.userId,
    required this.userRole,
    required this.userPhotoUrl,
    this.actions = const [],
    this.bottom,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('CustomAppBar userPhotoUrl: $userPhotoUrl'); // Debug statement

    return AppBar(
      backgroundColor: const Color(0xFFFFA726),
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Image.asset('assets/logo.png', height: 40),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationsPage(userId: userId, userRole: userRole)),
              );
            },
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage(userId: userId, userRole: userRole)),
              );
            },
            child: CircleAvatar(
              backgroundImage: userPhotoUrl.isNotEmpty
                  ? NetworkImage(userPhotoUrl)
                  : AssetImage('assets/user_profile.png') as ImageProvider, // Use a placeholder image if the URL is empty
            ),
          ),
          ...actions,
        ],
      ),
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
      kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));
}