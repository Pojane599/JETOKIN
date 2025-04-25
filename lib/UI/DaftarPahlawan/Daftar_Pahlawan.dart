import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jetokin/NavBar/NavBar.dart';
import 'package:jetokin/UI/DaftarPahlawan/DetailTokohPage.dart';
import 'package:jetokin/NavBarProvider.dart';
import 'package:provider/provider.dart';

class HeroSearchScreenWithButton extends StatefulWidget {
  final String baseUrl; // Base URL API backend Flask
  final Map<String, dynamic> userData; // Data user yang sudah login

  const HeroSearchScreenWithButton({
    Key? key,
    required this.baseUrl,
    required this.userData,
  }) : super(key: key);

  @override
  _HeroSearchScreenWithButtonState createState() =>
      _HeroSearchScreenWithButtonState();
}

class _HeroSearchScreenWithButtonState
    extends State<HeroSearchScreenWithButton> {
  String searchQuery = '';
  String? selectedLetter;
  bool showGrid = false;
  bool isLoading = true;
  bool isGridView = false; // Tambahkan state untuk mode tampilan
  List<Map<String, dynamic>> heroes = [];
  int currentPage = 1; // Halaman aktif
  int totalPages = 1; // Total jumlah halaman
  String? selectedCategory; // Untuk menyimpan kategori yang dipilih
  String? selectedSubCategory; // Untuk menyimpan subkategori yang dipilih
  List<Map<String, dynamic>> subCategories = []; // Data subkategori dari API
  bool isSubCategoryLoading = false; // Status loading subkategori
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: searchQuery);
    fetchHeroes(currentPage);
  }

    @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCategoryOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pilihan Zaman Perjuangan
            ListTile(
              leading: const Icon(Icons.timeline, color: Colors.blue),
              title: const Text('Zaman Perjuangan'),
              onTap: () {
                Navigator.pop(context); // Tutup bottom sheet
                fetchSubCategories('Zaman Perjuangan'); // Panggil kategori ini
              },
            ),
            // Pilihan Asal Daerah
            ListTile(
              leading: const Icon(Icons.place, color: Colors.green),
              title: const Text('Asal Daerah'),
              onTap: () {
                Navigator.pop(context); // Tutup bottom sheet
                fetchSubCategories('Asal Daerah'); // Panggil kategori ini
              },
            ),
            // Pilihan Bidang Perjuangan
            ListTile(
              leading: const Icon(Icons.category, color: Colors.purple),
              title: const Text('Bidang Perjuangan'),
              onTap: () {
                Navigator.pop(context); // Tutup bottom sheet
                fetchSubCategories('Bidang Perjuangan'); // Panggil kategori ini
              },
            ),
          ],
        );
      },
    );
  }

  /// **Fetch Daftar Tokoh**
  Future<void> fetchHeroes(int page) async {
    setState(() {
      isLoading = true; // Menampilkan loading
    });

    try {
      final queryParams = {
        if (searchQuery.isNotEmpty) 'q': searchQuery,
        if (selectedLetter != null) 'letter': selectedLetter,
        'page': page.toString(),
        'per_page': '10', // Mengatur jumlah item per halaman
      };

      final uri = Uri.parse('${widget.baseUrl}/api/tokoh')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['tokoh_list'] is List) {
          setState(() {
            heroes = List<Map<String, dynamic>>.from(data['tokoh_list']);
            currentPage = data['current_page']; // Menyimpan halaman aktif
            totalPages = data['total_pages']; // Menyimpan total halaman
          });
        } else {
          throw Exception('Format data tidak valid');
        }
      } else {
        throw Exception('Gagal memuat pahlawan: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal memuat daftar pahlawan: $e"),
        ),
      );
    } finally {
      setState(() {
        isLoading = false; // Menyembunyikan loading
      });
    }
  }

  //-------Fungsi untuk Mengambil Data Subkategori:
  Future<void> fetchSubCategories(String category) async {
    setState(() {
      isSubCategoryLoading = true;
      selectedCategory = category;
      subCategories = [];
    });

    try {
      String groupBy = '';
      if (category == 'Zaman Perjuangan') {
        groupBy = 'zaman_perjuangan';
      } else if (category == 'Asal Daerah') {
        groupBy = 'provinsi';
      } else if (category == 'Bidang Perjuangan') {
        groupBy = 'bidang_perjuangan';
      }

      final uri = Uri.parse('${widget.baseUrl}/api/tokoh').replace(
        queryParameters: {'group_by': groupBy},
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          subCategories = List<Map<String, dynamic>>.from(data['data']);
        });

        // Tampilkan subkategori di bottom sheet
        _showSubCategoryOptions();
      } else {
        throw Exception('Gagal memuat data kategori');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => isSubCategoryLoading = false);
    }
  }

  //-----Fungsi untuk Mengambil Data Pahlawan Berdasarkan Subkategori
  Future<void> fetchHeroesBySubCategory(String value) async {
    setState(() {
      isLoading = true;
      selectedSubCategory = value;
      heroes = [];
    });

    try {
      String queryParam = '';
      if (selectedCategory == 'Zaman Perjuangan') {
        queryParam = 'zaman_perjuangan';
      } else if (selectedCategory == 'Asal Daerah') {
        queryParam = 'provinsi';
      } else if (selectedCategory == 'Bidang Perjuangan') {
        queryParam = 'bidang_perjuangan';
      }

      final uri = Uri.parse('${widget.baseUrl}/api/tokoh').replace(
        queryParameters: {queryParam: value},
      );

      print("URL: $uri"); // Debug log

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['tokoh_list'] is List) {
          setState(() {
            heroes = List<Map<String, dynamic>>.from(data['tokoh_list']);
          });
          print("Response status code: ${response.statusCode}");
          print("Response body: ${response.body}");

          if (data['tokoh_list'] is List) {
            setState(() {
              heroes = List<Map<String, dynamic>>.from(data['tokoh_list']);
            });
            print(
                "Heroes loaded: ${heroes.length}"); // Debug jumlah pahlawan yang diterima
          }
        } else {
          throw Exception('Format data tidak valid');
        }
      } else {
        throw Exception('Gagal memuat daftar pahlawan');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  //fungsi ini untuk menampilkan daftar subkategori setelah kategori utama dipilih
  void _showSubCategoryOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height *
              0.6, // Batasi tinggi bottom sheet
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Pilih Subkategori",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: subCategories.length,
                  itemBuilder: (context, index) {
                    final sub = subCategories[index];
                    final String subName =
                        selectedCategory == 'Zaman Perjuangan'
                            ? sub['zaman_perjuangan']
                            : selectedCategory == 'Asal Daerah'
                                ? sub['provinsi']
                                : sub['bidang_kategori'];
                    final int jumlah = sub['jumlah'];

                    return ListTile(
                      title: Text(subName),
                      trailing: Text('$jumlah'),
                      onTap: () {
                        Navigator.pop(context); // Tutup bottom sheet
                        fetchHeroesBySubCategory(
                            subName); // Panggil data berdasarkan subkategori
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Fungsi untuk mendapatkan nama file dari URL
  String extractFileName(String? url) {
    if (url == null || url.isEmpty)
      return "default.png"; // Jika URL kosong, gunakan default
    try {
      final uri = Uri.parse(url); // Parse URL
      return uri.pathSegments.last; // Ambil segmen terakhir (nama file)
    } catch (e) {
      print("Error parsing URL: $e");
      return "default.png"; // Fallback jika ada kesalahan
    }
  }

  /// **Render Gambar Tokoh**
  Widget _buildHeroImage(String? photoUrl) {
    // Ekstrak nama file
    final fileName = extractFileName(photoUrl);
    // Bangun URL lengkap
    final fullUrl = '${widget.baseUrl}/static/images/Pahlawan/$fileName';

    return CircleAvatar(
      radius: 25,
      backgroundImage: NetworkImage(fullUrl),
    );
  }

  /// Render Daftar Tokoh
  Widget _buildHeroList() {
    print("Building hero list with ${heroes.length} items");
    if (isGridView) {
      return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Jumlah kolom pada grid
          childAspectRatio: 1, // Gunakan 1 agar gambar lebih besar
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
        ),
        itemCount: heroes.length,
        itemBuilder: (context, index) {
          final hero = heroes[index];
          // Ekstrak nama file dari URL
          final fileName = extractFileName(hero["photo_url"]);
          // Bangun URL lengkap
          final fullUrl = '${widget.baseUrl}/static/images/Pahlawan/$fileName';

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HeroDetailScreen(
                    baseUrl: widget.baseUrl,
                    heroId: hero["id"],
                  ),
                ),
              );
            },
            child: Card(
              color:
                  const Color(0xFFFCFAEE), // Warna krem sama seperti search bar
              margin: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gambar penuh dalam grid
                  Expanded(
                    child: Image.network(
                      fullUrl, // URL gambar baru
                      fit: BoxFit.cover, // Mengatur gambar untuk memenuhi ruang
                      width: double.infinity, // Lebar penuh grid
                      height: double.infinity, // Tinggi penuh grid
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hero["name"] ?? "Nama tidak tersedia",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hero["peran_utama"] ?? "Peran tidak diketahui",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      return ListView.builder(
        itemCount: heroes.length,
        itemBuilder: (context, index) {
          final hero = heroes[index];
          // Ekstrak nama file dari URL
          final fileName = extractFileName(hero["photo_url"]);
          // Bangun URL lengkap
          final fullUrl = '${widget.baseUrl}/static/images/Pahlawan/$fileName';

          return Card(
            color:
                const Color(0xFFFCFAEE), // Warna krem sama seperti search bar
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage(fullUrl), // URL gambar baru
              ),
              title: Text(hero["name"] ?? "Nama tidak tersedia"),
              subtitle: Text(hero["peran_utama"] ?? "Peran tidak diketahui"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HeroDetailScreen(
                      baseUrl: widget.baseUrl,
                      heroId: hero["id"],
                    ),
                  ),
                );
              },
            ),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90), // Tinggi AppBar diperbesar
        child: AppBar(
          automaticallyImplyLeading: false, // Hilangkan tombol back
          backgroundColor: Colors.red, // Warna merah untuk AppBar
          flexibleSpace: Padding(
            padding: const EdgeInsets.fromLTRB(
                16.0, 40.0, 16.0, 10.0), // Atur padding
            child: Container(
              height: 50, // Tinggi search bar
              decoration: BoxDecoration(
                color: const Color(0xFFFCFAEE), // Warna krem untuk search bar
                borderRadius: BorderRadius.circular(30), // Sudut membulat penuh
                border: Border.all(
                  color: Colors.black, // Border hitam
                  width: 1.0,
                ),
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Icon(Icons.search,
                        color: Colors.black), // Ikon pencarian
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (query) {
                        setState(() => searchQuery = query);
                        fetchHeroes(currentPage);
                      },
                      decoration: const InputDecoration(
                        hintText: 'Siapa yang anda cari?',
                        hintStyle: TextStyle(color: Colors.black54),
                        border: InputBorder.none, // Hilangkan border default
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16.0),
          _buildSearchAndFilter(), // Button kategori dan lainnya
          if (showGrid) _buildAlphabetGrid(), // Grid berdasarkan huruf
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.red,
                    ),
                  )
                : _buildHeroList(),
          ),
          if (!isLoading && heroes.isNotEmpty) _buildPagination(),
        ],
      ),
      bottomNavigationBar: const NavBar(),
    );
  }

  Widget _buildPagination() {
    return Container(
      color: const Color.fromARGB(255, 255, 0, 0), // Latar belakang merah penuh
      padding: const EdgeInsets.symmetric(
          vertical: 12.0), // Padding untuk jarak vertikal
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal, // Mengaktifkan scroll horizontal
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tombol untuk setiap halaman
            Row(
              children: List.generate(totalPages, (index) {
                int pageIndex = index + 1;
                return GestureDetector(
                  onTap: () {
                    if (pageIndex != currentPage) {
                      fetchHeroes(pageIndex); // Memuat halaman yang dipilih
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6.0),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: pageIndex == currentPage
                          ? Colors.white
                          : Colors
                              .red[400], // Warna tombol aktif dan tidak aktif
                      borderRadius: BorderRadius.circular(
                          10), // Membuat tombol persegi dengan sudut membulat
                      border: pageIndex == currentPage
                          ? Border.all(
                              color: Colors
                                  .blue, // Warna border biru untuk tombol aktif
                              width: 2.0,
                            )
                          : null,
                    ),
                    child: Text(
                      '$pageIndex',
                      style: TextStyle(
                        color: pageIndex == currentPage
                            ? Colors.blue
                            : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Button Pilih Berdasarkan Huruf dan Kategori
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFCFAEE), // Warna krem
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colors.black), // Border hitam
                    borderRadius:
                        BorderRadius.circular(30), // Sudut membulat penuh
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30, vertical: 12), // Atur ukuran tombol
                ),
                onPressed: () {
                  setState(() => showGrid = !showGrid);
                },
                child: const Text(
                  'Pilih Berdasarkan Huruf',
                  style: TextStyle(
                    color: Colors.black, // Warna teks hitam
                    fontSize: 14,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFCFAEE), // Warna krem
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: Colors.black), // Border hitam
                    borderRadius:
                        BorderRadius.circular(30), // Sudut membulat penuh
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 45, vertical: 12), // Atur ukuran tombol
                ),
                onPressed: _showCategoryOptions,
                child: const Text(
                  'Kategori',
                  style: TextStyle(
                    color: Colors.black, // Warna teks hitam
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Dropdown Pilihan Tampilan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Tampilan",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.normal, // Tidak terlalu tebal
                ),
              ),
              DropdownButton<String>(
                value: isGridView ? "GridView" : "ListView",
                underline: Container(), // Hilangkan garis bawah
                items: const [
                  DropdownMenuItem(
                    value: "ListView",
                    child: Text("Daftar"),
                  ),
                  DropdownMenuItem(
                    value: "GridView",
                    child: Text("Bingkai"),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    isGridView = value == "GridView";
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlphabetGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Wrap(
        spacing: 12.0,
        runSpacing: 12.0,
        children: List.generate(26, (index) {
          final letter = String.fromCharCode(65 + index);
          return GestureDetector(
            onTap: () {
              setState(() => selectedLetter = letter);
              fetchHeroes(currentPage);
            },
            child: Container(
              width: 50,
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selectedLetter == letter ? Colors.blue : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey),
              ),
              child: Text(
                letter,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
