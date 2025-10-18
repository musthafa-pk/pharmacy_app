// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
// class EditDailyRoutine extends StatefulWidget {
//   const EditDailyRoutine({super.key});
//
//   @override
//   State<EditDailyRoutine> createState() => _EditDailyRoutineState();
// }
//
// class _EditDailyRoutineState extends State<EditDailyRoutine> {
//   static var getRoutine = 'http://13.232.117.141:3003/medone/getUserRoutine';
//   static var editRoutine = 'http://13.232.117.141:3003/medone/editroutine';
//
//   List<TimeOfDay> routineTimes = List.generate(6, (index) => TimeOfDay.now());
//   bool isLoading = true;
//
//   // List of image assets for each activity
//   final List<String> routineImages = [
//     'assets/images/doc.png',
//     'assets/images/doc.png',
//     'assets/images/doc.png',
//     'assets/images/doc.png',
//     'assets/images/doc.png',
//     'assets/images/doc.png',
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchRoutine();
//   }
//
//   Future<void> _fetchRoutine() async {
//     final url = Uri.parse(getRoutine);
//     try {
//       final response = await http.post(
//         url,
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({'userId': 1}),
//       );
//
//       if (response.statusCode == 200) {
//         final responseData = json.decode(response.body);
//         setState(() {
//           isLoading = false;
//           routineTimes = _parseRoutineTimes(responseData['data'][0]['routine'][0]);
//         });
//       } else {
//         setState(() {
//           isLoading = false;
//         });
//       }
//     } catch (error) {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
//   List<TimeOfDay> _parseRoutineTimes(Map<String, dynamic> routine) {
//     return [
//       _stringToTimeOfDay(routine['wakeUp']),
//       _stringToTimeOfDay(routine['exercise']),
//       _stringToTimeOfDay(routine['breakfast']),
//       _stringToTimeOfDay(routine['lunch']),
//       _stringToTimeOfDay(routine['dinner']),
//       _stringToTimeOfDay(routine['sleep']),
//     ];
//   }
//
//   TimeOfDay _stringToTimeOfDay(String timeString) {
//     final parts = timeString.split(' ');
//     final timeParts = parts[0].split(':');
//     final hour = int.parse(timeParts[0]);
//     final minute = int.parse(timeParts[1]);
//
//     if (parts[1] == 'PM' && hour != 12) {
//       return TimeOfDay(hour: hour + 12, minute: minute);
//     } else if (parts[1] == 'AM' && hour == 12) {
//       return TimeOfDay(hour: 0, minute: minute);
//     }
//     return TimeOfDay(hour: hour, minute: minute);
//   }
//
//   Future<void> _saveRoutine() async {
//     final url = Uri.parse(editRoutine);
//     final routineData = {
//       'userId': 1,
//       'routine': [
//         {
//           'wakeUp': routineTimes[0].format(context),
//           'exercise': routineTimes[1].format(context),
//           'breakfast': routineTimes[2].format(context),
//           'lunch': routineTimes[3].format(context),
//           'dinner': routineTimes[4].format(context),
//           'sleep': routineTimes[5].format(context),
//         },
//       ],
//     };
//
//     try {
//       final response = await http.post(
//         url,
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode(routineData),
//       );
//       if (response.statusCode == 200) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Routine updated successfully!')),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Failed to update routine.')),
//         );
//       }
//     } catch (error) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error saving routine: $error')),
//       );
//     }
//   }
//
//   Future<void> _selectTime(int index) async {
//     final picked = await showTimePicker(
//       context: context,
//       initialTime: routineTimes[index],
//     );
//
//     if (picked != null) {
//       setState(() {
//         routineTimes[index] = picked;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Edit Daily Routine', style: TextStyle(color: Colors.white)),
//         backgroundColor: Colors.blue,
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             ...List.generate(
//               routineTimes.length,
//                   (index) => Stack(
//                 children: [
//                   if (index != routineTimes.length - 1)
//                     Positioned(
//                       top: 48,
//                       left: 32,
//                       child: Container(
//                         height: 50,
//                         width: 2,
//                         color: Colors.blue,
//                       ),
//                     ),
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       CircleAvatar(
//                         backgroundColor: Colors.blue,
//                         radius: 20,
//                         backgroundImage: AssetImage(routineImages[index]),
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: GestureDetector(
//                           onTap: () => _selectTime(index),
//                           child: Card(
//                             color: Colors.blue.shade50,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: Padding(
//                               padding: const EdgeInsets.all(16),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     ['Wake Up', 'Exercise', 'Breakfast', 'Lunch', 'Dinner', 'Sleep'][index],
//                                     style: const TextStyle(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.blue,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 4),
//                                   Text(
//                                     routineTimes[index].format(context),
//                                     style: const TextStyle(
//                                       fontSize: 16,
//                                       color: Colors.black54,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _saveRoutine,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blue,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
//               ),
//               child: const Text(
//                 'Save Routine',
//                 style: TextStyle(fontSize: 18, color: Colors.white),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
