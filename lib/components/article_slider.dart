import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticleSlider extends StatefulWidget {
  final List<ArticleData> articles;

  const ArticleSlider({
    super.key,
    required this.articles,
  });

  @override
  State<ArticleSlider> createState() => _ArticleSliderState();
}

class _ArticleSliderState extends State<ArticleSlider> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: SizedBox(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.2,
        child: Stack(
          children: [
            // PageView untuk slider
            PageView.builder(
              controller: _pageController,
              itemCount: widget.articles.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return _buildArticleItem(widget.articles[index]);
              },
            ),

            // Indikator halaman
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.articles.length,
                      (index) => _buildDotIndicator(index),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleItem(ArticleData article) {
    return GestureDetector(
      onTap: () async {
        final Uri url = Uri.parse(article.articleUrl);

        if (await canLaunchUrl(url)) {
          await launchUrl(
            url,
            mode: LaunchMode.externalApplication,
          );
        } else {
        }
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(article.imageUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.1),
                Colors.black.withValues(alpha: 0.7),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                article.title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              Text(
                article.preview,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDotIndicator(int index) {
    return Container(
      width: 8,
      height: 8,
      margin: EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _currentPage == index
            ? Colors.white
            : Colors.white.withValues(alpha: 0.5),
      ),
    );
  }
}

// Model data untuk artikel
class ArticleData {
  final String imageUrl;
  final String title;
  final String preview;
  final String articleUrl;

  ArticleData({
    required this.imageUrl,
    required this.title,
    required this.preview,
    required this.articleUrl,
  });
}

// Contoh penggunaan:
Widget buildArticleSlider() {
  final List<ArticleData> articles = [
    ArticleData(
      imageUrl: 'https://mysiloam-api.siloamhospitals.com/public-asset/website-cms/website-cms-16927582754302106.webp',
      title: 'Ketahui Prosedur Donor Darah dan Manfaatnya bagi Tubuh',
      preview: 'Perlu diketahui bahwa tidak semua orang bisa melakukan donor darah. Adapun beberapa syarat yang perlu dipenuhi untuk melakukan donor darah adalah sebagai berikut...',
      articleUrl: 'https://www.siloamhospitals.com/informasi-siloam/artikel/mengenal-prosedur-donor-darah',
    ),
    ArticleData(
      imageUrl: 'https://rsudcabangbungin.bekasikab.go.id/static/vendor/file/web/news_Masak-sih-DONOR-DARAH-banyak-manfaatnya--031009.jpeg',
      title: 'Masak sih DONOR DARAH banyak manfaatnya',
      preview: 'Selain bermanfaat untuk orang yang menerima, donor darah juga bermanfaat bagi sang pendonor darah. Lantas apa saja manfaat dari donor darah yang dapat kamu rasakan? Berikut ini manfaat positif dari kegiatan donor darah...',
      articleUrl: 'https://rsudcabangbungin.bekasikab.go.id/home/lihat_detail/artikel/MasaksihDONORDARAHbanyakmanfaatnya115204',
    ),
    ArticleData(
      imageUrl: 'https://cdns.klimg.com/merdeka.com/i/w/news/2022/10/12/1481116/540x270/manfaat-donor-darah-menurut-islam-bantu-selamatkan-nyawa-manusia.jpg',
      title: 'Manfaat Donor Darah Menurut Islam, Bantu Selamatkan Nyawa Manusia',
      preview: 'Menyumbangkan darah kepada orang lain yang membutuhkan termasuk suatu tindakan yang mulia. Dalam Surat Al Maidah ayat 2, Allah telah berfirman pada setiap umatnya untuk saling tolong menolong dan mengerjakan kebaikan dan takwa.....',
      articleUrl: 'https://www.merdeka.com/jateng/manfaat-donor-darah-menurut-islam-bantu-selamatkan-nyawa-manusia-kln.html',
    ),
    // Tambahkan artikel lainnya sesuai kebutuhan
  ];

  return ArticleSlider(articles: articles);
}