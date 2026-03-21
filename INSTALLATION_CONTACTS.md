# Installation de la Fonctionnalité des Contacts

## Étapes d'installation

### 1. Appliquer la migration

```bash
bin/rails db:migrate
```

Cette migration:
- Crée une colonne `contacts` (JSONB) dans la table `users`
- Ajoute un index GIN pour optimiser les requêtes

### 2. Vérifier les fichiers créés

Les fichiers suivants ont été créés/modifiés:

**Fichiers créés:**
- ✅ `app/controllers/contacts_controller.rb` - Contrôleur pour la gestion des contacts
- ✅ `app/views/contacts/index.html.erb` - Page d'index
- ✅ `app/views/contacts/_list.html.erb` - Partielle pour la liste
- ✅ `app/views/contacts/_error.html.erb` - Partielle pour les erreurs
- ✅ `app/assets/stylesheets/contacts.scss` - Styles CSS
- ✅ `db/migrate/20250926130000_add_contacts_to_users.rb` - Migration DB
- ✅ `CONTACTS_FEATURE.md` - Documentation technique

**Fichiers modifiés:**
- ✅ `app/models/user.rb` - Ajout des méthodes de gestion des contacts
- ✅ `config/routes.rb` - Ajout des routes des contacts
- ✅ `app/controllers/holonews_controller.rb` - Validation des contacts pour les PJ
- ✅ `app/views/holonews/new.html.erb` - Interface adaptée aux PJ
- ✅ `app/javascript/controllers/contacts_controller.js` - Contrôleur Stimulus

### 3. Redémarrer le serveur

```bash
bin/rails s
```

### 4. Vérifier l'installation

1. Connectez-vous avec un compte de type **PJ**
2. Allez à `/holonews/new`
3. Vous devriez voir le bouton "📇 Mes Contacts" en haut de la page
4. Cliquez dessus pour ouvrir la modale de gestion des contacts

## Vérifications de fonctionnement

### Test 1: Ajout de contact
1. Entrez le nom d'utilisateur exact d'un autre utilisateur
2. Cliquez "Ajouter"
3. Le contact doit apparaître dans la liste

### Test 2: Suppression de contact
1. Cliquez sur le "✕" à côté d'un contact
2. Confirmez la suppression
3. Le contact doit disparaître de la liste

### Test 3: Restriction d'envoi
1. Essayez d'envoyer un message à un utilisateur qui n'est pas dans vos contacts
2. Vous devriez recevoir une alerte: "Vous ne pouvez envoyer des messages qu'à vos contacts."

### Test 4: MJ/PNJ sans restriction
1. Connectez-vous avec un compte **MJ** ou **PNJ**
2. Allez à `/holonews/new`
3. Vous ne devriez pas voir le bouton "Mes Contacts"
4. Vous pouvez envoyer des messages à n'importe quel utilisateur

## Données de test

Pour tester rapidement:

```ruby
# Dans la console Rails
user = User.find_by(username: 'votre_username')
user.add_contact('autre_username')
user.get_contacts
```

## Troubleshooting

### La colonne contacts n'existe pas
```bash
# Vérifiez que la migration a été appliquée
bin/rails db:migrate:status

# Réappliquez si nécessaire
bin/rails db:migrate
```

### Le bouton Contacts n'apparaît pas
1. Vérifiez que vous êtes connecté avec un compte PJ
2. Videz le cache du navigateur (Ctrl+Shift+Delete)
3. Rechargez la page

### Les contacts ne s'ajoutent pas
1. Vérifiez que le nom d'utilisateur exact est utilisé (case-sensitive)
2. Vérifiez que l'utilisateur existe dans la base de données
3. Regardez les logs du serveur pour les erreurs

## Déploiement

### En production

1. Exécutez la migration:
```bash
RAILS_ENV=production bin/rails db:migrate
```

2. Précompilez les assets:
```bash
RAILS_ENV=production bin/rails assets:precompile
```

3. Redémarrez l'application

## Rollback (si nécessaire)

```bash
# Annuler la migration
bin/rails db:rollback

# Cela supprimera la colonne 'contacts' de la table users
```

## Questions fréquentes

**Q: Puis-je ajouter le même contact deux fois?**
R: Non, le système l'empêche automatiquement.

**Q: Puis-je m'ajouter moi-même comme contact?**
R: Non, c'est bloquer à la source.

**Q: Les contacts persistants entre les sessions?**
R: Oui, ils sont stockés en base de données JSONB et persistent.

**Q: Puis-je exporter/importer mes contacts?**
R: Actuellement non, mais c'est envisageable pour une future amélioration.

## Support et améliorations futures

Pour signaler des bugs ou proposer des améliorations:
1. Vérifiez les logs du serveur
2. Consultez la documentation technique dans CONTACTS_FEATURE.md
3. Contactez l'administrateur système

## Changement récent (cohérence du code)

La vérification du groupe a été standardisée dans le contrôleur `HolonewsController`:
- **Avant**: Utilisait `current_user.group == 'MJ'`
- **Après**: Utilise `current_user.group.name == 'MJ'` (cohérent avec les vues)

Cela améliore la compatibilité et réduit les bugs potentiels.
