import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> notifications = [
      {
        'title': 'Hoş Geldin!',
        'body': 'Filmistik ailesine katıldığın için teşekkürler.',
        'time': 'Az önce',
      },
      {
        'title': 'Yeni Özellik',
        'body': 'Artık IMDb puanlarını gerçek zamanlı görebilirsin.',
        'time': '1 saat önce',
      },
      {
        'title': 'Film Önerisi',
        'body': 'Bu hafta "Interstellar" filmini izledin mi?',
        'time': 'Dün',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0F111D),
      appBar: AppBar(
        title: const Text(
          "Bildirimler",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0F111D),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Text("Bildirim yok", style: TextStyle(color: Colors.grey)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F2232),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notifications[index]['title']!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notifications[index]['body']!,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        notifications[index]['time']!,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
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
