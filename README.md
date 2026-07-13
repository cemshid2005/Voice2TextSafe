# Voice2TextSafe

Server yoxdur. Database yoxdur. Login yoxdur.

Voice2TextSafe - WhatsApp və digər tətbiqlərdən **Share** edilən audio faylını
birbaşa sizin OpenAI və ya Gemini API açarınızla mətnə çevirən, tamamilə
serversiz Android tətbiqi. Bütün sorğular telefonunuzdan birbaşa seçdiyiniz AI
provayderinə göndərilir; heç bir vasitəçi server yoxdur.

## Əsas xüsusiyyətlər

- **Share Intent**: WhatsApp/digər tətbiqlərdən audio faylı paylaşarkən
  Voice2TextSafe-i seçin.
- **Avtomatik dil aşkarlama**: Model danışıq dilini (dillərini) özü müəyyən
  edir, tərcümə etmir, olduğu kimi transkripsiya edir.
- **İstəyə bağlı tərcümə**: Azərbaycan / English / Türkçe. Orijinal
  transkripsiya heç vaxt dəyişdirilmir.
- **Copy / Share / Yenidən transkripsiya et**.
- **API Key** yalnız cihazda, Android Keystore ilə şifrələnmiş şəkildə
  saxlanılır (`flutter_secure_storage`).
- Dark mode, default tərcümə dili kimi ayarlar.

## Texnologiyalar

- Flutter (Material 3), `provider` state management
- `flutter_secure_storage` - Android Keystore-backed API key saxlama
- `receive_sharing_intent` - Android Share Intent
- `http` - OpenAI / Gemini REST çağırışları
- `share_plus`, `shared_preferences`, `path_provider`

## Layihəni işə salmaq

```bash
flutter pub get
flutter run           # cihaz/emulator qoşulu olmalıdır
```

APK yığmaq üçün:

```bash
flutter build apk --debug     # test üçün
flutter build apk --release   # nəşr üçün (imzalama konfiqurasiyası tələb olunur)
```

> Qeyd: `receive_sharing_intent` paketinin `1.9.0` versiyası bu layihənin
> Flutter/AGP versiyası ilə Gradle uyğunsuzluğu yaratdığı üçün `1.8.1`
> versiyası istifadə olunur (bax `pubspec.yaml`). Paket yeniləndikdə yenidən
> yoxlanılmalıdır.

## API Key necə əldə edilir

- **OpenAI**: https://platform.openai.com/api-keys ünvanından yeni "secret
  key" yaradın.
- **Gemini**: https://aistudio.google.com/app/apikey ünvanından API key əldə
  edin.

Tətbiqin ilk açılışında (və ya Ayarlar bölməsindən) provayder seçib API
key-i daxil edin. Key yalnız sizin cihazınızda saxlanılır.

## Layihə strukturu

```
lib/
  core/            # tema, sabitlər
  models/          # AiProvider, TranslationLanguage, TranscriptionResult
  services/        # secure storage, settings, share intent, AI servisləri
  providers/       # SettingsProvider, TranscriptionProvider (state)
  screens/         # Splash, Onboarding, Home, Result, Settings
  widgets/         # Təkrar istifadə olunan UI komponentləri
  utils/           # Xəta mesajlarının xəritələnməsi
```

## Məxfilik

- Audio fayl yalnız cihazın müvəqqəti keş qovluğunda saxlanılır və
  transkripsiya prosesi bitdikdən / nəticə ekranından çıxıldıqdan sonra
  silinir. Tətbiq açılışında əvvəlki sessiyadan qalan fayllar da təmizlənir.
  Sənəd: `lib/services/share_intent_service.dart`, `lib/providers/transcription_provider.dart`.
- Audio və mətn heç vaxt üçüncü tərəf serverində (bizim tərəfimizdən idarə
  olunan) saxlanılmır - yalnız seçdiyiniz AI provayderinə (OpenAI/Gemini)
  birbaşa HTTPS ilə göndərilir, onların öz məxfilik siyasətinə uyğun.
- API Key Android Keystore ilə şifrələnmiş şəkildə saxlanılır və heç vaxt
  log-lanmır.
- Tətbiqdə analitika, tracking və ya reklam SDK-sı yoxdur.

## Məlum məhdudiyyətlər (MVP)

- Audio fayl ölçüsü 15 MB ilə məhdudlaşdırılıb (hər iki provayderin sorğu
  limitlərinə uyğun təhlükəsiz hədd).
- Çoxdillı (code-switching) transkripsiya keyfiyyəti seçilmiş modeldən
  asılıdır; nəticə 100% zəmanətli deyil.
- Yalnız Android dəstəklənir (iOS bu mərhələdə hədəf deyil).
