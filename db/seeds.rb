puts "Creating groups..."
group1 = Group.find_or_create_by!(name: "MJ", description: "Le groupe des Maîtres du Jeu. Prosternez vous.")
group2 = Group.find_or_create_by!(name: "PNJ", description: "Le groupe des marchands et auxiliaires de jeu")
group3 = Group.find_or_create_by!(name: "PJ", description: "Les joueurs jouent au jeu")
group4 = Group.find_or_create_by!(name: "Hackers", description: "Les hackers peuvent hacker les données des autres")

puts "Creating races..."
human = Race.find_or_create_by!(name: "Humain", description: "Une espèce polyvalente.")
kaminoan = Race.find_or_create_by!(name: "Kaminien", description: "Les bio-savants de Kamino.")
codruji = Race.find_or_create_by!(name: "Codru'Ji", description: "Les êtres à quatre bras de Munto Codru.")
toydarian = Race.find_or_create_by!(name: "Torydarien", description: "Les ingénieurs venus de Toydaria.")
clawdite = Race.find_or_create_by!(name: "Clawdite", description: "Les métamorphes de Zolan.")

puts "Creating classes..."
senator = ClassePerso.find_or_create_by!(name: "Sénateur", description: "Politicien influent.")
bio_savant = ClassePerso.find_or_create_by!(name: "Bio-savant", description: "Expert en sciences de la vie.")
autodidact = ClassePerso.find_or_create_by!(name: "Autodidacte", description: "Un apprenant autonome.")
mercenary = ClassePerso.find_or_create_by!(name: "Mercenaire", description: "Un combattant à louer.")
cyber_engineer = ClassePerso.find_or_create_by!(name: "Cyber-ingénieur", description: "Spécialiste des technologies avancées.")
smuggler = ClassePerso.find_or_create_by!(name: "Contrebandier", description: "Expert dans l'art de la contrebande.")
technicien = ClassePerso.find_or_create_by!(name: "Technicien", description: "Specialiste en reparation et maintenance d'equipements.")

puts "Creating statuses..."
statuses = [
  { name: "En forme", description: "En pleine santé", color: "#1EDD88" }, # Vert clair
  { name: "Empoisonné", description: "Empoisonné", color: "#7F00FF" }, # Violet
  { name: "Irradié", description: "Irradié par des radiations", color: "#FFD700" }, # Or
  { name: "Agonisant", description: "À l'agonie, proche de la mort", color: "#8B0000" }, # Rouge foncé
  { name: "Mort", description: "Le joueur est mort", color: "#A9A9A9" }, # Gris
  { name: "Inconscient", description: "Inconscient, dans le coma", color: "#808080" }, # Gris foncé
  { name: "Malade", description: "Affection commune", color: "#FF4500" }, # Orange foncé
  { name: "Maladie Virale", description: "Affection commune", color: "#FF4600" },
  { name: "Gravement Malade", description: "Affection grave", color: "#FF4700" },
  { name: "Paralysé", description: "Impossible de bouger", color: "#FF69B4" }, # Rose
  { name: "Sonné", description: "Désorienté", color: "#4682B4" }, # Bleu acier
  { name: "Aveugle", description: "Impossible de voir", color: "#000000" }, # Noir
  { name: "Sourd", description: "Impossible d'entendre", color: "#C0C0C0" }, # Argent
  { name: "Folie", description: "Ne se contrôle plus et attaque le plus proche", color: "#FF69B4" } # Rose
]

statuses.each do |status|
  Status.find_or_create_by!(status)
end

puts "Creating the users and assigning them to the corresponding groups, races, and classes..."

# Vérification pour le MJ
existing_mj = User.find_by("LOWER(username) = ?", "mj")
puts "MJ existant trouvé : #{existing_mj ? existing_mj.username : 'Aucun'}"

unless existing_mj
  puts "Création du MJ..."
  User.create!(
    username: "MJ",
    email: "mj@rpg.com",
    password: "adminsw",
    hp_max: 1000,
    hp_current: 1000,
    credits: 100000,
    group: group1
  )
  puts "MJ créé avec succès"
else
  puts "MJ déjà existant, passage..."
end

