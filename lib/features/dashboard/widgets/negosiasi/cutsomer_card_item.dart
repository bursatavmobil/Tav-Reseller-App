import 'package:flutter/material.dart';

class CustomerItemCard extends StatelessWidget {
  final dynamic customer;
  final VoidCallback onEdit;

  const CustomerItemCard({
    super.key,
    required this.customer,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final String address = customer['user_address_default'] != null
        ? customer['user_address_default']['address']
        : '-';

    final String accountStatus = customer['account_status'] ?? 'UNVERIFIED';
    final bool isVerified = accountStatus.toUpperCase() == 'VERIFIED';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFF8F9FA),
              border: Border(
                bottom: BorderSide(color: Color(0xFFEFEFEF), width: 0.8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isVerified
                        ? const Color(0xFFD4AF37).withOpacity(0.12)
                        : const Color(0xFFE52525).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isVerified
                          ? const Color(0xFFD4AF37)
                          : const Color(0xFFE52525),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isVerified
                            ? Icons.verified_user_rounded
                            : Icons.gpp_maybe_rounded,
                        size: 11,
                        color: isVerified
                            ? const Color(0xFFD4AF37)
                            : const Color(0xFFE52525),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        accountStatus,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          color: isVerified
                              ? const Color(0xFFD4AF37)
                              : const Color(0xFFE52525),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F3F5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.edit_note_rounded,
                      size: 18,
                      color: Color(0xFFD4AF37),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 26,
                    backgroundColor: const Color(0xFFF1F3F5),
                    backgroundImage: customer['photo'] != null
                        ? NetworkImage(customer['photo'])
                        : null,
                    child: customer['photo'] == null
                        ? const Icon(
                            Icons.person_rounded,
                            color: Color(0xFF8E8E93),
                            size: 28,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer['first_name'] ?? 'No Name',
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1A1A1A),
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.phone_iphone_rounded,
                            size: 12,
                            color: Color(0xFF8E8E93),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            customer['phone'] ?? '-',
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.mail_outline_rounded,
                            size: 12,
                            color: Color(0xFF8E8E93),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              customer['email'] ?? '-',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF8E8E93),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Divider(color: Color(0xFFEFEFEF), height: 1),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Icon(
                              Icons.location_on_rounded,
                              size: 12,
                              color: Color(0xFFE52525),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              address,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF8E8E93),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
