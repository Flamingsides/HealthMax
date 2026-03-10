import 'package:flutter/material.dart';
import 'package:healthmax_frontend/GeneralPages/helper_widgets.dart';

class RegistrationQuestions extends StatelessWidget {
  final int numQuestions;
  final int currentIndex;
  final List<Widget>? children;
  const RegistrationQuestions({
    super.key,
    required this.numQuestions,
    required this.currentIndex,
    this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Screen(
      bgDecoration: bgWhite,
      child: ListView(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(50, 0, 50, 0),
            child: ProgressBar(current: currentIndex, countBars: numQuestions),
          ),
          ...children ?? [],
        ],
      ),
    );
  }
}

class GenderCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final UserAnswers userAnswers;
  final String selectedGender;
  final void Function(String) setSelectedGender;

  const GenderCard({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.userAnswers,
    required this.selectedGender,
    required this.setSelectedGender,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withAlpha(30),
      borderRadius: BorderRadius.circular(50),
      child: InkWell(
        onTap: () {
          setSelectedGender(label);
          userAnswers.gender = label.toLowerCase();
          print("$label selected.");
        },
        borderRadius: BorderRadius.circular(50),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            border: selectedGender == label
                ? BoxBorder.all(color: color, width: 3)
                : null,
          ),
          padding: EdgeInsets.fromLTRB(10, 30, 10, 30),
          child: Column(
            children: [
              Icon(icon, size: 150, color: color),
              Text(
                label,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  fontFamily: "LexendExaNormal",
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// The following class will keep track of the user's
// answers to each question
class UserAnswers {
  String? gender;
  DateTime? dob;
  double? weight;
  String? weightUnit;
  double? height;
  String? heightUnit;

  UserAnswers({
    this.gender,
    this.dob,
    this.weight,
    this.weightUnit,
    this.height,
    this.heightUnit,
  });
}

class RegistrationGender extends StatefulWidget {
  const RegistrationGender({super.key});

  @override
  State<RegistrationGender> createState() => _RegistrationGenderState();
}

class _RegistrationGenderState extends State<RegistrationGender> {
  String? selectedGender;
  UserAnswers userAnswers = UserAnswers();
  void setSelectedGender(String gender) {
    setState(() => selectedGender = gender);
  }

  @override
  Widget build(BuildContext context) {
    return RegistrationQuestions(
      numQuestions: 4,
      currentIndex: 0,
      children: [
        const SizedBox(height: 100),
        Text(
          "Select your Gender",
          style: TextStyle(
            color: Colors.black,
            fontSize: 25,
            fontWeight: FontWeight.bold,
            fontFamily: "LexendExaNormal",
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 100),
        Row(
          spacing: 10,
          children: [
            Expanded(
              child: GenderCard(
                icon: Icons.male,
                color: Colors.lightBlueAccent,
                label: "Male",
                userAnswers: userAnswers,
                selectedGender: selectedGender ?? "None",
                setSelectedGender: setSelectedGender,
              ),
            ),
            Expanded(
              child: GenderCard(
                icon: Icons.female,
                label: "Female",
                color: Colors.purpleAccent,
                userAnswers: userAnswers,
                selectedGender: selectedGender ?? "None",
                setSelectedGender: setSelectedGender,
              ),
            ),
          ],
        ),
        const SizedBox(height: 100),
        CustomButton(
          label: "Next",
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RegistrationDOB(userAnswers: userAnswers),
              ),
            );
          },
        ),
      ],
    );
  }
}

class EnterDOBWidget extends StatefulWidget {
  const EnterDOBWidget({super.key});

  @override
  State<EnterDOBWidget> createState() => _EnterDOBWidgetState();
}

class _EnterDOBWidgetState extends State<EnterDOBWidget> {
  DateTime selectedDate = DateTime.fromMillisecondsSinceEpoch(0);

  Future<void> getDate() async {
    DateTime curr = DateTime.now();
    DateTime date18YearsAgo = DateTime(curr.year - 18, curr.month, curr.day);

    DateTime? date = await showDatePicker(
      context: context,
      firstDate: DateTime.fromMillisecondsSinceEpoch(0),
      lastDate: date18YearsAgo,
    );

    if (date != null) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  String formatDate(DateTime date) {
    List<String> months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blueAccent.withAlpha(30),
        borderRadius: BorderRadius.circular(50),
      ),
      padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
      child: Column(
        children: [
          Text(
            formatDate(selectedDate),
            style: TextStyle(
              color: Colors.black,
              fontSize: 25,
              fontWeight: FontWeight.bold,
              fontFamily: "LexendExaNormal",
            ),
          ),
          const SizedBox(height: 80),
          TextButton(
            onPressed: () => getDate(),
            style: ButtonStyle(
              padding: WidgetStateProperty.all(EdgeInsets.all(10)),
            ),
            child: Text("Choose date", style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
  }
}

class RegistrationDOB extends StatelessWidget {
  final UserAnswers userAnswers;
  const RegistrationDOB({super.key, required this.userAnswers});

  @override
  Widget build(BuildContext context) {
    return RegistrationQuestions(
      numQuestions: 4,
      currentIndex: 1,
      children: [
        const SizedBox(height: 100),
        Text(
          "Enter your date of birth",
          style: TextStyle(
            color: Colors.black,
            fontSize: 25,
            fontWeight: FontWeight.bold,
            fontFamily: "LexendExaNormal",
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 100),
        EnterDOBWidget(),
        const SizedBox(height: 100),
        CustomButton(
          label: "Next",
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RegistrationDOB(userAnswers: userAnswers),
              ),
            );
          },
        ),
      ],
    );
  }
}
