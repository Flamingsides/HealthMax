import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';

// --- Internal Data Model ---
class DeviceModel {
  final String name;
  bool isActive;
  final String syncTime;
  final IconData icon;
  final List<String> tags;
  final int batteryLevel; 

  DeviceModel(this.name, this.isActive, this.syncTime, this.icon, this.tags, this.batteryLevel);
}

class ManageDevicesPage extends StatefulWidget {
  const ManageDevicesPage({super.key});

  @override
  State<ManageDevicesPage> createState() => _ManageDevicesPageState();
}

class _ManageDevicesPageState extends State<ManageDevicesPage> {
  final Color userBlue = const Color(0xFF5A84F1);

  // Live state list of devices
  List<DeviceModel> devices = [
    DeviceModel("Apple Watch S8", true, "Last Sync: 1 Minute Ago", Icons.watch_rounded, ["Steps", "Heart Rate", "Calories"], 82),
    DeviceModel("Oura Ring Gen3", true, "Last Sync: 5 Minutes Ago", Icons.radio_button_unchecked_rounded, ["Sleep", "Heart Rate"], 45),
    DeviceModel("Fitbit Aria Scale", false, "Last Connected: 3 Days Ago", Icons.monitor_weight_rounded, ["Weight Data"], 12),
  ];

  void _toggleDeviceStatus(int index) {
    setState(() {
      devices[index].isActive = !devices[index].isActive;
      // Sort so active devices bubble to the top
      devices.sort((a, b) => b.isActive ? 1 : -1); 
    });
  }

