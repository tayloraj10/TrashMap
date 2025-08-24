import 'package:flutter/material.dart';

class AttendeeAvatar extends StatelessWidget {
  final Map<String, dynamic> userData;
  const AttendeeAvatar({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    String displayName = userData['displayName'] ?? '';
    String email = userData['email'] ?? '';
    String? photoURL = userData['photoURL'];

    return Tooltip(
      message: displayName.isNotEmpty ? displayName : email,
      child: CircleAvatar(
        radius: 20,
        backgroundColor: Colors.green.shade600,
        child: photoURL != null
            ? ClipOval(
                child: Image.network(
                  photoURL,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Text(
                        (displayName.isNotEmpty ? displayName[0] : email[0])
                            .toUpperCase(),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    );
                  },
                ),
              )
            : Text(
                (displayName.isNotEmpty ? displayName[0] : email[0])
                    .toUpperCase(),
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20),
              ),
      ),
    );
  }
}
