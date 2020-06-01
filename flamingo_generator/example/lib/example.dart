import 'package:flamingo_generator/flamingo_generator.dart';

part 'example.value.g.dart';

enum JapanesePrefecture {
  // 北海道・東北
  @Value('北海道')
  hokkaido,
  @Value('青森')
  aomori,
  @Value('岩手')
  iwate,
  @Value('宮城')
  miyagi,
  @Value('秋田')
  akita,
  @Value('山形')
  yamagata,
  @Value('福島')
  fukushima,

  /// 関東
  @Value('茨城')
  ibaraki,
  @Value('栃木')
  tochigi,
  @Value('群馬')
  gunma,
  @Value('埼玉')
  saitama,
  @Value('千葉')
  chiba,
  @Value('東京')
  tokyo,
  @Value('神奈川')
  kanagawa,

  /// 北陸
  @Value('新潟')
  nigata,
  @Value('富山')
  toyama,
  @Value('石川')
  ishikawa,
  @Value('福井')
  fukui,

  /// 甲信越
  @Value('山梨')
  yamanashi,
  @Value('長野')
  nagano,

  /// 東海
  @Value('岐阜')
  gifu,
  @Value('静岡')
  shizuoka,
  @Value('愛知')
  aichi,

  /// 近畿
  @Value('三重')
  mie,
  @Value('滋賀')
  shiga,
  @Value('京都')
  kyoto,
  @Value('大阪')
  osaka,
  @Value('兵庫')
  hyogo,
  @Value('奈良')
  nara,
  @Value('和歌山')
  wakayama,

  /// 中国
  @Value('鳥取')
  tottori,
  @Value('島根')
  shimane,
  @Value('岡山')
  okayama,
  @Value('広島')
  hiroshima,
  @Value('山口')
  yamaguchi,

  /// 四国
  @Value('徳島')
  tokushima,
  @Value('香川')
  kagawa,
  @Value('愛媛')
  ehime,
  @Value('高知')
  kochi,

  /// 九州・沖縄
  @Value('福岡')
  fukuoka,
  @Value('佐賀')
  saga,
  @Value('長崎')
  nagasaki,
  @Value('熊本')
  kumamoto,
  @Value('大分')
  oita,
  @Value('宮崎')
  miyazaki,
  @Value('鹿児島')
  kagoshima,
  @Value('沖縄')
  okinawa,
}
