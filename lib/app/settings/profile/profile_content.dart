import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ourbit_pos/src/core/theme/app_theme.dart';

class ProfileContent extends StatelessWidget {
  const ProfileContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profil Pengguna',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.secondaryText,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Pengaturan akun akan tersedia di sini.',
          style: TextStyle(color: AppColors.secondaryText),
        ),
      ],
    );
  }
}
