import 'package:flutter/material.dart' as material;
import 'package:ourbit_pos/src/widgets/navigation/sidebar_drawer.dart';
import 'package:ourbit_pos/app/admin/mobile/settings/profile/profile_content_mobile.dart';
import 'package:ourbit_pos/app/admin/mobile/settings/printer/printer_content_mobile.dart';

class SettingsPageMobile extends material.StatefulWidget {
  const SettingsPageMobile({super.key});

  @override
  material.State<SettingsPageMobile> createState() =>
      _SettingsPageMobileState();
}

class _SettingsPageMobileState extends material.State<SettingsPageMobile>
    with material.SingleTickerProviderStateMixin {
  late material.TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = material.TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  material.Widget build(material.BuildContext context) {
    return material.Scaffold(
      appBar: material.AppBar(
        title: const material.Text('Pengaturan'),
        leading: material.Builder(
          builder: (context) => material.IconButton(
            icon: const material.Icon(material.Icons.menu),
            onPressed: () => material.Scaffold.of(context).openDrawer(),
          ),
        ),
        bottom: material.TabBar(
          controller: _tabController,
          tabs: const [
            material.Tab(
              icon: material.Icon(material.Icons.person),
              text: 'Profil',
            ),
            material.Tab(
              icon: material.Icon(material.Icons.print),
              text: 'Printer',
            ),
          ],
        ),
      ),
      drawer: const SidebarDrawer(),
      body: material.TabBarView(
        controller: _tabController,
        children: const [
          ProfileContentMobile(),
          PrinterContentMobile(),
        ],
      ),
    );
  }
}
