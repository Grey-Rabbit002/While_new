import 'package:com.example.while_app/view/profile/community_connect.dart';
import 'package:com.example.while_app/view/profile/demo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectScreen extends ConsumerStatefulWidget {
  const ConnectScreen({Key? key}) : super(key: key);

  @override
  ConnectScreenState createState() => ConnectScreenState();
}

class ConnectScreenState extends ConsumerState<ConnectScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Initialize the TabController
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    // Dispose the TabController
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: TabBar(
        controller: _tabController,
        indicatorColor: Colors.black,
        tabs: const [
          Tab(
            text: 'People',
          ),
          Tab(
            text: 'Communities',
          ),
        ],
        labelColor: Colors.black, // Set the text color of the selected tab
        unselectedLabelColor:
            Colors.grey, // Set the text color of unselected tabs
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          Connect(),
          CommunityConnect(),
        ],
      ),
    );
  }
}
