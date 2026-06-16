# Port Tracking — Flutter Mobile App 🚢
Système de Suivi Portuaire — Application Mobile Android/iOS  
Built with Flutter + Dart, connected to Spring Boot backend

---

## 📋 Table des Matières
1. Aperçu
2. Technologies Utilisées
3. Prérequis
4. Installation
5. Configuration
6. Structure du Projet
7. Rôles & Accès
8. Fonctionnalités
9. Lancer l'Application
10. Build APK

---

## 📌 Aperçu
Application mobile Flutter pour le suivi portuaire PORTNET.  
Permet aux inspecteurs et autres acteurs de gérer les inspections, scanner les QR codes des conteneurs et recevoir des notifications en temps réel.

---

## 🛠 Technologies Utilisées
| Technologie | Version | Rôle |
|---|---|---|
| Flutter | 3.x | Framework mobile |
| Dart | 3.x | Langage |
| Dio | ^5.4.0 | HTTP Client |
| Provider | ^6.1.1 | State Management |
| GoRouter | ^13.0.0 | Navigation |
| flutter_secure_storage | ^9.0.0 | Stockage JWT token |
| mobile_scanner | ^5.0.0 | Scanner QR Code |
| image_picker | ^1.0.7 | Photos comme preuve |
| qr_flutter | ^4.1.0 | Affichage QR Code |
| shimmer | ^3.0.0 | Loading animations |

---

## ✅ Prérequis
- Flutter SDK 3.0+
- Android Studio
- Dart SDK 3.0+
- Spring Boot Backend démarré sur port 8080
- MySQL avec base `port_tracking`

```bash
flutter doctor
```

---

## 🚀 Installation

### 1. Cloner le projet
```bash
git clone https://github.com/Younes-Germat1/port-tracking-flutter.git
cd port-tracking-flutter
```

### 2. Installer les dépendances
```bash
flutter pub get
```

---

## ⚙️ Configuration

### IP du Backend
Modifier `lib/core/constants.dart` :

```dart
class AppConstants {
  // Pour appareil réel → utiliser l'IP de votre PC
  static const String baseUrl = 'http://192.168.X.X:8080';

  // Pour émulateur Android
  // static const String baseUrl = 'http://10.0.2.2:8080';

  // Pour iOS Simulator
  // static const String baseUrl = 'http://localhost:8080';
}
```

### Trouver l'IP de votre PC
```powershell
# Windows
ipconfig
# Chercher: Carte réseau sans fil Wi-Fi → Adresse IPv4
```

> ⚠️ Le téléphone et le PC doivent être sur le même réseau WiFi !

### Ouvrir le firewall Windows
```powershell
# En tant qu'Administrateur
netsh advfirewall firewall add rule name="Spring Boot 8080" dir=in action=allow protocol=TCP localport=8080 profile=any
```

---

## 📁 Structure du Projet
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

│   │   ├── auth_provider.dart

│   │   ├── fiche_provider.dart

│   │   └── notification_provider.dart

│   ├── screens/

│   │   ├── auth/

│   │   │   └── login_screen.dart       # Glassmorphism UI

│   │   ├── dashboard/

│   │   │   └── dashboard_screen.dart   # Stats cliquables

│   │   ├── fiches/

│   │   │   ├── fiche_list_screen.dart

│   │   │   ├── fiche_detail_screen.dart

│   │   │   └── create_fiche_screen.dart

│   │   ├── conteneurs/

│   │   │   ├── conteneur_list_screen.dart

│   │   │   └── conteneur_detail_screen.dart

│   │   ├── inspections/

│   │   │   ├── inspection_list_screen.dart

│   │   │   └── inspection_detail_screen.dart  # Photos comme preuve

│   │   ├── notifications/

│   │   │   └── notification_list_screen.dart

│   │   ├── admin/

│   │   │   └── user_management_screen.dart

│   │   └── qr/

│   │       └── qr_scanner_screen.dart   # Scanner futuriste

│   ├── widgets/

│   │   ├── app_drawer.dart

│   │   └── statut_badge.dart

│   ├── router/

│   │   └── app_router.dart

│   └── main.dart

├── assets/

│   └── images/

│       └── Portnet-removebg-preview.png

├── android/

├── ios/

├── pubspec.yaml

└── README.md

---

## 👥 Rôles & Accès
| Rôle | Email | Password | Pages Accessibles |
|---|---|---|---|
| ADMIN | admin@port.ma | 123456 | Tout + Utilisateurs |
| IMPORTATEUR | importateur@port.ma | 123456 | Dashboard, Fiches, Notifications |
| ADII | adii@port.ma | 123456 | Dashboard, Fiches, Conteneurs, Inspections |
| OPERATEUR | operateur@port.ma | 123456 | Dashboard, Fiches, Conteneurs |
| INSPECTEUR | inspecteur@port.ma | 123456 | Dashboard, Inspections, Scanner QR, Notifications |

---

## ✨ Fonctionnalités
- ✅ **Login sécurisé** avec JWT — UI glassmorphism PORTNET
- ✅ **Dashboard** avec statistiques cliquables par rôle
- ✅ **Scanner QR Code** futuriste pour les inspecteurs
- ✅ **Inspections** — voir, enregistrer résultats (Conforme/Non Conforme)
- ✅ **Photos comme preuve** d'inspection (caméra + galerie)
- ✅ **Notifications** en temps réel avec polling
- ✅ **Fiches Suiveuses** — créer, approuver, rejeter
- ✅ **Conteneurs** — suivi emplacement et statut
- ✅ **Gestion utilisateurs** (Admin)

---

## ▶️ Lancer l'Application

### Ordre à respecter :
```bash
# 1. Démarrer MySQL
# 2. Démarrer Spring Boot (IntelliJ → Run)
# 3. Connecter le téléphone Android en USB
# 4. Lancer Flutter
flutter run
```

### Hot Reload
r  # Hot reload

R  # Hot restart

q  # Quit

---

## 📦 Build APK

```bash
# Debug
flutter build apk --debug

# Release
flutter build apk --release
```

---

## 🐛 Problèmes Connus & Solutions
| Problème | Solution |
|---|---|
| Serveur inaccessible | Vérifier IP dans `constants.dart` + même WiFi |
| 403 Forbidden | Token expiré → se reconnecter |
| Écran noir | `flutter clean && flutter pub get && flutter run` |
| IP change | Relancer `ipconfig` et mettre à jour `constants.dart` |
| Camera QR ne fonctionne pas | Vérifier permission caméra dans `AndroidManifest.xml` |

---

## 📝 Notes PFE
- Backend partagé avec l'application web React
- Même base de données MySQL `port_tracking`
- Même JWT token — un seul backend pour web + mobile
- Application testée sur Android 8.1 (OPPO CPH1803)
- Logo PORTNET intégré