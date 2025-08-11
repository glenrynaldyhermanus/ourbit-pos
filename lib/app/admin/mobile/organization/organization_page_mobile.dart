import 'package:flutter/material.dart' as material;
import 'package:ourbit_pos/src/widgets/navigation/sidebar_drawer.dart';
import 'package:ourbit_pos/app/admin/mobile/organization/stores/stores_content_mobile.dart';
import 'package:ourbit_pos/app/admin/mobile/organization/staffs/staffs_content_mobile.dart';
import 'package:ourbit_pos/app/admin/mobile/organization/onlinestores/onlinestores_content_mobile.dart';

class OrganizationPageMobile extends material.StatefulWidget {
  const OrganizationPageMobile({super.key});

  @override
  material.State<OrganizationPageMobile> createState() =>
      _OrganizationPageMobileState();
}

class _OrganizationPageMobileState
    extends material.State<OrganizationPageMobile>
    with material.SingleTickerProviderStateMixin {
  late material.TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = material.TabController(length: 3, vsync: this);
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
        title: const material.Text('Organisasi'),
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
              icon: material.Icon(material.Icons.store),
              text: 'Toko',
            ),
            material.Tab(
              icon: material.Icon(material.Icons.people),
              text: 'Staff',
            ),
            material.Tab(
              icon: material.Icon(material.Icons.shopping_cart),
              text: 'Online',
            ),
          ],
        ),
      ),
      drawer: const SidebarDrawer(),
      body: material.TabBarView(
        controller: _tabController,
        children: const [
          StoresContentMobile(),
          StaffsContentMobile(),
          OnlineStoresContentMobile(),
        ],
      ),
    );
  }
}
