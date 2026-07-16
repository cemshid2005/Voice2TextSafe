# Voice2TextSafe

Server yoxdur. Database yoxdur. Login yoxdur.

Voice2TextSafe — WhatsApp və digər tətbiqlərdən **Share** edilən audio faylını
birbaşa sizin OpenAI və ya Gemini API açarınızla mətnə çevirən, tamamilə
serversiz Android tətbiqi. Bütün sorğular telefonunuzdan birbaşa seçdiyiniz AI
provayderinə göndərilir; heç bir vasitəçi server yoxdur.

## Əsas xüsusiyyətlər

- **Share Intent**: WhatsApp və digər tətbiqlərdən audio faylı paylaşarkən
  Voice2TextSafe-i seçin (cold və hot start dəstəyi).
- **Avtomatik dil aşkarlama**: Model danışıq dilini (dillərini) özü müəyyən
  edir; tərcümə etmir, code-switching-i olduğu kimi saxlayır.
- **Tərcümə** (10 dil): Azərbaycan, English, Türkçe, Русский, العربية,
  Deutsch, Français, Español, فارسی, 中文. Ayarlardan aktiv dilləri seçə
  bilərsiniz; orijinal transkripsiya heç vaxt dəyişdirilmir.
- **Xülasə** (4 növ): Normal, Professional, Qısa, Bullet-point. Mətn
  transkripsiyanın dilində qalır (tərcümə olunmur).
- **Nəticə əməliyyatları**: Copy, Share, Yenidən transkripsiya et.
- **API Key köməyi**: Onboarding və Ayarlarda `?` düyməsi ilə addım-addım
  təlimat və provayder saytına birbaşa keçid.
- **API Key** yalnız cihazda, Android Keystore ilə şifrələnmiş şəkildə
  saxlanılır (`flutter_secure_storage`).
- **Ayarlar**: AI provayder, API key, tərcümə dilləri, default tərcümə dili,
  dark mode.

## AI modelləri

| Əməliyyat | OpenAI | Gemini |
|-----------|--------|--------|
| Transkripsiya | `gpt-4o-transcribe` | `gemini-2.5-flash` |
| Tərcümə / Xülasə | `gpt-4o-mini` | `gemini-2.5-flash` |

## Texnologiyalar

- Flutter (Material 3), `provider` state management
- `flutter_secure_storage` — Android Keystore-backed API key saxlama
- `receive_sharing_intent` — Android Share Intent (`audio/*`)
- `http` — OpenAI / Gemini REST çağırışları
- `share_plus`, `shared_preferences`, `path_provider`, `url_launcher`

## Layihəni işə salmaq

**Tələblər**: Flutter SDK (stable), Android SDK, minSdk 23+

```bash
flutter pub get
flutter run           # cihaz/emulator qoşulu olmalıdır
```

APK yığmaq üçün:

```bash
flutter build apk --debug     # test üçün
flutter build apk --release   # nəşr üçün (imzalama konfiqurasiyası tələb olunur)
```

Yoxlama:

```bash
flutter analyze
flutter test
```

> **Qeyd**: `receive_sharing_intent` paketinin `1.9.0` versiyası bu layihənin
> Flutter/AGP versiyası ilə Gradle uyğunsuzluğu yaratdığı üçün `1.8.1`
> versiyası istifadə olunur (`pubspec.yaml`). Paket yeniləndikdə yenidən
> yoxlanılmalıdır.

## API Key necə əldə edilir

Tətbiqin içində Onboarding və ya **Ayarlar → API Key** yanındakı `?` düyməsi
addım-addım təlimat göstərir və provayder saytını açır.

| Provayder | Keçid |
|-----------|-------|
| OpenAI | https://platform.openai.com/api-keys |
| Gemini | https://aistudio.google.com/apikey |

OpenAI üçün hesabda billing/balans aktiv olmalıdır. Key yalnız sizin
cihazınızda saxlanılır.

## İstifadə axını

1. İlk açılışda provayder seçin və API key daxil edin.
2. WhatsApp-dan (və ya başqa tətbiqdən) audio faylı **Paylaş** edin →
   Voice2TextSafe-i seçin.
3. Transkripsiya bitdikdən sonra istəyə görə tərcümə və ya xülasə edin.
4. Mətni kopyalayın və ya paylaşın.

## Layihə strukturu

```
lib/
  core/            # tema, sabitlər (model adları, limitlər)
  models/          # AiProvider, TranslationLanguage, SummaryType, TranscriptionResult
  services/        # secure storage, settings, share intent, AI servisləri
  providers/       # SettingsProvider, TranscriptionProvider (state)
  screens/         # Splash, Onboarding, Home, Result, Settings
  widgets/         # ApiKeyField, ApiKeyHelpButton, LanguageChip, SummaryTypeChip, ...
  utils/           # Xəta mesajlarının xəritələnməsi
```

## Məxfilik

- Audio fayl yalnız cihazın müvəqqəti keş qovluğunda saxlanılır və
  transkripsiya bitdikdən / nəticə ekranından çıxıldıqdan sonra silinir.
  Tətbiq açılışında əvvəlki sessiyadan qalan fayllar da təmizlənir.
- Audio və mətn heç vaxt bizim tərəfimizdən idarə olunan serverdə saxlanılmır —
  yalnız seçdiyiniz AI provayderinə (OpenAI/Gemini) birbaşa HTTPS ilə
  göndərilir (onların öz məxfilik siyasətinə uyğun).
- API Key Android Keystore ilə şifrələnmiş şəkildə saxlanılır; log-lanmır.
- Tətbiqdə analitika, tracking və ya reklam SDK-sı yoxdur.

## Məlum məhdudiyyətlər

- **Yalnız Android** dəstəklənir. iOS üçün `ios/` qovluğu və Share Extension
  konfiqurasiyası hazırda yoxdur; Dart məntiqinin əksəriyyəti cross-platform
  olsa da, iOS build bu mərhələdə mümkün deyil.
- Audio fayl ölçüsü **15 MB** ilə məhdudlaşdırılıb.
- Çoxdillı (code-switching) transkripsiya keyfiyyəti seçilmiş modeldən
  asılıdır; nəticə 100% zəmanətli deyil.
- AI provayder sorğuları üçün internet bağlantısı və etibarlı API key tələb
  olunur; xidmət provayderin öz qiymətləndirmə/billing qaydalarına tabedir.
