import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TutorialScreen extends StatelessWidget {
  const TutorialScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nasıl Oynanır?'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Erdoğan Liderlik Kararları',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Bu oyun, Recep Tayyip Erdoğan\'ın 20 yıllık liderlik döneminde karşılaştığı zorlu kararları simüle eder. Amacınız, dört temel değeri dengede tutarak ülkeyi yönetmektir.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            
            // Değerler
            _buildSection(
              context,
              'Dört Temel Değer',
              [
                _buildValueItem(context, 'Sağlık', Colors.red, 'Halk sağlığı ve vatandaş refahını temsil eder.'),
                _buildValueItem(context, 'Zenginlik', Colors.amber, 'Ekonomik istikrar ve refahı temsil eder.'),
                _buildValueItem(context, 'Politik', Colors.blue, 'Siyasi gücü ve uluslararası duruşu temsil eder.'),
                _buildValueItem(context, 'Toplumsal', Colors.green, 'Sosyal uyumu ve halk desteğini temsil eder.'),
              ],
            ),
            
            // Oyun Mekanikleri
            _buildSection(
              context,
              'Oyun Mekanikleri',
              [
                _buildItem(context, 'Her değer 0-100 arasında değişir ve 50 puanla başlar.'),
                _buildItem(context, 'Herhangi bir değer 0\'a ulaştığında oyun sona erer.'),
                _buildItem(context, 'Değerler zaman içinde doğal olarak azalır, sürekli yönetim gerektirir.'),
                _buildItem(context, 'Kararlar değerleri -25 ile +25 arasında etkiler.'),
              ],
            ),
            
            // Nasıl Oynanır
            _buildSection(
              context,
              'Nasıl Oynanır',
              [
                _buildItem(context, 'Sağa kaydırma = EVET kararı'),
                _buildItem(context, 'Sola kaydırma = HAYIR kararı'),
                _buildItem(context, 'Her karar dört değeri farklı şekilde etkiler.'),
                _buildItem(context, 'Bazı kararlar zincir olayları tetikler.'),
                _buildItem(context, 'Oyun dört dönemden oluşur: İktidara Yükseliş, Konsolidasyon, Kriz ve Tepki, Geç Dönem.'),
              ],
            ),
            
            // İpuçları
            _buildSection(
              context,
              'İpuçları',
              [
                _buildItem(context, 'Değerleri dengede tutmaya çalışın.'),
                _buildItem(context, 'Kararlarınızın uzun vadeli sonuçlarını düşünün.'),
                _buildItem(context, 'Bazı kararlar kısa vadede olumlu, uzun vadede olumsuz etkilere sahip olabilir.'),
                _buildItem(context, 'Oyun ilerledikçe zorluk artar.'),
              ],
            ),
            
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('ANLADIM'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Divider(),
        const SizedBox(height: 8),
        ...items,
      ],
    );
  }

  Widget _buildItem(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.arrow_right, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueItem(BuildContext context, String name, Color color, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.circle, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: [
                  TextSpan(
                    text: '$name: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  TextSpan(
                    text: description,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