players = [
  { username: "Jarluc", email: "jarluc@rpg.com", race: human, classe_perso: senator, hp_max: 33, hp_current: 33, shield_max: 0, shield_current: 0, echani_shield_max: 0, echani_shield_current: 0, credits: 31650 },
  { username: "Kaey Noa", email: "kay@rpg.com", race: kaminoan, classe_perso: bio_savant, hp_max: 26, hp_current: 26, shield_max: 50, shield_current: 50, echani_shield_max: 50, echani_shield_current: 0, credits: 520 },
  { username: "Nuok", email: "nuok@rpg.com", race: codruji, classe_perso: autodidact, hp_max: 38, hp_current: 38, shield_max: 0, shield_current: 0, echani_shield_max: 0, echani_shield_current: 0, credits: 1110 },
  { username: "Pluto", email: "pluto@rpg.com", race: human, classe_perso: mercenary, hp_max: 34, hp_current: 34, shield_max: 50, shield_current: 50, echani_shield_max: 0, echani_shield_current: 0, credits: 0 },
  { username: "Viggo", email: "viggo@rpg.com", race: toydarian, classe_perso: cyber_engineer, hp_max: 22, hp_current: 22, shield_max: 50, echani_shield_max: 0, echani_shield_current: 0, credits: 14850 },
  { username: "Mas Tandor", email: "mas@rpg.com", race: clawdite, classe_perso: smuggler, hp_max: 21, hp_current: 21, shield_max: 20, shield_current: 20, echani_shield_max: 30, echani_shield_current: 30, credits: 8120 }
]

players.each do |player_attrs|
  # Recherche insensible à la casse
  existing_user = User.find_by("LOWER(username) = ?", player_attrs[:username].downcase)
  puts "Utilisateur #{player_attrs[:username]} existant : #{existing_user ? 'Oui' : 'Non'}"
  
  unless existing_user
    puts "Création de #{player_attrs[:username]}..."
    begin
      user = User.create!(
        username: player_attrs[:username],
        email: player_attrs[:email],
        password: "password",
        group: group3,
        race: player_attrs[:race],
        classe_perso: player_attrs[:classe_perso],
        hp_max: player_attrs[:hp_max],
        hp_current: player_attrs[:hp_current],
        shield_max: player_attrs[:shield_max],
        shield_current: player_attrs[:shield_current],
        echani_shield_max: player_attrs[:echani_shield_max],
        echani_shield_current: player_attrs[:echani_shield_current],
        credits: player_attrs[:credits]
      )
      # ✅ Utiliser set_status pour éviter les doublons potentiels
      user.set_status("En forme")
      puts "#{player_attrs[:username]} créé avec succès"
    rescue ActiveRecord::RecordInvalid => e
      puts "Erreur lors de la création de #{player_attrs[:username]}: #{e.message}"
      # Vérifier s'il y a des doublons
      puts "Utilisateurs avec username similaire: #{User.where("username ILIKE ?", "%#{player_attrs[:username]}%").pluck(:username, :email)}"
      puts "Utilisateurs avec email similaire: #{User.where("email ILIKE ?", "%#{player_attrs[:email]}%").pluck(:username, :email)}"
      raise e
    end
  else
    puts "#{player_attrs[:username]} déjà existant, passage..."
  end
end

# Agent B-47 (Technicien pour les reparations)
existing_b47 = User.find_by("LOWER(username) = ?", "agent b-47")
unless existing_b47
  puts "Création de Agent B-47..."
  User.create!(
    username: "Agent B-47",
    email: "agentb47@rpg.com",
    password: "password",
    group: group3,
    credits: 100
  )
  puts "Agent B-47 créé avec succès"
else
  puts "Agent B-47 déjà existant, passage..."
end

puts "Adding new skills..."

puts "🛠️ Création des caractéristiques..."

carac_names = %w[Vigueur Dextérité Perception Savoir Technique Mécanique]
carac_names.each do |name|
  Carac.find_or_create_by!(name: name)
end

puts "✅ Caractéristiques créées."

puts "📌 Création et mise à jour des compétences..."

# Liste des compétences sans duplication
skills_list = [
  "Vitesse", "Précision", "Esquive", "Ingénierie", "Médecine", "Résistance Corporelle",
  "Sabre-laser", "Arts martiaux", "Armes blanches", "Lancer", "Tir", "Discrétion", "Habileté",
  "Observation", "Intuition", "Imitation", "Psychologie", "Commandement", "Marchandage",
  "Persuasion", "Sang Froid", "Dressage", "Saut", "Escalade", "Endurance", "Intimidation", "Natation",
  "Survie", "Nature", "Substances", "Savoir jedi", "Langage", "Astrophysique", "Planètes",
  "Evaluation", "Illégalité", "Pilotage", "Esquive spatiale", "Astrogation", "Tourelles",
  "Jetpack", "Réparation", "Sécurité", "Démolition", "Systèmes", "Contrôle", "Sens", "Altération",
  "Coque", "Ecrans", "Maniabilité"
]

