# Système de Contacts pour les Holonews

## Description

Les joueurs de type **PJ** (Personnages Joueurs) ne peuvent désormais envoyer des messages Holonews qu'aux utilisateurs qu'ils ont enregistrés dans leur liste de contacts. Cette restriction renforce la sécurité et la réalisme du système de communication.

## Fonctionnalités

### Pour les PJ

- **Gestion des contacts** : Cliquez sur le bouton "📇 Mes Contacts" en haut de la page d'envoi de Holonews pour accéder à la modale de gestion des contacts.
- **Ajouter un contact** : Entrez le nom d'utilisateur exact du contact et cliquez sur "Ajouter".
- **Supprimer un contact** : Cliquez sur le bouton "✕" à côté du contact dans la liste.
- **Envoi restreint** : Vous ne pouvez envoyer des messages qu'aux utilisateurs dans votre liste de contacts.

### Pour les MJ et PNJ

- Aucune restriction : Continuez à envoyer des messages à n'importe quel utilisateur comme avant.

## Architecture Technique

### Base de données

- **Colonne `contacts`** : Colonne JSONB dans la table `users` stockant les IDs des contacts
- **Index GIN** : Index sur la colonne `contacts` pour optimiser les requêtes

### Modèle User

Nouvelles méthodes :

```ruby
- add_contact(contact_username)     # Ajouter un contact
- remove_contact(contact_id)         # Supprimer un contact
- get_contacts                       # Récupérer la liste complète des contacts
- is_contact?(user_id)               # Vérifier si un utilisateur est un contact
```

### Contrôleur ContactsController

Routes :

- `GET /contacts` - Afficher la page des contacts
- `POST /contacts/add` - Ajouter un contact (Turbo Stream)
- `DELETE /contacts/remove` - Supprimer un contact (Turbo Stream)

### Vues

- `app/views/contacts/index.html.erb` - Page d'index
- `app/views/contacts/_list.html.erb` - Partielle pour la liste des contacts
- `app/views/contacts/_error.html.erb` - Partielle pour les erreurs

### Validation du Contrôleur Holonews

Dans la méthode `create` du `HolonewsController` :

- Vérification que si l'utilisateur est PJ et envoie à un utilisateur spécifique, cet utilisateur doit être dans sa liste de contacts
- Affichage d'une alerte si la validation échoue

## Migration

Fichier : `db/migrate/20250926130000_add_contacts_to_users.rb`

Crée une colonne `contacts` JSONB avec un index GIN pour les performances optimales.

## Utilisation

### Pour les joueurs PJ

1. Allez à la page d'envoi de Holonews (`/holonews/new`)
2. Cliquez sur le bouton "📇 Mes Contacts"
3. Dans la modale, entrez le nom d'utilisateur exact et cliquez sur "Ajouter"
4. Une fois ajouté, vous pouvez sélectionner ce contact dans le dropdown "Envoyer à"

### Gestion des contacts

- Les avatars des contacts s'affichent dans la liste
- Le bouton "✕" supprime le contact
- Un message d'alerte vous informe du statut de l'opération

## Points d'intégration

Le système s'intègre parfaitement avec :

- **Système de groupes** : Les restrictions s'appliquent uniquement aux PJ
- **Notification des Holonews** : Les notifications continuent de fonctionner normalement
- **Lecteur/Non-lecteur** : Aucun impact sur le système de lecture

## Sécurité

- Les contacts ne peuvent être ajoutés que si l'utilisateur existe
- Vous ne pouvez pas vous ajouter vous-même comme contact
- Les duplicatas sont empêchés
- Validation côté serveur pour la vérification des contacts lors de l'envoi
