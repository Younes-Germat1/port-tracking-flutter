# 🚢 Port Tracking — Flutter Mobile App

> Système de suivi portuaire — Application Mobile Android/iOS
> Built with Flutter + Dart, connected to Spring Boot backend

---

## 📋 Table des Matières

- [Aperçu](#aperçu)
- [Technologies Utilisées](#technologies-utilisées)
- [Prérequis](#prérequis)
- [Installation](#installation)
- [Configuration](#configuration)
- [Connexion avec le Backend Spring Boot](#connexion-avec-le-backend)
- [Structure du Projet](#structure-du-projet)
- [Rôles & Accès](#rôles--accès)
- [Lancer l'Application](#lancer-lapplication)
- [Build APK](#build-apk)

---

## 📌 Aperçu

Application mobile Flutter pour le suivi portuaire. Permet aux différents acteurs (Importateur, ADII, Opérateur, Inspecteur, Admin) de gérer les fiches suiveuses, conteneurs et inspections depuis leur smartphone.

---

## 🛠 Technologies Utilisées

| Technologie | Version | Rôle |
|---|---|---|
| Flutter | 3.x | Framework mobile |
| Dart | 3.x | Langage |
| Dio | ^5.4.0 | HTTP Client (comme Axios) |
| Provider | ^6.1.1 | State Management |
| GoRouter | ^13.0.0 | Navigation |
| flutter_secure_storage | ^9.0.0 | Stockage JWT token |
| jwt_decoder | ^2.0.1 | Décodage token |
| qr_flutter | ^4.1.0 | Affichage QR Code |
| shimmer | ^3.0.0 | Loading animations |

---

## ✅ Prérequis

- **Flutter SDK** 3.0+ → [flutter.dev](https://flutter.dev/docs/get-started/install)
- **Android Studio** avec émulateur Android (API 26+)
- **Dart SDK** 3.0+
- **Spring Boot Backend** démarré sur port `8080`
- **MySQL** avec base `port_tracking`

Vérifier l'installation Flutter:
```bash
flutter doctor
```

---

## 🚀 Installation

### 1. Cloner le projet

```bash
git clone https://github.com/votre-repo/port-tracking-flutter.git
cd port-tracking-flutter
```

### 2. Installer les dépendances

```bash
flutter pub get
```

### 3. Créer les dossiers (si pas déjà fait)

```powershell
New-Item -ItemType Directory -Force -Path lib/core, lib/models, lib/services, lib/providers, lib/screens/auth, lib/screens/dashboard, lib/screens/fiches, lib/screens/conteneurs, lib/screens/inspections, lib/screens/notifications, lib/screens/admin, lib/widgets, lib/router, lib/utils
```

---

## ⚙️ Configuration

### IP du Backend selon l'environnement

Modifier `lib/core/constants.dart`:

```dart
class AppConstants {
  // Pour émulateur Android → utiliser 10.0.2.2
  static const String baseUrl = 'http://10.0.2.2:8080';

  // Pour appareil réel → utiliser l'IP de votre PC
  // static const String baseUrl = 'http://192.168.1.x:8080';

  // Pour iOS Simulator → utiliser localhost
  // static const String baseUrl = 'http://localhost:8080';
}
```

### Trouver l'IP de votre PC (appareil réel)

```bash
# Windows
ipconfig
# Chercher: IPv4 Address → ex: 192.168.1.5

# Mac/Linux
ifconfig | grep inet
```

---

## 🔗 Connexion avec le Backend

### Flow d'Authentification

```
Flutter App → POST /api/auth/login → Spring Boot
           ← { id, token, role, email, nom }
           → Stocke token dans SecureStorage
           → Toutes les requêtes incluent: Authorization: Bearer <token>
```

### Configuration Dio (`lib/core/api_client.dart`)

```dart
static Dio _createDio() {
  final dio = Dio(BaseOptions(
    baseUrl: AppConstants.baseUrl,  // http://10.0.2.2:8080
    connectTimeout: Duration(seconds: 10),
  ));

  // Intercepteur JWT automatique
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final token = await AuthStorage.getToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      return handler.next(options);
    },
  ));
  return dio;
}
```

### Endpoints Backend Utilisés

| Méthode | Endpoint | Service Flutter |
|---|---|---|
| POST | `/api/auth/login` | `AuthService.login()` |
| GET | `/api/fiches` | `FicheService.getAllFiches()` |
| POST | `/api/fiches` | `FicheService.createFiche()` |
| PUT | `/api/fiches/{id}/statut` | `FicheService.updateStatut()` |
| GET | `/api/conteneurs/fiche/{id}` | `ConteneurService.getConteneursByFiche()` |
| POST | `/api/conteneurs` | `ConteneurService.createConteneur()` |
| PUT | `/api/conteneurs/{id}/emplacement` | `ConteneurService.assignEmplacement()` |
| GET | `/api/inspections` | `InspectionService.getAllInspections()` |
| GET | `/api/inspections/mes-taches` | `InspectionService.getMesTaches()` |
| POST | `/api/inspections` | `InspectionService.createInspection()` |
| PUT | `/api/inspections/{id}/resultat` | `InspectionService.enregistrerResultat()` |
| GET | `/api/notifications/me` | `NotificationService.getMyNotifications()` |
| PUT | `/api/notifications/{id}/lu` | `NotificationService.markAsRead()` |
| GET | `/api/admin/users` | `UserService.getAllUsers()` |

---

## 📁 Structure du Projet

```
port_tracking_flutter/
├── lib/
│   ├── core/
│   │   ├── constants.dart        # baseUrl, roles, statuts
│   │   ├── api_client.dart       # Dio + JWT interceptor
│   │   └── auth_storage.dart     # SecureStorage token
│   ├── models/
│   │   ├── user.dart
│   │   ├── fiche.dart
│   │   ├── conteneur.dart
│   │   ├── inspection.dart
│   │   ├── notification.dart
│   │   └── document.dart
│   ├── services/
│   │   ├── auth_service.dart
│   │   ├── fiche_service.dart
│   │   ├── conteneur_service.dart
│   │   ├── inspection_service.dart
│   │   ├── notification_service.dart
│   │   └── user_service.dart
│   ├── providers/
│   │   ├── auth_provider.dart       # Login, logout, user state
│   │   ├── fiche_provider.dart      # Fiches list + filters
│   │   └── notification_provider.dart # Unread count + polling
│   ├── screens/
│   │   ├── auth/
│   │   │   └── login_screen.dart
│   │   ├── dashboard/
│   │   │   └── dashboard_screen.dart
│   │   ├── fiches/
│   │   │   ├── fiche_list_screen.dart
│   │   │   ├── fiche_detail_screen.dart
│   │   │   └── create_fiche_screen.dart
│   │   ├── conteneurs/
│   │   │   ├── conteneur_list_screen.dart
│   │   │   └── conteneur_detail_screen.dart
│   │   ├── inspections/
│   │   │   └── inspection_list_screen.dart
│   │   ├── notifications/
│   │   │   └── notification_list_screen.dart
│   │   └── admin/
│   │       └── user_management_screen.dart
│   ├── widgets/
│   │   ├── app_drawer.dart          # Side menu by role
│   │   ├── statut_badge.dart        # Colored status chip
│   │   └── notification_bell.dart   # Bell with red badge
│   ├── router/
│   │   └── app_router.dart          # GoRouter + role guards
│   ├── utils/
│   │   ├── date_formatter.dart
│   │   └── role_helper.dart
│   └── main.dart                    # App entry point
├── android/
├── ios/
├── pubspec.yaml
└── README.md
```

---

## 👥 Rôles & Accès

| Rôle | Email | Password | Pages Accessibles |
|---|---|---|---|
| **ADMIN** | admin@port.ma | 123456 | Tout + Utilisateurs |
| **IMPORTATEUR** | importateur@port.ma | 123456 | Dashboard, Fiches, Notifications |
| **ADII** | adii@port.ma | 123456 | Dashboard, Fiches, Conteneurs, Inspections |
| **OPERATEUR** | operateur@port.ma | 123456 | Dashboard, Fiches, Conteneurs |
| **INSPECTEUR** | inspecteur@port.ma | 123456 | Dashboard, Inspections, Notifications |

---

## ▶️ Lancer l'Application

### 1. Démarrer le backend Spring Boot
```bash
# Dans IntelliJ → Run PortTrackingBackendApplication
# Vérifier: Tomcat started on port(s): 8080
```

### 2. Démarrer l'émulateur Android
```bash
# Android Studio → Device Manager → Start Emulator
# OU
flutter emulators --launch <emulator_id>
```

### 3. Lancer l'app Flutter
```bash
flutter run
```

### Hot Reload (pendant le développement)
```bash
r  # Hot reload
R  # Hot restart
q  # Quit
```

---

## 📦 Build APK

### Debug APK (pour tests)
```bash
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk
```

### Release APK (pour production/PFE demo)
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Install directement sur appareil connecté
```bash
flutter install
```

---

## 🔧 Démarrage Complet

```
Ordre à respecter:
1. Démarrer MySQL
2. Démarrer Spring Boot (port 8080)
3. Démarrer émulateur Android
4. flutter run
5. Login: importateur@port.ma / 123456
```

---

## 🐛 Problèmes Connus & Solutions

| Problème | Solution |
|---|---|
| `Connection refused` | Vérifier Spring Boot est démarré |
| `403 Forbidden` | Token expiré → se reconnecter |
| `10.0.2.2` ne marche pas | Utiliser l'IP réelle du PC sur appareil physique |
| Écran noir au démarrage | `flutter clean && flutter pub get` |
| `file_picker` error | Déjà retiré du pubspec.yaml |

---

## 📝 Notes PFE

- Backend partagé avec l'application web React
- Même base de données MySQL `port_tracking`
- Même JWT token — un seul backend pour web + mobile
- Application testée sur **Android API 36 (Pixel 8 Pro)**
