# MatchScore — عداد المباريات

تطبيق Flutter عربي بالكامل لتسجيل نتيجة مباراة بين لاعبين أو أربعة لاعبين، مع حد فوز من 1 إلى 30 نقطة، حفظ محلي، وسجل قابل للمشاركة.

## التشغيل

يتطلب Flutter SDK حديثًا:

```bash
flutter pub get
flutter run
```

للتدقيق والاختبارات:

```bash
flutter analyze
flutter test
```

المشروع لا يستخدم Expo أو React Native. البيانات تحفظ محليًا على الجهاز عبر `shared_preferences`، والمشاركة تستخدم واجهة النظام عبر `share_plus`.
