class Landmark {
  final String id;
  final String name;
  final String description;
  final String city;
  final String period;

  const Landmark({
    required this.id,
    required this.name,
    required this.description,
    required this.city,
    required this.period,
  });
}

const List<Landmark> mockLandmarks = [
  Landmark(
    id: 'hagia_sophia',
    name: 'Ayasofya',
    description:
        'Bizans İmparatoru I. Justinianus tarafından 537 yılında inşa ettirilen, '
        'dünya mimarlık tarihinin en önemli eserlerinden biri.',
    city: 'İstanbul',
    period: 'MS 537',
  ),
  Landmark(
    id: 'topkapi',
    name: 'Topkapı Sarayı',
    description:
        'Osmanlı İmparatorluğu\'nun yaklaşık 400 yıl boyunca yönetim merkezi '
        'olan saray, Fatih Sultan Mehmet tarafından 1459\'da inşa ettirilmiştir.',
    city: 'İstanbul',
    period: '15. yüzyıl',
  ),
  Landmark(
    id: 'ephesus',
    name: 'Efes Antik Kenti',
    description:
        'MÖ 10. yüzyılda kurulan, Roma döneminde Anadolu\'nun en büyük şehirlerinden '
        'biri olan antik kent; Celsus Kütüphanesi ile ünlüdür.',
    city: 'İzmir',
    period: 'MÖ 10. yüzyıl',
  ),
];
