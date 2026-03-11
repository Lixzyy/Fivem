# Advanced Airdrop System (FiveM) / Système de largage d'objets avancé (FiveM)

This README provides both English and French documentation for the `lixzy_drop` resource.

---

## English 🇬🇧

Premium-grade, production-ready airdrop system for FiveM with plane flyover, parachute crate, red smoke, blips, notifications, and configurable loot.

### Features

- **Plane airdrop**: Spawns outside the map, flies over target, drops crate, despawns.
- **Parachute crate**: Natural fall, landing detection, red smoke on ground, configurable lifetime.
- **Player interaction**: Hold **E** to open, progress bar & animation. Exclusive access; one player at a time.
- **Loot system**: Money / Weapons / Rare Items with configurable tables.
- **Map system**: Blip + radius zone during event.
- **Notifications**: Incoming / Landed / Opened.
- **Event system**: Auto-timer, chance, min players.
- **Performance**: Event-driven, no heavy permanent loops.
- **Framework bridge**: ESX, QBCore, or standalone.
- **Webhook**: Optional Discord logs.

### Install

1. Drop the `lixzy_drop` (or `airdrop-system`) folder into `resources/`.
2. Add `ensure lixzy_drop` (or the folder name) to your `server.cfg`.
3. Configure everything in `config/`:
   - `config.lua` for timers, plane/crate/models, blips.
   - `locations.lua` to set drop spots.
   - `loot.lua` for rewards & weights.
4. (Optional) Add custom crate or plane models in `stream/`.

### Commands / ConVars

| Command / ConVar | Description |
|---|---|
| `/airdropspawn` | Manually spawns an airdrop at your current position (admin only). |
| `+set airdrop_debug 1` | Add to `server.cfg` for verbose logs. |

> **`/airdropspawn`** — Allows an admin to instantly trigger an airdrop event at their exact in-game position. Useful for testing or server events. Requires the appropriate ACE permission or admin level depending on your framework configuration.

### Notes

- Plane engine sound uses generic sets; depending on your build they may be silent (harmless).
- Rewards delivery auto-detects ESX/QBCore if present. Tune `Config.Framework` as needed.
- Replace item names to match your inventory system.

### Support

This resource is structured to premium standards with modular files for easy maintenance.

---

## Français 🇫🇷

Ressource premium prête pour la production offrant un largage aérien avec avion, caisse en parachute, fumée rouge, blips, notifications et butin configurable.

### Fonctionnalités

- **Largage par avion** : spawn à l'extérieur de la carte, survole la zone ciblée, largue la caisse, puis se désactive.
- **Caisse en parachute** : chute naturelle, détection d'atterrissage, fumée rouge au sol et durée configurable.
- **Interaction joueur** : maintenir **E** pour ouvrir, barre de progression et animation. Un seul joueur à la fois.
- **Système de butin** : argent / armes / objets rares avec tables de poids paramétrables.
- **Système de carte** : blip et zone radius pendant l'événement.
- **Notifications** : à l'approche, à l'atterrissage, à l'ouverture.
- **Système d'événement** : minuterie automatique, chances, nombre minimal de joueurs.
- **Performance** : événementiel, pas de boucles lourdes permanentes.
- **Bridge de framework** : ESX, QBCore ou autonome.
- **Webhook** : journaux Discord optionnels.

### Installation

1. Déposer le dossier `lixzy_drop` (ou `airdrop-system`) dans `resources/`.
2. Ajouter `ensure lixzy_drop` (ou le nom du dossier) dans `server.cfg`.
3. Configurer les fichiers sous `config/` :
   - `config.lua` pour les timers, modèles d'avion/caisse, blips, etc.
   - `locations.lua` pour définir les emplacements de largage.
   - `loot.lua` pour les récompenses et leurs poids.
4. (Optionnel) Ajouter des modèles personnalisés d'avion ou de caisse dans `stream/`.

### Commandes / ConVars

| Commande / ConVar | Description |
|---|---|
| `/airdropspawn` | Fait apparaître manuellement un airdrop à votre position actuelle (admin uniquement). |
| `+set airdrop_debug 1` | À ajouter dans `server.cfg` pour des logs verbeux. |

> **`/airdropspawn`** — Permet à un administrateur de déclencher instantanément un événement d'airdrop à sa position exacte en jeu. Utile pour les tests ou les événements serveur. Nécessite la permission ACE appropriée ou le niveau admin selon la configuration de votre framework.

### Remarques

- Le son du moteur de l'avion utilise des sets génériques ; selon votre build ils peuvent être silencieux (sans gravité).
- L'attribution du butin détecte automatiquement ESX/QBCore si présent. Ajuster `Config.Framework` si nécessaire.
- Remplacez les noms d'objets selon votre système d'inventaire.

### Support

La ressource est structurée selon des standards premium avec des fichiers modulaires pour une maintenance facile.