skills_list.each do |skill_name|
  Skill.find_or_create_by!(name: skill_name) do |s|
    s.description = "" # Description vide pour l'instant
  end
end

# Ajout des senseurs comme compétences sans carac associée
['Senseurs passifs', 'Senseurs détection', 'Senseurs recherche', 'Senseurs focalisation'].each do |senseur|
  Skill.find_or_create_by!(name: senseur) do |s|
    s.description = "Senseur du vaisseau"
    s.carac = nil
  end
end

puts "✅ Compétences créées ou mises à jour."

puts "🔗 Association des compétences aux caractéristiques..."

skills_caracs = {
  "Vitesse" => "Dextérité",
  "Précision" => "Dextérité",
  "Esquive" => "Dextérité",
  "Sabre-laser" => "Dextérité",
  "Arts martiaux" => "Dextérité",
  "Armes blanches" => "Dextérité",
  "Lancer" => "Dextérité",
  "Tir" => "Dextérité",
  "Discrétion" => "Dextérité",
  "Habileté" => "Dextérité",

  "Observation" => "Perception",
  "Intuition" => "Perception",
  "Imitation" => "Perception",
  "Psychologie" => "Perception",
  "Commandement" => "Perception",
  "Marchandage" => "Perception",
  "Persuasion" => "Perception",
  "Dressage" => "Perception",
  "Sang Froid" => "Perception",

  "Saut" => "Vigueur",
  "Escalade" => "Vigueur",
  "Endurance" => "Vigueur",
  "Intimidation" => "Vigueur",
  "Natation" => "Vigueur",
  "Survie" => "Vigueur",

  "Nature" => "Savoir",
  "Substances" => "Savoir",
  "Savoir jedi" => "Savoir",
  "Langage" => "Savoir",
  "Astrophysique" => "Savoir",
  "Planètes" => "Savoir",
  "Evaluation" => "Savoir",
  "Illégalité" => "Savoir",
  "Médecine" => "Savoir",

  "Pilotage" => "Mécanique",
  "Esquive spatiale" => "Mécanique",
  "Astrogation" => "Mécanique",
  "Tourelles" => "Mécanique",
  "Jetpack" => "Mécanique",

  "Ingénierie" => "Technique",
  "Réparation" => "Technique",
  "Sécurité" => "Technique",
  "Démolition" => "Technique",
  "Systèmes" => "Technique",
}

skills_caracs.each do |skill_name, carac_name|
  skill = Skill.find_by(name: skill_name)
  carac = Carac.find_by(name: carac_name)
  if skill && carac
    skill.update!(carac: carac)
  else
    puts "❌ Problème d'association : #{skill_name} → #{carac_name}" unless skill && carac
  end
end

puts "✅ New skills added successfully!"

puts "Adding new implants..."
# Liste des implants
implants = [
  { name: "Implant de vitalité", price: 400, description: "Implant lvl 1 ajoutant +5 Pvmax temporaires tant que l'implant est porté", rarity: "Commun", category: "implant" },
  { name: "Implant de vitalité +", price: 1000, description: "Implant lvl 2 ajoutant +10 Pvmax temporaires tant que l'implant est porté", rarity: "Unco", category: "implant" },
  { name: "Implant de récupération", price: 600, description: "Implant lvl 1 permettant de récupérer +1PV à chaque début de tour", rarity: "Commun", category: "implant" },
  { name: "Implant de récupération +", price: 1200, description: "Implant lvl 2 permettant de récupérer +2PV à chaque début de tour", rarity: "Unco", category: "implant" },
  { name: "Implant de comm neurale", price: 500, description: "Implant lvl 1 permettant de communiquer par la pensée avec un autre cyborg", rarity: "Commun", category: "implant" }
]

# Création ou mise à jour des implants dans la base de données
implants.each do |implant|
  InventoryObject.find_or_create_by!(name: implant[:name]) do |obj|
    obj.price = implant[:price]
    obj.description = implant[:description]
    obj.rarity = implant[:rarity]
    obj.category = implant[:category]
  end
end

