import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ourbit_pos/blocs/appbar_bloc.dart';
import 'package:ourbit_pos/blocs/appbar_event.dart';
import 'package:ourbit_pos/blocs/appbar_state.dart';

/// Global custom appbar widget for Allnimall application
///
/// This widget provides a consistent header across the application with:
/// - Business name and store name display
/// - User information with avatar
/// - Custom actions support
/// - Automatic data loading from local storage
/// - Real role data from database (e.g., "Owner", "Admin", "Cashier", "Vet", "Groomer")
///
/// Usage:
/// ```dart
/// // Basic usage - will show real role from database
/// const AllnimallAppBar()
///
/// // With custom title and subtitle
/// const AllnimallAppBar(
///   title: 'Custom Title',
///   subtitle: 'Custom Subtitle',
/// )
///
/// // With custom actions
/// const AllnimallAppBar(
///   actions: [
///     IconButton(
///       onPressed: () {},
///       icon: Icon(Icons.settings),
///     ),
///   ],
/// )
///
/// // Without user info
/// const AllnimallAppBar(
///   showUserInfo: false,
/// )
/// ```
///
/// **Role Data Priority:**
/// 1. Real role from database (stored in local storage)
/// 2. Fallback to "User"
class AllnimallAppBar extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final List<Widget>? actions;
  final bool showUserInfo;

  const AllnimallAppBar({
    super.key,
    this.title,
    this.subtitle,
    this.actions,
    this.showUserInfo = true,
  });

  String _getFirstName(String fullName) {
    final parts = fullName.split(' ');
    return parts.isNotEmpty ? parts.first : fullName;
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length > 1) {
      return '${parts.first[0]}${parts.last[0]}';
    } else {
      return name.isNotEmpty ? name[0] : 'U';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppBarBloc()..add(LoadAppBarData()),
      child: BlocBuilder<AppBarBloc, AppBarState>(
        builder: (context, state) {
          if (state is AppBarLoading) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Colors.slate[100], width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 20,
                          width: 200,
                          decoration: BoxDecoration(
                            color: Colors.slate[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const Gap(4),
                        Container(
                          height: 14,
                          width: 150,
                          decoration: BoxDecoration(
                            color: Colors.slate[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is AppBarLoaded) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Colors.slate[100], width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title ?? state.businessName).bold(),
                        Text(subtitle ?? state.storeName).muted().small(),
                      ],
                    ),
                  ),
                  // Custom actions
                  if (actions != null) ...actions!,
                  // User info section
                  if (showUserInfo) ...[
                    const Gap(16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // User info
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getFirstName(state.userName),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ).small(),
                              const Gap(4),
                              Text(
                                '|',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ).small,
                              const Gap(4),
                              Text(
                                state.userRole,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ).small,
                            ],
                          ),
                          const Gap(8),
                          // Avatar
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                _getInitials(state.userName),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          }

          if (state is AppBarError) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Colors.slate[100], width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Error loading data').bold(),
                        Text('Please refresh the page').muted().small(),
                      ],
                    ),
                  ),
                  IconButton.primary(
                    onPressed: () {
                      context.read<AppBarBloc>().add(RefreshAppBarData());
                    },
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
            );
          }

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.slate[100], width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Loading...').bold(),
                      Text('Please wait').muted().small(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