  void _addNewDevice(String name, List<String> tags) {
    setState(() {
      devices.insert(0, DeviceModel(name, true, "Last Sync: Just Now", Icons.devices_other_rounded, tags, 100));
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final textPrimary = Theme.of(context).colorScheme.onSurface;
    final textSecondary = isDark ? Colors.white54 : Colors.grey.shade600;
    final dividerColor = Theme.of(context).dividerColor;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ==========================================
              // PREMIUM SLIVER APP BAR (Matches Settings)
              // ==========================================
              SliverAppBar(
                backgroundColor: userBlue,
                expandedHeight: 200.0,
                toolbarHeight: 70.0,
                pinned: true,
                elevation: 0,
                scrolledUnderElevation: 0.0,
                surfaceTintColor: Colors.transparent,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 15.0, top: 10.0),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(30, 60, 30, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text("Manage", style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: "LexendExaNormal", letterSpacing: -0.5, height: 1.1)),
                          Text("Devices.", style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: "LexendExaNormal", letterSpacing: -0.5, height: 1.1)),
                        ],
                      ),
                    ),
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(30),
                  child: Transform.translate(
                    offset: const Offset(0, 1),
                    child: Container(height: 31, width: double.infinity, decoration: BoxDecoration(color: bgColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(40)))),
                  ),
                ),
              ),

              // ==========================================
              // MAIN DEVICE LIST
              // ==========================================
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("CONNECTED HARDWARE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: textSecondary, letterSpacing: 1.5, fontFamily: "LexendExaNormal")),
                      const SizedBox(height: 15),

                      ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: devices.length,
                        itemBuilder: (context, index) {
                          return _buildDeviceCard(devices[index], index, surfaceColor, textPrimary, textSecondary, dividerColor, isDark);
                        },
                      ),
                      
                      const SizedBox(height: 120), // Padding for the floating button
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ==========================================
          // FLOATING "ADD NEW DEVICE" BUTTON
          // ==========================================
          Positioned(
            bottom: 30, left: 25, right: 25,
            child: ElevatedButton(
              onPressed: () => _showAddDeviceSheet(surfaceColor, textPrimary, textSecondary, dividerColor, isDark),
              style: ElevatedButton.styleFrom(
                backgroundColor: userBlue,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 10, shadowColor: userBlue.withValues(alpha:0.4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 22),
                  SizedBox(width: 8),
                  Text("Connect New Device", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15, fontFamily: "LexendExaNormal")),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- DEVICE CARD ---
  Widget _buildDeviceCard(DeviceModel device, int index, Color surfaceColor, Color textPrimary, Color textSecondary, Color dividerColor, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: device.isActive ? userBlue.withValues(alpha:0.5) : dividerColor, width: device.isActive ? 2 : 1),
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha:0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: () => _showDeviceDetailsSheet(device, index, surfaceColor, textPrimary, textSecondary, dividerColor, isDark),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.grey.shade100, shape: BoxShape.circle),
                  child: Icon(device.icon, size: 28, color: device.isActive ? userBlue : textSecondary),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(device.name, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: textPrimary)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.circle, size: 8, color: device.isActive ? Colors.green : Colors.redAccent),
                          const SizedBox(width: 4),
                          Text(device.isActive ? "Active Sync" : "Disconnected", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: textSecondary)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(device.syncTime, style: TextStyle(fontSize: 10, color: textSecondary, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: textSecondary.withValues(alpha:0.5), size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // ACTION 1: DEEP DEVICE DETAILS SHEET
  // ==========================================
  void _showDeviceDetailsSheet(DeviceModel device, int index, Color surfaceColor, Color textPrimary, Color textSecondary, Color dividerColor, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(color: surfaceColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(35))),
        padding: const EdgeInsets.fromLTRB(25, 10, 25, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 25), decoration: BoxDecoration(color: dividerColor, borderRadius: BorderRadius.circular(10)))),
            
            // Header: Icon, Name, and Battery
            Row(
              children: [
                CircleAvatar(radius: 30, backgroundColor: isDark ? Colors.white10 : Colors.grey.shade100, child: Icon(device.icon, size: 30, color: textPrimary)),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(device.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: textPrimary, fontFamily: "LexendExaNormal")),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            device.batteryLevel > 20 ? Icons.battery_full_rounded : Icons.battery_alert_rounded, 
                            size: 14, color: device.batteryLevel > 20 ? Colors.green : Colors.redAccent
                          ),
                          const SizedBox(width: 4),
                          Text("${device.batteryLevel}% Battery", style: TextStyle(fontSize: 12, color: textSecondary, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // Permissions / Connected Metrics
            Text("PERMISSIONS GRANTED", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: textSecondary, letterSpacing: 1.5, fontFamily: "LexendExaNormal")),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: device.tags.map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: userBlue.withValues(alpha:0.1), borderRadius: BorderRadius.circular(10)),
                child: Text(tag, style: TextStyle(color: userBlue, fontWeight: FontWeight.bold, fontSize: 11)),
              )).toList(),
            ),
            const SizedBox(height: 30),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _toggleDeviceStatus(index);
                    },
                    icon: Icon(device.isActive ? Icons.power_off_rounded : Icons.power_rounded, color: device.isActive ? Colors.redAccent : Colors.white, size: 18),
                    label: Text(device.isActive ? "Disconnect" : "Reconnect", style: TextStyle(color: device.isActive ? Colors.redAccent : Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: device.isActive ? Colors.redAccent.withValues(alpha:0.1) : Colors.green,
                      elevation: 0, padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: device.isActive ? BorderSide(color: Colors.redAccent.withValues(alpha:0.3)) : BorderSide.none),
                    ),
                  ),
                ),
                if (device.isActive) const SizedBox(width: 15),
                if (device.isActive)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Force syncing ${device.name}..."), backgroundColor: userBlue, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))));
                      },
                      icon: const Icon(Icons.sync_rounded, color: Colors.white, size: 18),
                      label: const Text("Sync Now", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(backgroundColor: userBlue, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                    ),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // ==========================================
  // ACTION 2: ADD NEW DEVICE FLOW
  // ==========================================
  void _showAddDeviceSheet(Color surfaceColor, Color textPrimary, Color textSecondary, Color dividerColor, bool isDark) {
    String selectedService = "Google Health Connect";
    final TextEditingController nameController = TextEditingController();
    final List<String> selectedData = [];
    final List<String> availableData = ["Heart Rate", "Steps", "Glucose Level", "Calories", "Hearing Data", "Sleep", "Weight"];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
          
          return Container(
            decoration: BoxDecoration(color: surfaceColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(35))),
            padding: EdgeInsets.fromLTRB(25, 10, 25, 30 + bottomPadding),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 25), decoration: BoxDecoration(color: dividerColor, borderRadius: BorderRadius.circular(10)))),
                  
                  Text("Connect Provider", style: TextStyle(color: textPrimary, fontSize: 24, fontWeight: FontWeight.w900, fontFamily: "LexendExaNormal")),
                  Text("Link your wearable or health service.", style: TextStyle(color: textSecondary, fontSize: 13)),
                  const SizedBox(height: 25),
                  
                  Row(
                    children: [
                      Expanded(child: _buildServiceBtn("Health Connect", Icons.favorite_rounded, selectedService == "Google Health Connect", () => setModalState(() => selectedService = "Google Health Connect"), isDark, textPrimary, dividerColor)),
                      const SizedBox(width: 15),
                      Expanded(child: _buildServiceBtn("Apple Health", Icons.apple_rounded, selectedService == "Apple Health", () => setModalState(() => selectedService = "Apple Health"), isDark, textPrimary, dividerColor)),
                    ],
                  ),
                  const SizedBox(height: 25),
                  
                  TextField(
                    controller: nameController,
                    style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      filled: true, fillColor: isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade100,
                      hintText: "E.g., My Fitbit Charge 5", hintStyle: TextStyle(color: textSecondary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                  ),
                  const SizedBox(height: 25),

                  Text("Allow access to:", style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  
                  Wrap(
                    spacing: 10, runSpacing: 10,
                    children: availableData.map((data) {
                      final isSelected = selectedData.contains(data);
                      return ChoiceChip(
                        label: Text(data, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: isSelected ? Colors.white : textPrimary)),
                        selected: isSelected,
                        selectedColor: userBlue,
                        backgroundColor: isDark ? Colors.white10 : Colors.grey.shade100,
                        showCheckmark: false,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
                        onSelected: (selected) {
                          setModalState(() {
                            selected ? selectedData.add(data) : selectedData.remove(data);
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 35),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (nameController.text.isEmpty || selectedData.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a name and select at least one data type."), backgroundColor: Colors.redAccent));
                          return;
                        }
                        Navigator.pop(context);
                        _addNewDevice(nameController.text, selectedData);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade500, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                      child: const Text("Authorize & Connect", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900, fontFamily: "LexendExaNormal")),
                    ),
                  )
                ],
              ),
            ),
          );
        }
      ),
    );
  }

  Widget _buildServiceBtn(String label, IconData icon, bool isSelected, VoidCallback onTap, bool isDark, Color textPrimary, Color dividerColor) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 110,
        decoration: BoxDecoration(
          color: isSelected ? userBlue.withValues(alpha:0.1) : (isDark ? const Color(0xFF2C2C2E) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? userBlue : dividerColor, width: isSelected ? 2 : 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 35, color: isSelected ? userBlue : textPrimary),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center, style: TextStyle(color: isSelected ? userBlue : textPrimary, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}