skills = Skill.all
skills.each do |skill|
  # Implant ajoutant +1 à la compétence
  InventoryObject.find_or_create_by!(
    name: "Implant de #{skill.name} +1"
  ) do |object|
    object.price = 200
    object.description = "Ajoute +1 à la compétence #{skill.name} tant que l'implant est porté."
    object.rarity = "Commun"
    object.category = "implant"
  end

  # Implant ajoutant +2 à la compétence
  InventoryObject.find_or_create_by!(
    name: "Implant de #{skill.name} +2"
  ) do |object|
    object.price = 500
    object.description = "Ajoute +2 à la compétence #{skill.name} tant que l'implant est porté."
    object.rarity = "Unco"
    object.category = "implant"
  end

  # Implant ajoutant +1D à la compétence
  InventoryObject.find_or_create_by!(
    name: "Implant de #{skill.name} +1D"
  ) do |object|
    object.price = 1500
    object.description = "Ajoute +1D à la compétence #{skill.name} tant que l'implant est porté."
    object.rarity = "Rare"
    object.category = "implant"
  end
end

puts "✅ New implants added successfully!"

puts "Creating healing inventory objects..."
inventory_objects = [
  { name: "Medipack", category: "soins", price: 50, description: "Redonne en PV le jet de médecine du soigneur divisé par deux.", rarity: "Commun" },
  { name: "Medipack +", category: "soins", price: 200, description: "Redonne en PV le jet de médecine du soigneur divisé par deux +1D", rarity: "Unco" },
  { name: "Medipack Deluxe", category: "soins", price: 500, description: "Redonne en PV le plein jet de médecine du soigneur", rarity: "Rare" },
  { name: "Antidote", category: "soins", price: 200, description: "Soigne le statut empoisonné, +1D PV", rarity: "Unco" },
  { name: "Extrait de Nysillin", category: "soins", price: 150, description: "Plante soignante de Félucia: +2D PV immédiat en action de soutien", rarity: "Unco" },
  { name: "Baume de Kolto", category: "soins", price: 800, description: "Baume miraculeux disparu de Manaan. +4D PV immédiat action soutien", rarity: "Très rare" },
  { name: "Sérum de Thyffera", category: "soins", price: 300, description: "Guérit les maladies communes", rarity: "Commun" },
  { name: "Rétroviral kallidahin", category: "soins", price: 500, description: "Guérit les maladies virales communes", rarity: "Commun" },
  { name: "Draineur de radiations", category: "soins", price: 1000, description: "Guérit la radioactivité", rarity: "Unco" },
  { name: "Trompe-la-mort", category: "soins", price: 2000, description: "Soigne +2D PV à qqun passé sous -10 PV il y a – de 2 tours", rarity: "Rare" },
  { name: "Homéopathie", category: "soins", price: 0, description: "Soigne intégralement un personnage qui est à 5 PV ou moins de son maximum", rarity: "Don" },
  { name: "Kit de réparation", category: "soins", price: 100, description: "Kit permettant de réparer les vaisseaux. Nécessite 1-3 composants aléatoirement.", rarity: "Commun" }
]

inventory_objects.each do |item|
  InventoryObject.find_or_create_by!(name: item[:name]) do |obj|
    obj.category = item[:category]
    obj.price = item[:price]
    obj.description = item[:description]
    obj.rarity = item[:rarity]
  end
end

patches = [
  { name: "Poisipatch", description: "Quand le porteur est empoisonné, le patch libère un antidote", price: 50, category: "patch" },
  { name: "Traumapatch", description: "Quand le porteur est blessé, le patch libère 1D PV de bacta", price: 50, category: "patch" },
  { name: "Stimpatch", description: "Quand le porteur est sonné, le stimpatch le stimule", price: 50, category: "patch" },
  { name: "Fibripatch", description: "Quand le porteur tombe agonisant, le patch le stabilise", price: 80, category: "patch" },
  { name: "Vigpatch", description: "Le porteur a +1DD à son prochain jet de dégâts Mains nues/AB", price: 100, category: "patch" },
  { name: "Focuspatch", description: "Quand le porteur fait moins de la moitié du max d'un jet de précision, +1D préci", price: 100, category: "patch" },
  { name: "Répercupatch", description: "Quand le porteur reçoit des dégâts, il gagne 1 action immédiate", price: 200, category: "patch" },
  { name: "Vitapatch", description: "Quand le porteur tombe agonisant, le patch le remet à 0 PV", price: 300, category: "patch" }
]

patches.each do |patch|
  InventoryObject.find_or_create_by!(name: patch[:name]) do |p|
    p.description = patch[:description]
    p.price = patch[:price]
    p.category = patch[:category]
  end
end

puts "✅ Les patchs ont été ajoutés à la base de données."

puts "Adding inventory objects of category 'ingredient'..."

