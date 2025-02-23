# Фитнес Трекер

Приложение для отслеживания фитнес-прогресса, планирования тренировок и питания.

## Функциональность

- Отслеживание прогресса (вес, замеры тела)
- Создание планов тренировок
- Создание планов питания
- Статистика и графики прогресса
- Система уведомлений

## Требования

- Docker и Docker Compose
- Flutter SDK (для сборки APK)
- Android Studio (для сборки APK)

## Запуск через Docker Compose

1. Клонируйте репозиторий:
```bash
git clone <url-репозитория>
cd fitness-tracker
```

2. Запустите приложение:
```bash
docker compose up -d
```

После запуска:
- Фронтенд будет доступен по адресу: `http://localhost:3000`
- Бэкенд API: `http://localhost:8080`
- База данных PostgreSQL: `localhost:5432`

Для остановки приложения:
```bash
docker compose down
```

## Создание APK файла

1. Убедитесь, что у вас установлены:
   - Flutter SDK
   - Android Studio
   - Android SDK

2. Перейдите в директорию frontend:
```bash
cd frontend
```

3. Получите зависимости:
```bash
flutter pub get
```

4. Создайте APK:
```bash
flutter build apk
```

APK файл будет создан по пути: `build/app/outputs/flutter-apk/app-release.apk`

Для создания отладочной версии:
```bash
flutter build apk --debug
```
=

## Разработка

### Бэкенд (Go)

Для локальной разработки:
```bash
cd backend
go run cmd/main.go
```

### Фронтенд (Flutter)

Для запуска в режиме разработки:
```bash
cd frontend
flutter run -d chrome  # для веб-версии
flutter run           # для мобильной версии
 