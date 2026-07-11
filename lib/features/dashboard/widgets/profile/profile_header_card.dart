import 'package:flutter/material.dart';

class ProfileHeaderCard extends StatelessWidget {
  final String? userPhotoUrl;
  final String name;

  const ProfileHeaderCard({
    super.key,
    required this.userPhotoUrl,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAEAEA), width: 1.5),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: const Color(0xFFFFEAEA),
            backgroundImage: userPhotoUrl != null
                ? NetworkImage(userPhotoUrl!)
                : null,
            child: userPhotoUrl == null
                ? const Icon(
                    Icons.person_rounded,
                    size: 40,
                    color: Color(0xFFE52525),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
              color: Color(0xFF222222),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F9EE),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Mitra Agen Aktif',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF27AE60),
                fontFamily: 'Montserrat',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