ingredients = [
  { name: "Composant", price: 10, description: "Une pièce basique pour fabriquer ou réparer des objets techniques divers. Se trouve partout", rarity: "Commun" },
  { name: "Transmetteur", price: 50, description: "Le transmetteur est une pièce commune qui permet la transmission d'informations par ondes", rarity: "Commun" },
  { name: "Répartiteur", price: 50, description: "Le répartiteur est une pièce commune qui assure la redistribution de l'énergie", rarity: "Commun" },
  { name: "Répercuteur", price: 100, description: "Le répercuteur est une pièce commune qui permet d'amorcer des systèmes complexes", rarity: "Commun" },
  { name: "Circuit de retransmission", price: 200, description: "Fabriqué par le fabricant à base de 2 compos et 1 transmetteur, le circuit permet d'améliorer la connectique", rarity: "Commun" },
  { name: "Répartiteur fuselé", price: 200, description: "Fabriqué par le fabricant à base de 2 compos et 1 répartiteur, le rép. fuselé redistribue mieux l'énergie", rarity: "Commun" },
  { name: "Convecteur thermique", price: 300, description: "Le convecteur thermique est une pièce peu commune qui a pour fonction la concentration d'énergie", rarity: "Unco" },
  { name: "Senseur", price: 200, description: "Le senseur est une pièce peu commune qui a de multiples paramètres de détection par balayage d'ondes", rarity: "Unco" },
  { name: "Fuseur", price: 400, description: "Le fuseur est une pièce peu commune qui sert à fusionner des particules instables d'énergie", rarity: "Unco" },
  { name: "Propulseur", price: 400, description: "Le propulseur est une pièce peu commune dédiée aux systèmes de propulsion", rarity: "Unco" },
  { name: "Vibro-érecteur", price: 500, description: "Fabriqué avec 2 compos + 1 répercuteur + 1 circ de retr + 1 rép fuselé, sert à activer des puissants systèmes", rarity: "Unco" },
  { name: "Commandes", price: 1000, description: "Les commandes sont une pièce rare qui consiste en une interface de contrôle de systèmes complexes", rarity: "Rare" },
  { name: "Injecteur de photon", price: 2000, description: "L'injecteur de photon est une pièce rare qui sert à la transmission d'énergie dans la technologie de pointe", rarity: "Rare" },
  { name: "Chrysalis", price: 5000, description: "La chrysalis est une pièce très rare, qui catalyse l'énergie du vide pour l'alimentation en énergie", rarity: "Très rare" },
  { name: "Vibreur", price: 200, description: "Le vibreur est une pièce commune qui concentre l'énergie par émission d'ondes vibratoires", rarity: "Commun" },
  { name: "Micro-générateur", price: 300, description: "Le micro-générateur est une pièce commune qui assure l'apport en énergie dans la micro-ingénierie", rarity: "Commun" },
  { name: "Synthé-gilet", price: 200, description: "Nécessaire pour crafter différents types d'améliorations d'armures", rarity: "Commun" },
  { name: "Interface cyber", price: 500, description: "L'interface cyber est une pièce peu commune qui sert à créer une interface homme / machine", rarity: "Unco" },
  { name: "Pile à protons", price: 800, description: "La pile à protons une pièce rare qui sert à capter les particules de protons environnantes", rarity: "Rare" },
  { name: "Lingot de Phrik", price: 500, description: "Le lingot de phrik est un échantillon peu commun d'un métal résistant", rarity: "Unco" },
  { name: "Filet de Lommite", price: 1000, description: "Le filet de lommite est un échantillon rare d'un métal très résistant", rarity: "Rare" },
  { name: "Lingot de Duracier", price: 3000, description: "Le lingot de duracier est un alliage très rare et extrêmement résistant", rarity: "Très rare" },
  { name: "Fiole", price: 30, description: "Un contenant pour diverses préparations de potions et poisons", rarity: "Commun" },
  { name: "Matière organique", price: 80, description: "Un substras de matière organique amalgamée", rarity: "Commun" },
  { name: "Dose de bacta", price: 100, description: "Une dose de bacta, cette substance régénératrice utilisée dans les medipacks et cuves à bacta", rarity: "Unco" },
  { name: "Dose de kolto", price: 300, description: "Une dose de kolto, une substance régénératrice rare et très efficace", rarity: "Rare" },
  { name: "Jeu d'éprouvettes", price: 50, description: "Un simple jeu d'éprouvettes pour l'artisanat du biosavant", rarity: "Commun" },
  { name: "Pique chirurgicale", price: 300, description: "Une pique chirurgicale à usage unique pour les manipulations techniques difficiles du biosavant", rarity: "Unco" },
  { name: "Diffuseur aérosol", price: 100, description: "Un diffuseur aérosol à ouverture manuelle ou retardée, pour y mettre des choses méchantes à diffuser dedans", rarity: "Unco" },
  { name: "Matière explosive", price: 200, description: "La matière explosive est une matière malléable et adaptable, qui sert à la fabrication d'explosifs", rarity: "Commun" },
  { name: "Poudre de Zabron", price: 100, description: "La poudre de zabron est issu d'un sable très volatile qui se disperse en de grandes volutes de fumée rose", rarity: "Commun" },
  { name: "Neurotoxique", price: 300, description: "Une substance neurotoxique particulièrement dangereuse", rarity: "Rare" }
]

