import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; 
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme_provider.dart';
import '../GeneralPages/health_providers.dart';

class DeviceModel {
  final String id; final String name; bool isActive; final String syncTime; final IconData icon; final List<String> tags; final int batteryLevel; 
  DeviceModel({required this.id, required this.name, required this.isActive, required this.syncTime, required this.icon, required this.tags, required this.batteryLevel});
}

class ManageDevicesPage extends StatefulWidget {
  const ManageDevicesPage({super.key});
  @override
  State<ManageDevicesPage> createState() => _ManageDevicesPageState();
}

class _ManageDevicesPageState extends State<ManageDevicesPage> {
  final Color userBlue = const Color(0xFF5A84F1);
  List<DeviceModel> devices = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDevicesFromDatabase();
  }

  Future<void> _fetchDevicesFromDatabase() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final response = await supabase.from('user_devices').select().eq('user_id', user.id).order('created_at', ascending: false);
      final List<DeviceModel> loadedDevices = [];
      for (var row in response) {
        loadedDevices.add(DeviceModel(
          id: row['id'], name: row['device_name'], isActive: row['is_active'], syncTime: "Just Now", 
          icon: Icons.devices_other_rounded, tags: List<String>.from(row['permissions_granted'] ?? []), batteryLevel: row['battery_level'] ?? 100,
        ));
      }
      if (mounted) setState(() { devices = loadedDevices; isLoading = false; });
    } catch (e) { if (mounted) setState(() => isLoading = false); }
  }

  Future<void> _addNewDevice(String name, List<String> tags) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final response = await supabase.from('user_devices').insert({
        'user_id': user.id, 'device_name': name, 'is_active': true, 'battery_level': 100, 'permissions_granted': tags,
      }).select().single();

      if (mounted) {
        setState(() {
          devices.insert(0, DeviceModel(id: response['id'], name: name, isActive: true, syncTime: "Just Now", icon: Icons.devices_other_rounded, tags: tags, batteryLevel: 100));
        });
        
        context.read<HealthProvider>().checkDeviceAndStartMock();
      }
    } catch (e) { 
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to save device: $e"), backgroundColor: Colors.redAccent)); 
    }
  }

  Future<void> _toggleDeviceStatus(int index) async {
    final device = devices[index];
    final newStatus = !device.isActive;
    setState(() { devices[index].isActive = newStatus; devices.sort((a, b) => b.isActive ? 1 : -1); });

    try { 
        await Supabase.instance.client.from('user_devices').update({'is_active': newStatus}).eq('id', device.id); 
        if (mounted) context.read<HealthProvider>().checkDeviceAndStartMock();
    } 
    catch (e) { setState(() { devices[index].isActive = !newStatus; }); }
  }

  // --- NEW: Remove Device Logic ---
  Future<void> _removeDevice(int index) async {
    final device = devices[index];
    setState(() { devices.removeAt(index); });
    
    try {
      await Supabase.instance.client.from('user_devices').delete().eq('id', device.id);
      if (mounted) context.read<HealthProvider>().checkDeviceAndStartMock();
    } catch(e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to remove device: $e"), backgroundColor: Colors.redAccent)); 
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final isDark = theme.isDarkMode;
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
              SliverAppBar(
                backgroundColor: userBlue,
                expandedHeight: 200.0, toolbarHeight: 70.0, pinned: true, elevation: 0, scrolledUnderElevation: 0.0, surfaceTintColor: Colors.transparent,
                leading: Padding(padding: const EdgeInsets.only(left: 15.0, top: 10.0), child: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22), onPressed: () => Navigator.pop(context))),
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(30, 60, 30, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(theme.translate('manage'), style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: "LexendExaNormal", letterSpacing: -0.5, height: 1.1)),
                          Text("${theme.translate('device')}s.", style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: "LexendExaNormal", letterSpacing: -0.5, height: 1.1)),
                        ],
                      ),
                    ),
                  ),
                ),
                bottom: PreferredSize(preferredSize: const Size.fromHeight(30), child: Transform.translate(offset: const Offset(0, 1), child: Container(height: 31, width: double.infinity, decoration: BoxDecoration(color: bgColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(40)))))),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(theme.translate('connected_devices').toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: textSecondary, letterSpacing: 1.5, fontFamily: "LexendExaNormal")),
                      const SizedBox(height: 15),

                      if (isLoading)
                        const Padding(padding: EdgeInsets.all(40.0), child: Center(child: CircularProgressIndicator()))
                      else if (devices.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Center(child: Text(theme.translate('No devices connected yet.'), textAlign: TextAlign.center, style: TextStyle(color: textSecondary, height: 1.5))),
                        )
                      else
                        ListView.builder(
                          padding: EdgeInsets.zero, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: devices.length,
                          itemBuilder: (context, index) { return _buildDeviceCard(devices[index], index, surfaceColor, textPrimary, textSecondary, dividerColor, isDark, theme); },
                        ),
                      const SizedBox(height: 120), 
                    ],
                  ),
                ),
              ),
            ],
          ),

          Positioned(
            bottom: 30, left: 25, right: 25,
            child: ElevatedButton(
              onPressed: () => _showAddDeviceSheet(surfaceColor, textPrimary, textSecondary, dividerColor, isDark, theme),
              style: ElevatedButton.styleFrom(backgroundColor: userBlue, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 10, shadowColor: userBlue.withValues(alpha:0.4)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 22), const SizedBox(width: 8), Text("${theme.translate('connect')} ${theme.translate('device')}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15, fontFamily: "LexendExaNormal"))],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(DeviceModel device, int index, Color surfaceColor, Color textPrimary, Color textSecondary, Color dividerColor, bool isDark, ThemeProvider theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(25), border: Border.all(color: device.isActive ? userBlue.withValues(alpha:0.5) : dividerColor, width: device.isActive ? 2 : 1), boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha:0.03), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: () => _showDeviceDetailsSheet(device, index, surfaceColor, textPrimary, textSecondary, dividerColor, isDark, theme), // UPDATED!
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.grey.shade100, shape: BoxShape.circle), child: Icon(device.icon, size: 28, color: device.isActive ? userBlue : textSecondary)),
                const SizedBox(width: 15),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(device.name, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: textPrimary)), const SizedBox(height: 4), Row(children: [Icon(Icons.circle, size: 8, color: device.isActive ? Colors.green : Colors.redAccent), const SizedBox(width: 4), Text(device.isActive ? theme.translate('live_syncing') : theme.translate('status_quiet'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: textSecondary))])])),
                Icon(Icons.arrow_forward_ios_rounded, color: textSecondary.withValues(alpha: 0.5), size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- NEW: THE DETAILS BOTTOM SHEET ---
  void _showDeviceDetailsSheet(DeviceModel device, int index, Color surfaceColor, Color textPrimary, Color textSecondary, Color dividerColor, bool isDark, ThemeProvider theme) {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(color: surfaceColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(35))), padding: const EdgeInsets.fromLTRB(25, 10, 25, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 25), decoration: BoxDecoration(color: dividerColor, borderRadius: BorderRadius.circular(10)))),
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
                          Icon(device.batteryLevel > 20 ? Icons.battery_full_rounded : Icons.battery_alert_rounded, size: 14, color: device.batteryLevel > 20 ? Colors.green : Colors.redAccent),
                          const SizedBox(width: 4),
                          Text("${device.batteryLevel}% Battery", style: TextStyle(fontSize: 12, color: textSecondary, fontWeight: FontWeight.bold))
                        ]
                      )
                    ]
                  )
                )
              ]
            ),
            const SizedBox(height: 25),
            Text(theme.translate('select_data_accessed').toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: textSecondary, letterSpacing: 1.5, fontFamily: "LexendExaNormal")),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: device.tags.map((tag) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: userBlue.withValues(alpha:0.1), borderRadius: BorderRadius.circular(10)), child: Text(theme.translate(tag), style: TextStyle(color: userBlue, fontWeight: FontWeight.bold, fontSize: 11)))).toList()
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () { Navigator.pop(context); _removeDevice(index); },
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                    label: Text(theme.translate('remove'), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent.withValues(alpha:0.1), elevation: 0, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  )
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () { Navigator.pop(context); _toggleDeviceStatus(index); },
                    icon: Icon(device.isActive ? Icons.power_settings_new_rounded : Icons.power_rounded, color: Colors.white, size: 18),
                    label: Text(device.isActive ? "Disable" : "Enable", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: device.isActive ? Colors.orange.shade400 : Colors.green.shade500, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  )
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _showAddDeviceSheet(Color surfaceColor, Color textPrimary, Color textSecondary, Color dividerColor, bool isDark, ThemeProvider theme) {
    String selectedService = "Google Health Connect";
    final TextEditingController nameController = TextEditingController();
    final List<String> selectedData = [];
    final List<String> availableData = ["Heart Rate", "Steps", "Blood Glucose", "Calories", "Env. Noise"];

    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
          return Container(
            decoration: BoxDecoration(color: surfaceColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(35))), padding: EdgeInsets.fromLTRB(25, 10, 25, 30 + bottomPadding),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 25), decoration: BoxDecoration(color: dividerColor, borderRadius: BorderRadius.circular(10)))),
                  Text("${theme.translate('connect')} Provider", style: TextStyle(color: textPrimary, fontSize: 24, fontWeight: FontWeight.w900, fontFamily: "LexendExaNormal")),
                  const SizedBox(height: 25),
                  Row(children: [Expanded(child: _buildServiceBtn("Health Connect", Icons.favorite_rounded, selectedService == "Google Health Connect", () => setModalState(() => selectedService = "Google Health Connect"), isDark, textPrimary, dividerColor)), const SizedBox(width: 15), Expanded(child: _buildServiceBtn("Apple Health", Icons.apple_rounded, selectedService == "Apple Health", () => setModalState(() => selectedService = "Apple Health"), isDark, textPrimary, dividerColor))]),
                  const SizedBox(height: 25),
                  TextField(controller: nameController, style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600), decoration: InputDecoration(filled: true, fillColor: isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade100, hintText: theme.translate('Device Name'), hintStyle: TextStyle(color: textSecondary), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15))),
                  const SizedBox(height: 25),
                  Text(theme.translate('select_data_accessed'), style: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(spacing: 10, runSpacing: 10, children: availableData.map((data) { final isSelected = selectedData.contains(data); return ChoiceChip(label: Text(theme.translate(data), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: isSelected ? Colors.white : textPrimary)), selected: isSelected, selectedColor: userBlue, backgroundColor: isDark ? Colors.white10 : Colors.grey.shade100, showCheckmark: false, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none), onSelected: (selected) { setModalState(() { selected ? selectedData.add(data) : selectedData.remove(data); }); }); }).toList()),
                  const SizedBox(height: 35),
                  SizedBox(width: double.infinity, child: ElevatedButton(
                    onPressed: () { 
                      if (nameController.text.isEmpty || selectedData.isEmpty) return; 
                      Navigator.pop(context); 
                      _addNewDevice(nameController.text, selectedData); 
                    }, 
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade500, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))), 
                    child: Text(theme.translate('connect'), style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900, fontFamily: "LexendExaNormal"))
                  ))
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
        duration: const Duration(milliseconds: 200), height: 110,
        decoration: BoxDecoration(color: isSelected ? userBlue.withValues(alpha:0.1) : (isDark ? const Color(0xFF2C2C2E) : Colors.white), borderRadius: BorderRadius.circular(20), border: Border.all(color: isSelected ? userBlue : dividerColor, width: isSelected ? 2 : 1)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, size: 35, color: isSelected ? userBlue : textPrimary), const SizedBox(height: 8), Text(label, textAlign: TextAlign.center, style: TextStyle(color: isSelected ? userBlue : textPrimary, fontSize: 11, fontWeight: FontWeight.bold))]),
      ),
    );
  }
}