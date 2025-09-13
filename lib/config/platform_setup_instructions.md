Platform setup for Google Maps

1) Get an API key
   - Go to Google Cloud Console, enable Maps SDK for Android and/or iOS and create an API key.

2) Android
   - Open `android/app/src/main/AndroidManifest.xml` and add inside the <application> tag:
     <meta-data android:name="com.google.android.geo.API_KEY" android:value="YOUR_API_KEY"/>
   - Alternatively, use a string resource and keep API key out of version control.

3) iOS
   - Open `ios/Runner/AppDelegate.swift` or Info.plist and add your api key via:
     GMSServices.provideAPIKey("YOUR_API_KEY")
   - If using Info.plist, add a key `GMSApiKey` with the value of your key (recommended in code is explicit).

4) Local convenience file (optional)
    - You can copy `lib/config/google_maps_api_key.dart.example` to
       `lib/config/google_maps_api_key.dart` and paste your key there. That file is
       gitignored and can be used by Dart code when useful.

5) After adding keys run:
   flutter pub get
   flutter run
