// Fungsi untuk ambil total poin dari API
Future<int?> fetchTotalPoints() async {
  final userData = await AuthService().getCurrentUser();
  final userId = userData?['id'];

  if (userId == null) return null;
  String baseUrl = dotenv.env['BASE_URL'] ?? 'https://default-url.com';
  final url = Uri.parse('$baseUrl/users/poin/$userId');
  print(url);

  try {
    final response = await http.get(url);
    print(response.body);  
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['total_points'];
    } else {
      print("Gagal fetch data, status: ${response.statusCode}");
      return null;
    }
  } catch (e) {
    print("Error saat fetch poin: $e");
    return null;
  }
}

Widget _buildActionButtons() {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
    child: Row(
      children: [
        Padding(
          padding: EdgeInsets.only(right: 16, top: 8),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DataPemintaanDarah()),
                  );
                },
                child: Icon(
                  Icons.account_balance_wallet,
                  color: AppTheme.brand_02,
                  size: 30,
                ),
              ),
              SizedBox(height: 4),
              FutureBuilder<int?>(
                future: fetchTotalPoints(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  } else if (snapshot.hasError) {
                    return Text("Error");
                  } else if (!snapshot.hasData || snapshot.data == null) {
                    return Text("0 Poin");
                  }

                  return Text(
                    '${snapshot.data} Poin',
                    style: TextStyle(
                      color: AppTheme.brand_02,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        ActionButton(
          text: 'Minta Darah',
          color: AppTheme.brand_01,
          textColor: Colors.white,
          icon: Icons.water_drop,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DataPemintaanDarah()),
            );
          },
        ),
        SizedBox(width: 12),
        ActionButton(
          text: 'Donor Darah',
          color: AppTheme.brand_03,
          textColor: Colors.white,
          icon: Icons.local_hospital,
          onPressed: () {
            SharedPreferences.getInstance().then((prefs) {
              prefs.setInt('selectedIndex', 1);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => MainScreen()),
                    (route) => false,
              );
            });
          },
          isOutlined: false,
        ),
      ],
    ),
  );
}