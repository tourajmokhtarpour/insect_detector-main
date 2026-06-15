class PestInfo {
  final String name;              // نام علمی/فارسی
  final String commonName;        // نام رایج
  final String order;             // راسته
  final String distribution;      // پراکنش جغرافیایی
  final String hosts;             // گیاهان میزبان
  final String damage;            // نوع خسارت
  final String symptoms;          // علائم خسارت
  final String controlMethods;    // روش‌های کنترل
  final String quarantineStatus;  // وضعیت قرنطینه‌ای
  final String imagePath;         // مسیر تصویر (اختیاری)

  PestInfo({
    required this.name,
    required this.commonName,
    required this.order,
    required this.distribution,
    required this.hosts,
    required this.damage,
    required this.symptoms,
    required this.controlMethods,
    required this.quarantineStatus,
    this.imagePath = '',
  });
}