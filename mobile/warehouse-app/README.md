# LogiFlow Warehouse

LogiFlow Warehouse is a thin mobile client for warehouse employees in the LogiFlow 3PL demonstration system. The application currently contains only a static welcome screen.

Barcode scanning and warehouse operations are planned for future stages. The application will communicate with the public API over REST/HTTPS and will not connect directly to PostgreSQL, SQL Server, or other databases.

## Requirements

- Flutter Stable
- Android SDK

## Development

Run from `mobile/warehouse-app`:

```powershell
flutter pub get
flutter analyze
flutter test
flutter run
```
