import 'package:flutter/material.dart';
import 'hp_bottomnavbar.dart';
import 'hp_glassy_profile.dart'; 
import 'hp_userselected.dart';
import "usermodel.dart";

class HPUsersPage extends StatefulWidget {
  const HPUsersPage({super.key});

  @override
  State<HPUsersPage> createState() => _HPUsersPageState();
}

class _HPUsersPageState extends State<HPUsersPage> {
  // --- STATE VARIABLES ---
  final TextEditingController _searchController = TextEditingController();
  bool _isAscending = true;
  List<UserModel> _foundUsers = [];

  // Mocking 10 Users as requested
  final List<UserModel> _allUsers = [
    UserModel(username: "adam_t", fullName: "Tengku Adam", gender: "M", height: 175, weight: 75, device: "Apple Watch 9"),
    UserModel(username: "sarah_j", fullName: "Sarah Jenkins", gender: "F", height: 165, weight: 55, device: "Garmin Venu 3"),
    UserModel(username: "mike_r", fullName: "Mike Ross", gender: "M", height: 182, weight: 80, device: "Fitbit Sense 2"),
    UserModel(username: "clara_o", fullName: "Clara Oswald", gender: "F", height: 160, weight: 52, device: "Apple Watch SE"),
    UserModel(username: "bruce_w", fullName: "Bruce Wayne", gender: "M", height: 188, weight: 95, device: "Oura Ring Gen3"),
    UserModel(username: "diana_p", fullName: "Diana Prince", gender: "F", height: 178, weight: 65, device: "Garmin Fenix 7"),
    UserModel(username: "barry_a", fullName: "Barry Allen", gender: "M", height: 180, weight: 70, device: "Whoop 4.0"),
    UserModel(username: "selina_k", fullName: "Selina Kyle", gender: "F", height: 172, weight: 58, device: "Apple Watch S9"),
    UserModel(username: "arthur_c", fullName: "Arthur Curry", gender: "M", height: 193, weight: 105, device: "Suunto Vertical"),
    UserModel(username: "hal_j", fullName: "Hal Jordan", gender: "M", height: 185, weight: 85, device: "Galaxy Watch 6"),
  ];

  @override
  void initState() {
    _foundUsers = List.from(_allUsers);
    _applyCurrentSort();
    super.initState();
  }

  // ---------- 1. MAIN BUILD METHOD ----------
  @override
  Widget build(BuildContext context) {
    const Color themeColor = Color(0xFF8E33FF);

    return Scaffold(
      backgroundColor: themeColor,
      body: Stack(
        children: [
          // BACKGROUND HEADER
          Positioned(
            top: 80, left: 25,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Connected", 
                  style: TextStyle(fontSize: 55, fontWeight: FontWeight.bold, color: Colors.white, height: 1.0)),
                Text("Users.", 
                  style: TextStyle(fontSize: 55, fontWeight: FontWeight.bold, color: Colors.white, height: 1.0)),
              ],
            ),
          ),

          // PROFILE BUTTON
          Positioned(top: 75, right: 25, child: HPGlassyProfile(onTap: () {})),
          
          // MAIN WHITE BODY
          Column(
            children: [
              const SizedBox(height: 220),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 25),
                      _buildSearchBar(),
                      const SizedBox(height: 20),
                      _buildUserHeader(),
                      const SizedBox(height: 10),
                      Expanded(
                        child: _foundUsers.isNotEmpty 
                          ? ListView.separated(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(25, 10, 25, 120),
                              itemCount: _foundUsers.length,
                              separatorBuilder: (context, index) => const Divider(height: 30, thickness: 0.5),
                              itemBuilder: (context, index) => _buildUserTile(_foundUsers[index]),
                            )
                          : const Center(child: Text("No users found.", style: TextStyle(color: Colors.grey))),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // BOTTOM NAVIGATION BAR
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: HPBottomNavBar(currentIndex: 1, activeColor: themeColor),
          ),
        ],
      ),
    );
  }

  // ---------- 2. UI COMPONENT HELPERS ----------
  // INDIVIDUAL USER TILE
  Widget _buildUserTile(UserModel user) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => HPUserSelected(user: user))),
      child: Row(
        children: [
          const CircleAvatar(radius: 25, backgroundColor: Colors.black, child: Icon(Icons.person, color: Colors.white)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.fullName, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                Text(user.infoString, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ],
      ),
    );
  }

  // SEARCH BAR
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Container(
        height: 50,
        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(18)),
        child: TextField(
          controller: _searchController,
          onChanged: _runFilter,
          decoration: const InputDecoration(
            hintText: "Search for Patient",
            hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
            prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  // HEADER FOR THE LIST (Count and Sort toggle)
  Widget _buildUserHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("CONNECTED PATIENTS (${_foundUsers.length})", 
            style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 1.1)),
          GestureDetector(
            onTap: _toggleSort,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10)),
              child: Row(
            children: [
              Text(_isAscending ? "A-Z " : "Z-A ", 
              style: TextStyle(color: Colors.grey.shade700, fontSize: 11, fontWeight: FontWeight.bold)),
              Icon(
                _isAscending ? Icons.arrow_downward : Icons.arrow_upward, 
                size: 14, 
                color: Colors.grey.shade700
                ),
              ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- 3. LOGIC & FILTERING HELPERS ----------
  void _runFilter(String enteredKeyword) {
    List<UserModel> results = enteredKeyword.isEmpty 
        ? List.from(_allUsers) 
        : _allUsers.where((user) => user.fullName.toLowerCase().contains(enteredKeyword.toLowerCase())).toList();
    setState(() {
      _foundUsers = results;
      _applyCurrentSort();
    });
  }

  void _applyCurrentSort() {
    setState(() {
      _foundUsers.sort((a, b) => _isAscending
          ? a.fullName.compareTo(b.fullName)
          : b.fullName.compareTo(a.fullName));
    });
  }

  void _toggleSort() {
    setState(() {
      _isAscending = !_isAscending;
      _applyCurrentSort();
    });
  }
}