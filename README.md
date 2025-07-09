# 🏨 Booking App - Application de Réservation

[![Flutter](https://img.shields.io/badge/Built%20with-Flutter-02569B?style=for-the-badge&logo=flutter)](https://flutter.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)
[![Platforms](https://img.shields.io/badge/Platform-iOS%20%7C%20Android%20%7C%20Web%20%7C%20Desktop-lightgrey.svg?style=for-the-badge)]()

Une application de réservation multiplateforme, complète et élégante, construite avec Flutter. Elle offre une expérience utilisateur fluide pour parcourir, réserver et gérer des annonces de location.

### ✨ Galerie d'aperçus

| Login Screen | Home Screen | Detail Page |
| :---: | :---: | :---: |
| ![Placeholder Login](https://via.placeholder.com/300x600.png?text=Login+Screen) | ![Placeholder Home](https://via.placeholder.com/300x600.png?text=Home+Screen) | ![Placeholder Details](https://via.placeholder.com/300x600.png?text=Detail+Page) |
*Insérez ici des captures d'écran réelles de votre application.*

---

## 📋 Table des matières

1.  [🌟 Fonctionnalités Clés](#-fonctionnalités-clés)
2.  [🛠️ Stack Technique](#️-stack-technique)
3.  [📂 Structure du Projet](#-structure-du-projet)
4.  [🚀 Démarrage Rapide](#-démarrage-rapide)
5.  [⚙️ Configuration Requise](#️-configuration-requise)
6.  [✅ Lancer les Tests](#-lancer-les-tests)
7.  [🤝 Contribuer](#-contribuer)
8.  [📄 Licence](#-licence)

---

## 🌟 Fonctionnalités Clés

-   **🔑 Authentification Robuste :**
    -   Écrans d'inscription et de connexion.
    -   Gestion de la session utilisateur via un service dédié (`AuthService`).
    -   Utilisation potentielle de tokens (`TokenService`).

-   **🏡 Exploration d'Annonces :**
    -   Affichage dynamique des listes depuis un service (`ListingService`).
    -   Interface contrôlée par `HomeTabController` et `ListingController`.

-   **ℹ️ Détails Complets et Transparents :**
    -   Page de détail avec description, photos, caractéristiques (`FeatureWidget`).
    -   Informations sur le propriétaire (`OwnerInfoWidget`).
    -   Section de commentaires interactive (`CommentSectionWidget`).

-   **📅 Système de Réservation Intuitif :**
    -   Logique de réservation gérée par `ReservationController`.
    -   Interface de paiement sur `PaymentPage`.
    -   Écran de suivi des réservations (`ReservationScreen`).

-   **❤️ Gestion des Favoris :**
    -   Ajoutez ou retirez des annonces de votre liste de favoris.
    -   Logique gérée par `FavoritesController`.

-   **💬 Messagerie Intégrée :**
    -   Communiquez avec les propriétaires via un écran de chat (`ChatScreen`).
    -   Gestion des conversations et des messages (`ConversationService`).

-   **📱 Interface Multiplateforme :**
    -   Code unique pour Android, iOS, Web, Windows, macOS, et Linux.
    -   Design adaptatif et réactif.

---

## 🛠️ Stack Technique

-   **Framework :** [Flutter](https://flutter.dev)
-   **Langage :** [Dart](https://dart.dev)
-   **Architecture :** Le projet semble suivre une architecture de type **MVC (Modèle-Vue-Contrôleur)** ou similaire, avec une séparation claire des responsabilités :
    -   `models` : La couche de données.
    -   `screens` : La couche de vue (UI).
    -   `controllers` : La couche de logique métier.
-   **Gestion d'état :** Probablement **GetX** ou **Provider**, étant donné l'utilisation de contrôleurs dédiés.
-   **Services Backend :** La structure avec le dossier `services` est conçue pour interagir avec des API externes (ex: **Firebase**, **API REST**).

---

## 📂 Structure du Projet

Le projet est organisé pour être évolutif et maintenable.

```
/lib
├── /config         # Fichiers de configuration (Thème, couleurs, URLs d'API).
│   └── theme.dart
├── /controllers    # Gestion de l'état et de la logique pour chaque fonctionnalité.
│   └── listing_controller.dart
├── /models         # Classes Dart pures représentant les données de l'application.
│   └── listing_model.dart
├── /screens        # Widgets représentant les pages complètes de l'application.
│   └── detail_page.dart
├── /services       # Couche de communication avec les sources de données externes.
│   └── listing_service.dart
└── /widgets        # Petits widgets réutilisables à travers l'application.
    └── custom_nav_bar.dart
```

---

## 🚀 Démarrage Rapide

Suivez ces étapes pour faire fonctionner le projet en local.

### 1. Prérequis

-   Assurez-vous d'avoir le **[Flutter SDK](https://flutter.dev/docs/get-started/install)** installé.
-   Vérifiez votre installation avec la commande `flutter doctor`. Tout doit être coché (✅).

### 2. Installation

1.  **Clonez le dépôt :**
    ```sh
    git clone https://github.com/votre-utilisateur/booking-app.git
    cd booking-app
    ```

2.  **Installez les dépendances :**
    ```sh
    flutter pub get
    ```

3.  **Lancez l'application :**
    ```sh
    flutter run
    ```
    Pour choisir un appareil spécifique (ex: Chrome pour le web) :
    ```sh
    flutter run -d chrome
    ```

---

## ⚙️ Configuration Requise

Avant de lancer l'application, vous pourriez avoir besoin de configurer des variables d'environnement ou des clés d'API.

-   **Où ?** Jetez un œil au fichier `lib/config/app_config.dart`.
-   **Exemple (fictif) :**
    ```dart
    // lib/config/app_config.dart
    class AppConfig {
      static const String apiKey = 'VOTRE_CLE_API_ICI';
      static const String baseUrl = 'https://api.monapp.com/v1';
    }
    ```

---

## ✅ Lancer les Tests

Pour garantir que tout fonctionne comme prévu, lancez la suite de tests automatisés :

```sh
flutter test
```

---

## 🤝 Contribuer

Votre aide est la bienvenue pour faire grandir ce projet !

1.  **🍴 Fork** le projet.
2.  **🌿 Créez** une nouvelle branche (`git checkout -b feature/ma-super-feature`).
3.  **💾 Committez** vos changements (`git commit -m 'feat: Ajout de ma super feature'`).
4.  **📤 Pushez** vers la branche (`git push origin feature/ma-super-feature`).
5.  **📬 Ouvrez** une Pull Request.

---

## 📄 Licence

Ce projet est distribué sous la licence MIT. Voir le fichier `LICENSE` pour plus de détails.
