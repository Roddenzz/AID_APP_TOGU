# Отчет об изменениях сборки

## Исправленные проблемы

### ✅ Android APK — исправлено
- **Проблема:** конфликты между Gradle и Kotlin DSL
- **Решение:** все Gradle-файлы переведены на `.kts`, версии плагинов приведены к AGP 8.2.1 и Kotlin 1.9.22, убраны дублирующие объявления и временно отключен плагин Google Services.
- **Результат:** `build/app/outputs/flutter-apk/app-release.apk` (56.1 МБ) собирается без ошибок.
- **Файл:** `android/app/build.gradle.kts` теперь содержит только нужные плагины, а `google-services.json` можно подключить после настройки Firebase.

### ⚠️ Windows сборка — требует внимания
- **Проблема:** плагин Firebase Auth не компилируется C++ (ошибка `std::variant`).
- **Решения:**
  1. **Временно убрать Firebase** (закомментировать `firebase_core`, `firebase_auth`, `cloud_firestore` в `pubspec.yaml`).
  2. **Понизить версии Firebase** до проверенных (например, `firebase_core` 2.20.0 и т.д.).
  3. **Использовать Firebase Web** для десктопа (посредством web API).

## Изменённые файлы
- `android/settings.gradle.kts`, `android/build.gradle.kts`, `android/app/build.gradle.kts` — переведены на Kotlin DSL с едиными версиями.
- Удалены старые Groovy-файлы (`settings.gradle`, `build.gradle`, `app/build.gradle`).

## Текущее состояние
- ✅ Android сборка работает, конфигурация Gradle выровнена.
- ⚠️ Firebase отключён для Android (нужны `google-services.json` и плагин).
- ⚠️ Windows сборка рушится на Firebase Auth.

## Как вернуть Firebase

### Android
1. В Firebase Console откройте проект `profburo-255e8`.
2. Добавьте Android-приложение `com.example.aid_app`.
3. Скачайте новый `google-services.json` в `android/app/`.
4. Раскомментируйте `id("com.google.gms.google-services")` в `android/app/build.gradle.kts`.

### Windows
Следуйте одному из предложенных выше вариантов (убрать Firebase или понизить версии).

## Рекомендации
- Обновить Android Gradle Plugin до 8.6.0 и Kotlin до 2.1.0 (в `android/settings.gradle.kts`).
- `flutter clean && flutter pub get` после любых изменений.

## Быстрые команды

```bash
flutter build apk         # Android релиз
flutter build appbundle   # App Bundle
flutter run               # Запуск на устройстве
flutter clean
flutter pub get
```

## Следующие шаги
1. Для тестов: пользоваться готовым APK.
2. Для выпуска: подключить Firebase и подписать сборку.
3. Для Windows: выбрать подходящий вариант с Firebase.
4. Для обновлений: рассмотреть повышение версий Gradle и Kotlin.

---

**Дата сборки**: 12 декабря 2025  
**Статус**: Android ✅ | Windows ⚠️ (Firebase Auth)