ingredients.each do |ingredient|
  InventoryObject.find_or_create_by!(name: ingredient[:name]) do |obj|
    obj.price = ingredient[:price]
    obj.description = ingredient[:description]
    obj.rarity = ingredient[:rarity]
    obj.category = "ingredient"
  end
end

# Section ingrédients déjà créée ci-dessus, pas besoin de la dupliquer

# Processors
processors = [
  { name: "Processeur basique (10)", price: 200, description: "Un processeur de base dont la vitesse permettra à la plupart des navordinateurs et droïdes de fonctionner", rarity: "Commun" },
  { name: "Processeur 12", price: 400, description: "Un processeur un peu amélioré, de façon à intégrer quelques fonctions plus poussées", rarity: "Commun" },
  { name: "Processeur 14", price: 600, description: "Un processeur plus puissant dont la vitesse permettra à des systèmes plus complexes de fonctionner", rarity: "Unco" },
  { name: "Processeur 16", price: 1500, description: "Un processeur très puissant qui conviendra pour faire tourner la plupart des systèmes", rarity: "Rare" },
  { name: "Processeur 18", price: 3000, description: "Un processeur rare d'une technologie de pointe dont la puissance énorme permet de gérer presque tout système", rarity: "Rare" },
  { name: "Processeur 20", price: 6000, description: "Un processeur rare et de très haute technologie dont la puissance extrême permet de gérer tout type de système", rarity: "Très rare" }
]

processors.each do |processor|
  InventoryObject.find_or_create_by!(name: processor[:name]) do |obj|
    obj.price = processor[:price]
    obj.description = processor[:description]
    obj.rarity = processor[:rarity]
    obj.category = "processeur"
  end
end

# Animals
animals = [
  { name: "Sang de félin", price: 300, description: "Du sang de félin bien frais pour les expériences scientifiques", rarity: "Unco" },
  { name: "Hormone de rongeur", price: 300, description: "Des hormones spécifiques de rongeurs dédiées à la science", rarity: "Unco" },
  { name: "Cerveau de mammifère aquatique", price: 300, description: "Un cerveau frais disponible pour expérimentation", rarity: "Unco" },
  { name: "Yeux de rapace", price: 300, description: "Des yeux de rapaces conservés pour l'expérimentation scientifique", rarity: "Unco" },
  { name: "Sang de Dragon Krayt", price: 800, description: "Du sang de Dragon Krayt bouillonnant dans une éprouvette", rarity: "Rare" },
  { name: "Sang de Rancor", price: 800, description: "Du sang de Rancor bouillonnant dans une éprouvette", rarity: "Rare" }
]

animals.each do |animal|
  InventoryObject.find_or_create_by!(name: animal[:name]) do |obj|
    obj.price = animal[:price]
    obj.description = animal[:description]
    obj.rarity = animal[:rarity]
    obj.category = "animal"
  end
end

# Plants
plants = [
  { name: "Cardamine", price: 30, description: "Une petite plante commune aux propriétés diurétiques, et toxique à haute dose", rarity: "Commun" },
  { name: "Kava", price: 50, description: "Une plante hallucinogène, aux effets réactifs divers en mélange avec d'autres plantes", rarity: "Commun" },
  { name: "Passiflore", price: 100, description: "Une famille de plantes peu commune, à très haute toxicité", rarity: "Unco" },
  { name: "Nysillin", price: 100, description: "Une famille de plantes peu communes, à vertu thérapeuthique", rarity: "Unco" }
]

plants.each do |plant|
  InventoryObject.find_or_create_by!(name: plant[:name]) do |obj|
    obj.price = plant[:price]
    obj.description = plant[:description]
    obj.rarity = plant[:rarity]
    obj.category = "plante"
  end
end

