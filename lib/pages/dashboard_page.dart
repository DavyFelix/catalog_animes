import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Nenhum usuário logado")),
      );
    }

    final docRef =
        FirebaseFirestore.instance.collection("users").doc(user.uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
      ),
      body: StreamBuilder(
        stream: docRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() ?? {};

          final name = data["name"] ?? user.email;
          final photo = data["photoUrl"];
          final status = data["status"] ?? "offline";

          Color statusColor = Colors.grey;

          switch (status) {
            case "online":
              statusColor = Colors.green;
              break;
            case "away":
              statusColor = Colors.orange;
              break;
            case "offline":
              statusColor = Colors.red;
              break;
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundImage:
                          photo != null ? NetworkImage(photo) : null,
                      child: photo == null
                          ? const Icon(Icons.person, size: 30)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: Theme.of(context).textTheme.titleLarge),
                        Row(
                          children: [
                            Icon(Icons.circle, color: statusColor, size: 12),
                            const SizedBox(width: 6),
                            Text(status),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: () async {
                    await docRef.update({"status": "online"});
                  },
                  child: const Text("Ficar Online"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await docRef.update({"status": "away"});
                  },
                  child: const Text("Ausente"),
                ),
                ElevatedButton(
                  onPressed: () async {
                  await docRef.update({"status": "offline"});
                  },
                  child: const Text("Offline"),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
