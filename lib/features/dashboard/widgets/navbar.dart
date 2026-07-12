import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:reseller_app_tav/core/theme/app_assets.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';

class Navbar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const Navbar({super.key, required this.scaffoldKey});

  String _getInitial(String? name) {
    if (name == null || name.trim().isEmpty) return "?";
    return name.trim().substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final String? userPhotoUrl = authProvider.userPhotoUrl;
    final String userName = authProvider.userName ?? "Reseller";

    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu),
        color: Colors.white,
        iconSize: 24.0,
        padding: const EdgeInsets.all(8.0),
        tooltip: 'Buka Menu Sidebar',
        splashColor: Colors.white24,
        highlightColor: Colors.transparent,
        onPressed: () {
          scaffoldKey.currentState?.openDrawer();
        },
      ),
      title: Row(
        children: [SvgPicture.asset(AppAssets.logoTav, width: 120)],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Container(
                width: 36,
                height: 36,
                color: AppTheme.primaryButtonContainer,
                child: userPhotoUrl != null && userPhotoUrl.isNotEmpty
                    ? Image.network(
                        userPhotoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Text(
                              _getInitial(userName),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Montserrat',
                                fontSize: 16,
                              ),
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Text(
                          _getInitial(userName),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Montserrat',
                            fontSize: 16,
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