injections = [
  { name: "Injection d'adrénaline", price: 200, description: "Perd 2 PV mais augmente les compétences de dex de +1D pour 3 tours", rarity: "Unco", category: "injection" },
  { name: "Injection d'hormone de Shalk", price: 300, description: "Perd 2 PV mais augmente les compétences de vig de +1D pour 3 tours", rarity: "Rare", category: "injection" },
  { name: "Injection de phosphore", price: 100, description: "Perd 2 PV mais augmente les compétences de sav de +1D pour 3 tours", rarity: "Unco", category: "injection" },
  { name: "Injection de focusféron", price: 100, description: "Perd 2 PV mais augmente les compétences de perc de +1D pour 3 tours", rarity: "Unco", category: "injection" },
  { name: "Injection de trinitine", price: 50, description: "Regagne +1D PV par tour pour 3 tours, mais -2 toutes comp", rarity: "Unco", category: "injection" },
  { name: "Injection de stimulant", price: 50, description: "Perd 2 PV mais est immunisé au statut désorienté ou sonné 3 tours", rarity: "Unco", category: "injection" },
  { name: "Injection de bio-rage", price: 400, description: "Folie 1D tours, +1DD au CaC, +1 action d'attaque par tour", rarity: "Rare", category: "injection" },
  { name: "Injection tétrasulfurée", price: 500, description: "Ne peut pas passer en statut sonné, inconscient ou agonisant 3 tours", rarity: "Rare", category: "injection" }
]

injections.each do |injection|
  InventoryObject.find_or_create_by!(name: injection[:name]) do |obj|
    obj.price = injection[:price]
    obj.description = injection[:description]
    obj.rarity = injection[:rarity]
    obj.category = injection[:category]
  end
end

chemical_weapons = [
  { name: "Gaz Lacrymogène", price: 50, description: "A le statut désorienté tant qu'il est exposé à l'arme", rarity: "Commun", category: "gaz" },
  { name: "Gaz Souffre", price: 100, description: "Perd 1D PV Ignore def / tour tant qu'il est exposé", rarity: "Commun", category: "gaz" },
  { name: "Gaz Empoisonné", price: 300, description: "Perd 2D PV Ignore def / tour tant qu'il est exposé + Empoisonné", rarity: "Unco", category: "gaz" },
  { name: "Gaz Neurolax", price: 500, description: "Perd 2D PV Ign def / tour tant qu'il est exposé + Tue les -20PVmax", rarity: "Rare", category: "gaz" }
]

chemical_weapons.each do |weapon|
  InventoryObject.find_or_create_by!(name: weapon[:name]) do |obj|
    obj.price = weapon[:price]
    obj.description = weapon[:description]
    obj.rarity = weapon[:rarity]
    obj.category = weapon[:category]
  end
end

poisons = [
  { name: "Laxatif", price: 30, description: "Jet de vig pour résister au poison : 15 / Effets : -1DD au CaC et -1D précision à distance, -1PV / tour, 3/12 se chie dessus", rarity: "Commun", category: "poison" },
  { name: "Tranquilisant", price: 50, description: "Jet de vig pour résister au poison : 15 / Effets : -1D à tous ses jets, -1PV / tour, 1/12 s'endort", rarity: "Commun", category: "poison" },
  { name: "Somnifère", price: 50, description: "Jet de vig pour résister au poison : 20 / Effets : -1D à tous ses jets, -2PV / tour, 2/12 s'endort, 10/12 si 25PVmax", rarity: "Unco", category: "poison" },
  { name: "Poison", price: 100, description: "Jet de vig pour résister au poison : 15 / Effets : -1DPV / tour, 1/12 tombe inconscient", rarity: "Commun", category: "poison" },
  { name: "Poison neurotoxique", price: 200, description: "Jet de vig pour résister au poison : 20 / Effets : -1DPV / tour, 2/12 tombe inconscient", rarity: "Unco", category: "poison" },
  { name: "Poison foudroyant", price: 300, description: "Jet de vig pour résister au poison : 25 / Effets : -2DPV / tour, 4/12 tombe inconscient, 1/12 meurt", rarity: "Rare", category: "poison" },
  { name: "Stimulateur mnémonique", price: 300, description: "Jet de vig pour résister : 20 / Rend une personne très volubile, proche d'un sérum de vérité. +1D Comm, Intim, Psy sur elle", rarity: "Rare", category: "poison" }
]

poisons.each do |poison|
  InventoryObject.find_or_create_by!(name: poison[:name]) do |obj|
    obj.price = poison[:price]
    obj.description = poison[:description]
    obj.rarity = poison[:rarity]
    obj.category = poison[:category]
  end
end

pazaak_cards = []

