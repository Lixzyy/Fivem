# lixzy_admin

**Auteur :** Lixzy

Module d'administration pour FiveM utilisant ESX (es_extended) et une interface RAGEUI.

## ⚙️ Fonctionnalités principales

- Activation/désactivation du mode staff
- Téléportation (`tp`, `tpto`, etc.)
- Revive / Unjail / Jail
- Envoi de messages & annonces globales
- Gestion d'inventaire et d'armes (clearInv, clearLoadout, wipe)
- Sauvegarde automatique des joueurs
- Commandes de kick
- Interface RAGEUI personnalisée dans le client
- Logs envoyées sur Discord via Webhooks
- Contrôle d'accès via licences ESX et configuration des tenues par groupe

## 📦 Pré-requis

- FiveM server
- [es_extended](https://github.com/esx-framework/es_extended) (dépendance déclarée)
- MySQL (utilise @mysql-async)

## 🛠 Installation

1. Copiez le dossier `lixzy_admin` dans votre répertoire `resources`.
2. Ajoutez `ensure lixzy_admin` à votre `server.cfg`.
3. Assurez-vous que `es_extended` et `mysql-async` sont chargés avant le script.

## 📝 Configuration

Le fichier `config.lua` contient toutes les options :

- **Webhooks Discord** : Remplacez les URLs par celles de votre serveur pour les actions souhaitées.
- **Coordonnées de Jail/UnJail** : Ajustez `Config.JailBlip` et `Config.JailLocation`.
- **Licences** : Définissez les identifiants ESX pour chaque groupe.
- **GroupOutfits** : Personnalisez l'apparence des rôles (support, mod, admin, etc.).

> **Note** : ne modifiez pas les sections commentées dans le script si vous n'êtes pas sûr.

## 🚀 Utilisation

Les commandes sont implémentées côté serveur et client et sont accessibles aux utilisateurs dotés des licences appropriées. Par exemple :

```lua
-- Exemple côté serveur
TriggerEvent('lixzy_admin:teleport', targetPlayerId)
```

L'interface RAGEUI est visible en appuyant sur la touche définie dans `client/client.lua`.

## 🗂 Structure des fichiers

```
client/
  client.lua
  client_report.lua
server/
  server.lua

internal/RageUI/   -- bibliothèque intégrée RAGEUI
config.lua
fxmanifest.lua
```

## 🔐 Accès et licences

Le script gère plusieurs niveaux :
- `owner`
- `manager`
- `admin`
- `mod`
- `support`

Ajoutez simplement les licences ESX correspondantes dans la table `Config.Licenses`.

## 📄 SQL

Le dossier `sql/lixzy_admin.sql` contient les requêtes nécessaires au stockage (à adapter selon besoin).

## 📈 Logs Discord

Toutes les actions importantes sont dispatchées via webhooks configurables. Copiez votre URL dans le champ correspondant du `config.lua`.

## 🙋 Contribution

N'hésitez pas à forker le dépôt, ajouter des fonctionnalités ou corriger des bugs. Respectez la structure existante (RAGEUI et ESX).

---

Ce README offre un point de départ clair pour l'installation et l'utilisation du script d'administration `lixzy_admin`. Ajustez selon vos besoins serveur.

---

# English Version

**Author:** Lixzy

Administration module for FiveM using ESX (es_extended) and a RAGEUI interface.

## ⚙️ Key Features

- Enable/disable staff mode
- Teleportation (`tp`, `tpto`, etc.)
- Revive / Unjail / Jail
- Send messages & global announcements
- Inventory and weapon management (clearInv, clearLoadout, wipe)
- Automatic player saving
- Kick commands
- Custom RAGEUI interface on the client
- Discord logging via Webhooks
- Access control through ESX licenses and outfit configuration per group

## 📦 Requirements

- FiveM server
- [es_extended](https://github.com/esx-framework/es_extended) (declared dependency)
- MySQL (uses @mysql-async)

## 🛠 Installation

1. Copy the `lixzy_admin` folder to your `resources` directory.
2. Add `ensure lixzy_admin` to your `server.cfg`.
3. Make sure `es_extended` and `mysql-async` are started before the script.

## 📝 Configuration

The `config.lua` file contains all options:

- **Discord Webhooks**: Replace the URLs with your server's for each action.
- **Jail/UnJail coordinates**: Adjust `Config.JailBlip` and `Config.JailLocation`.
- **Licenses**: Set ESX identifiers for each group.
- **GroupOutfits**: Customize role appearance (support, mod, admin, etc.).

> **Note**: Do not modify the commented sections in the script if you are unsure.

## 🚀 Usage

Commands are implemented on both client and server and are available to users with the appropriate licenses. For example:

```lua
-- Server-side example
TriggerEvent('lixzy_admin:teleport', targetPlayerId)
```

The RAGEUI interface is shown by pressing the key defined in `client/client.lua`.

## 🗂 File Structure

```
client/
  client.lua
  client_report.lua
server/
  server.lua

internal/RageUI/   -- embedded RAGEUI library
config.lua
fxmanifest.lua
```

## 🔐 Access & Licenses

The script handles multiple levels:
- `owner`
- `manager`
- `admin`
- `mod`
- `support`

Simply add the appropriate ESX licenses into the `Config.Licenses` table.

## 📄 SQL

The `sql/lixzy_admin.sql` folder contains the necessary database queries (adjust as needed).

## 📈 Discord Logs

All important actions are dispatched via configurable webhooks. Copy your URL into the appropriate field in `config.lua`.

## 🙋 Contribution

Feel free to fork the repo, add features, or fix bugs. Respect the existing structure (RAGEUI and ESX).

---

This README provides a clear starting point for installing and using the `lixzy_admin` admin script. Adjust according to your server needs.