# Cartes positives +1 à +5
(1..5).each do |i|
  pazaak_cards << {
    name: "+#{i}",
    price: 100,
    description: "Ajoute #{i} à votre total.",
    rarity: "Commun",
    category: "pazaak"
  }
end

# Cartes négatives -1 à -5
(1..5).each do |i|
  pazaak_cards << {
    name: "-#{i}",
    price: 100,
    description: "Retire #{i} à votre total.",
    rarity: "Commun",
    category: "pazaak"
  }
end

# Cartes duales ±1 à ±5
(1..5).each do |i|
  pazaak_cards << {
    name: "±#{i}",
    price: 150,
    description: "Permet d'ajouter ou retirer #{i}.",
    rarity: "Inhabituel",
    category: "pazaak"
  }
end

# Carte spéciale x2
pazaak_cards << {
  name: "x2",
  price: 200,
  description: "Double la valeur de la dernière carte jouée.",
  rarity: "Rare",
  category: "pazaak"
}

# Carte spéciale 2&4
pazaak_cards << {
  name: "2&4",
  price: 250,
  description: "Transforme tous les 2 et 4 en -2 et -4.",
  rarity: "Rare",
  category: "pazaak"
}

# Carte spéciale 3&6
pazaak_cards << {
  name: "3&6",
  price: 250,
  description: "Transforme tous les 3 et 6 en -3 et -6.",
  rarity: "Rare",
  category: "pazaak"
}

# Création dans la base
pazaak_cards.each do |card|
  InventoryObject.find_or_create_by!(name: card[:name]) do |obj|
    obj.price = card[:price]
    obj.description = card[:description]
    obj.rarity = card[:rarity]
    obj.category = card[:category]
  end
end

puts "✅ New objects added successfully!"

puts "Adding new base..."

Headquarter.find_or_create_by!(name: "Nom de la base", location: "Planète inconnue", credits: 0, description: "Aucune description pour l'instant.")

puts "✅ New base added successfully!"

puts "📦 Création des bâtiments par défaut..."

headquarter = Headquarter.first_or_create!(name: "Base Célestiale", location: "Mobile - Bordure Extérieure", credits: 0, description: "Une mystérieuse base très ancienne")

if Building::BUILDING_DATA.nil?
  puts "⚠️ Erreur : Impossible de charger les données des bâtiments !"
  exit
end

Building::BUILDING_DATA.each do |building_type, levels|
  levels.each do |level, data|
    level = level.to_i 

    building = headquarter.buildings.find_or_initialize_by(name: data["name"])

    building.update!(
      level: 0,
      description: data["description"],
      price: data["price"],
      category: building_type,
      properties: data["properties"] || {}
    )

    puts "✅ Bâtiment ajouté : #{building.name} (Niveau #{building.level})"
  end
end

puts "✅ Bâtiments créés avec succès."

puts "📦 Création des systèmes de défense..."

defenses = [
  { name: "Système d'alarme", description: "Des systèmes d'alarme retentissant automatiquement en cas d'attaque. +1 défense", price: 1000, bonus: 1 },
  { name: "Système de défense interne", description: "Tourelles automatiques et semi-automatiques pour protéger l'intérieur. +1 défense", price: 5000, bonus: 1 },
  { name: "Pièges internes", description: "Des pièges ingénieux parsèment la base. +1 défense", price: 3000, bonus: 1 },
  { name: "Pulso blaster sol/air", description: "Défense anti-aérienne contre les vaisseaux ennemis. +2 défense", price: 10000, bonus: 2 },
  { name: "Pulso blaster sol/sol", description: "Pulso-blaster pour contrer les troupes terrestres. +2 défense", price: 12000, bonus: 2 },
  { name: "Canons à ions", description: "Système avancé de défense anti-vaisseaux. +2 défense", price: 30000, bonus: 2 },
  { name: "Station orbitale", description: "Poste avancé d'observation et défense spatiale. +3 défense", price: 80000, bonus: 3 },
  { name: "Drones", description: "Défense basée sur des droïdes autonomes. +3 défense", price: 100000, bonus: 3 },
  { name: "Boucliers", description: "Protège des assauts énergétiques. +2 défense", price: 50000, bonus: 2 },
  { name: "Renforcement des murs", description: "Améliore la résistance aux attaques. +1 défense", price: 10000, bonus: 1 }
]

defenses.each do |defense|
  Defense.find_or_create_by!(name: defense[:name]) do |d|
    d.description = defense[:description]
    d.price = defense[:price]
    d.bonus = defense[:bonus]
  end
end

puts "✅ Systèmes de défense ajoutés avec succès."

