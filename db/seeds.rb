puts "Creating groups..."
group_mj = Group.find_or_create_by!(name: "MJ", description: "Le groupe des Maîtres du Jeu. Prosternez vous.")
group_pnj = Group.find_or_create_by!(name: "PNJ", description: "Le groupe des marchands et auxiliaires de jeu")
group_pj = Group.find_or_create_by!(name: "PJ", description: "Les joueurs jouent au jeu")
group_hackers = Group.find_or_create_by!(name: "Hackers", description: "Les hackers peuvent hacker les données des autres")

puts "Cleaning up obsolete test accounts..."
%w[Agent\ B-47 Technicien\ Comm Cantinier Droïde\ de\ Service Jawas].each do |obsolete_username|
  user = User.find_by("LOWER(username) = ?", obsolete_username.downcase)
  if user
    user.destroy
    puts "Deleted test account: #{obsolete_username}"
  end
end

puts "Renaming MJ Sylvain if needed..."
existing_mj = User.find_by("LOWER(username) = ?", "sylvain")
if existing_mj && existing_mj.group_id == group_mj.id
  existing_mj.update!(username: "MJ Sylvain")
  puts "Renamed MJ account 'Sylvain' to 'MJ Sylvain'"
end

puts "Creating MJ account..."
unless User.find_by("LOWER(username) = ?", "mj sylvain")
  User.create!(
    username: "MJ Sylvain",
    email: "mj@sw-gn.com",
    password: "adminsw",
    credits: 100000,
    group: group_mj
  )
  puts "MJ Sylvain créé"
end

puts "Creating PJ accounts (one per class)..."
# username = login_name (no accents), character_class = display label (with accents),
# password = login_name (no spaces, lowercase) + 2 random hardcoded digits.
pj_classes = [
  { username: "Technicienne", character_class: "Technicienne", password: "technicienne47" },
  { username: "Prospecteur",  character_class: "Prospecteur",  password: "prospecteur23" },
  { username: "Ascete",       character_class: "Ascète",       password: "ascete81" },
  { username: "Braconnier",   character_class: "Braconnier",   password: "braconnier56" },
  { username: "Senateur",     character_class: "Sénateur",     password: "senateur92" },
  { username: "Analyste",     character_class: "Analyste",     password: "analyste18" },
  { username: "Maitre Jedi",  character_class: "Maître Jedi",  password: "maitrejedi34" },
  { username: "Padawan",      character_class: "Padawan",      password: "padawan65" },
  { username: "Amiral",       character_class: "Amiral",       password: "amiral07" },
  { username: "Pilote",       character_class: "Pilote",       password: "pilote73" },
  { username: "Chasseur",     character_class: "Chasseur",     password: "chasseur29" }
]

pj_classes.each do |pj|
  email = "#{pj[:username].downcase.delete(' ')}@sw-gn.com"
  user = User.find_by("LOWER(username) = ?", pj[:username].downcase)
  if user
    user.update!(password: pj[:password], character_class: pj[:character_class])
  else
    User.create!(
      username: pj[:username],
      email: email,
      password: pj[:password],
      credits: 100,
      group: group_pj,
      character_class: pj[:character_class],
      character_name_chosen: false
    )
  end
  puts "PJ #{pj[:username]} (mot de passe: #{pj[:password]})"
end

# PJ pré-existants (avant la refactorisation) : on les considère comme déjà nommés
# pour ne pas les bloquer au login.
group_pj.users.where(character_class: nil).update_all(character_name_chosen: true)

puts "Creating PNJ accounts..."
# Hardcoded passwords (prénom sans accent + chiffres random) so the seed is reproducible.
pnj_accounts = [
  { username: "Marine",   real_first_name: "Marine",   password: "marine42",   characters: ["Twy'la"] },
  { username: "Brendan",  real_first_name: "Brendan",  password: "brendan87",  characters: ["Maitre Valeon Kalisteas", "Dali Marien"] },
  { username: "Elise",    real_first_name: "Elise",    password: "elise19",    characters: ["Kallyu Gray"] },
  { username: "Sylvain",  real_first_name: "Sylvain",  password: "sylvain63",  characters: ["Mankel Yvlada", "Dali Marien"] },
  { username: "Noe",      real_first_name: "Noé",      password: "noe742",     characters: ["Copper Barley", "Chancelier"] },
  { username: "Pia",      real_first_name: "Pia",      password: "pia519",     characters: ["Max Mayer"] },
  { username: "Aurelie",  real_first_name: "Aurélie",  password: "aurelie33",  characters: ["Siitra"] },
  { username: "Aurelien", real_first_name: "Aurélien", password: "aurelien04", characters: ["Lurba Dinguin"] }
]

pnj_accounts.each do |pnj|
  user = User.find_by("LOWER(username) = ?", pnj[:username].downcase)
  user ||= User.create!(
    username: pnj[:username],
    email: "#{pnj[:username].downcase}@sw-gn.com",
    password: pnj[:password],
    credits: 0,
    group: group_pnj,
    real_first_name: pnj[:real_first_name]
  )
  user.update!(real_first_name: pnj[:real_first_name]) if user.real_first_name != pnj[:real_first_name]
  puts "PNJ #{pnj[:username]} (mot de passe: #{pnj[:password]})"

  pnj[:characters].each do |character_name|
    npc = NpcCharacter.find_or_create_by!(name: character_name)
    NpcCharacterUser.find_or_create_by!(user: user, npc_character: npc)
  end
end

puts "Creating inventory objects..."

# Soins
[
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
].each do |item|
  InventoryObject.find_or_create_by!(name: item[:name]) do |obj|
    obj.category = item[:category]
    obj.price = item[:price]
    obj.description = item[:description]
    obj.rarity = item[:rarity]
  end
end

# Patchs
[
  { name: "Poisipatch", description: "Quand le porteur est empoisonné, le patch libère un antidote", price: 50, category: "patch" },
  { name: "Traumapatch", description: "Quand le porteur est blessé, le patch libère 1D PV de bacta", price: 50, category: "patch" },
  { name: "Stimpatch", description: "Quand le porteur est sonné, le stimpatch le stimule", price: 50, category: "patch" },
  { name: "Fibripatch", description: "Quand le porteur tombe agonisant, le patch le stabilise", price: 80, category: "patch" },
  { name: "Vigpatch", description: "Le porteur a +1DD à son prochain jet de dégâts Mains nues/AB", price: 100, category: "patch" },
  { name: "Focuspatch", description: "Quand le porteur fait moins de la moitié du max d'un jet de précision, +1D préci", price: 100, category: "patch" },
  { name: "Répercupatch", description: "Quand le porteur reçoit des dégâts, il gagne 1 action immédiate", price: 200, category: "patch" },
  { name: "Vitapatch", description: "Quand le porteur tombe agonisant, le patch le remet à 0 PV", price: 300, category: "patch" }
].each do |item|
  InventoryObject.find_or_create_by!(name: item[:name]) do |obj|
    obj.description = item[:description]
    obj.price = item[:price]
    obj.category = item[:category]
  end
end

# Ingrédients
[
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
].each do |item|
  InventoryObject.find_or_create_by!(name: item[:name]) do |obj|
    obj.price = item[:price]
    obj.description = item[:description]
    obj.rarity = item[:rarity]
    obj.category = "ingredient"
  end
end

# Processeurs
[
  { name: "Processeur basique (10)", price: 200, description: "Un processeur de base dont la vitesse permettra à la plupart des navordinateurs et droïdes de fonctionner", rarity: "Commun" },
  { name: "Processeur 12", price: 400, description: "Un processeur un peu amélioré, de façon à intégrer quelques fonctions plus poussées", rarity: "Commun" },
  { name: "Processeur 14", price: 600, description: "Un processeur plus puissant dont la vitesse permettra à des systèmes plus complexes de fonctionner", rarity: "Unco" },
  { name: "Processeur 16", price: 1500, description: "Un processeur très puissant qui conviendra pour faire tourner la plupart des systèmes", rarity: "Rare" },
  { name: "Processeur 18", price: 3000, description: "Un processeur rare d'une technologie de pointe dont la puissance énorme permet de gérer presque tout système", rarity: "Rare" },
  { name: "Processeur 20", price: 6000, description: "Un processeur rare et de très haute technologie dont la puissance extrême permet de gérer tout type de système", rarity: "Très rare" }
].each do |item|
  InventoryObject.find_or_create_by!(name: item[:name]) do |obj|
    obj.price = item[:price]
    obj.description = item[:description]
    obj.rarity = item[:rarity]
    obj.category = "processeur"
  end
end

# Animaux
[
  { name: "Sang de félin", price: 300, description: "Du sang de félin bien frais pour les expériences scientifiques", rarity: "Unco" },
  { name: "Hormone de rongeur", price: 300, description: "Des hormones spécifiques de rongeurs dédiées à la science", rarity: "Unco" },
  { name: "Cerveau de mammifère aquatique", price: 300, description: "Un cerveau frais disponible pour expérimentation", rarity: "Unco" },
  { name: "Yeux de rapace", price: 300, description: "Des yeux de rapaces conservés pour l'expérimentation scientifique", rarity: "Unco" },
  { name: "Sang de Dragon Krayt", price: 800, description: "Du sang de Dragon Krayt bouillonnant dans une éprouvette", rarity: "Rare" },
  { name: "Sang de Rancor", price: 800, description: "Du sang de Rancor bouillonnant dans une éprouvette", rarity: "Rare" }
].each do |item|
  InventoryObject.find_or_create_by!(name: item[:name]) do |obj|
    obj.price = item[:price]
    obj.description = item[:description]
    obj.rarity = item[:rarity]
    obj.category = "animal"
  end
end

# Plantes
[
  { name: "Cardamine", price: 30, description: "Une petite plante commune aux propriétés diurétiques, et toxique à haute dose", rarity: "Commun" },
  { name: "Kava", price: 50, description: "Une plante hallucinogène, aux effets réactifs divers en mélange avec d'autres plantes", rarity: "Commun" },
  { name: "Passiflore", price: 100, description: "Une famille de plantes peu commune, à très haute toxicité", rarity: "Unco" },
  { name: "Nysillin", price: 100, description: "Une famille de plantes peu communes, à vertu thérapeuthique", rarity: "Unco" }
].each do |item|
  InventoryObject.find_or_create_by!(name: item[:name]) do |obj|
    obj.price = item[:price]
    obj.description = item[:description]
    obj.rarity = item[:rarity]
    obj.category = "plante"
  end
end

# Injections
[
  { name: "Injection d'adrénaline", price: 200, description: "Perd 2 PV mais augmente les compétences de dex de +1D pour 3 tours", rarity: "Unco", category: "injection" },
  { name: "Injection d'hormone de Shalk", price: 300, description: "Perd 2 PV mais augmente les compétences de vig de +1D pour 3 tours", rarity: "Rare", category: "injection" },
  { name: "Injection de phosphore", price: 100, description: "Perd 2 PV mais augmente les compétences de sav de +1D pour 3 tours", rarity: "Unco", category: "injection" },
  { name: "Injection de focusféron", price: 100, description: "Perd 2 PV mais augmente les compétences de perc de +1D pour 3 tours", rarity: "Unco", category: "injection" },
  { name: "Injection de trinitine", price: 50, description: "Regagne +1D PV par tour pour 3 tours, mais -2 toutes comp", rarity: "Unco", category: "injection" },
  { name: "Injection de stimulant", price: 50, description: "Perd 2 PV mais est immunisé au statut désorienté ou sonné 3 tours", rarity: "Unco", category: "injection" },
  { name: "Injection de bio-rage", price: 400, description: "Folie 1D tours, +1DD au CaC, +1 action d'attaque par tour", rarity: "Rare", category: "injection" },
  { name: "Injection tétrasulfurée", price: 500, description: "Ne peut pas passer en statut sonné, inconscient ou agonisant 3 tours", rarity: "Rare", category: "injection" }
].each do |item|
  InventoryObject.find_or_create_by!(name: item[:name]) do |obj|
    obj.price = item[:price]
    obj.description = item[:description]
    obj.rarity = item[:rarity]
    obj.category = item[:category]
  end
end

# Gaz
[
  { name: "Gaz Lacrymogène", price: 50, description: "A le statut désorienté tant qu'il est exposé à l'arme", rarity: "Commun", category: "gaz" },
  { name: "Gaz Souffre", price: 100, description: "Perd 1D PV Ignore def / tour tant qu'il est exposé", rarity: "Commun", category: "gaz" },
  { name: "Gaz Empoisonné", price: 300, description: "Perd 2D PV Ignore def / tour tant qu'il est exposé + Empoisonné", rarity: "Unco", category: "gaz" },
  { name: "Gaz Neurolax", price: 500, description: "Perd 2D PV Ign def / tour tant qu'il est exposé + Tue les -20PVmax", rarity: "Rare", category: "gaz" }
].each do |item|
  InventoryObject.find_or_create_by!(name: item[:name]) do |obj|
    obj.price = item[:price]
    obj.description = item[:description]
    obj.rarity = item[:rarity]
    obj.category = item[:category]
  end
end

# Poisons
[
  { name: "Laxatif", price: 30, description: "Jet de vig pour résister au poison : 15 / Effets : -1DD au CaC et -1D précision à distance, -1PV / tour, 3/12 se chie dessus", rarity: "Commun", category: "poison" },
  { name: "Tranquilisant", price: 50, description: "Jet de vig pour résister au poison : 15 / Effets : -1D à tous ses jets, -1PV / tour, 1/12 s'endort", rarity: "Commun", category: "poison" },
  { name: "Somnifère", price: 50, description: "Jet de vig pour résister au poison : 20 / Effets : -1D à tous ses jets, -2PV / tour, 2/12 s'endort, 10/12 si 25PVmax", rarity: "Unco", category: "poison" },
  { name: "Poison", price: 100, description: "Jet de vig pour résister au poison : 15 / Effets : -1DPV / tour, 1/12 tombe inconscient", rarity: "Commun", category: "poison" },
  { name: "Poison neurotoxique", price: 200, description: "Jet de vig pour résister au poison : 20 / Effets : -1DPV / tour, 2/12 tombe inconscient", rarity: "Unco", category: "poison" },
  { name: "Poison foudroyant", price: 300, description: "Jet de vig pour résister au poison : 25 / Effets : -2DPV / tour, 4/12 tombe inconscient, 1/12 meurt", rarity: "Rare", category: "poison" },
  { name: "Stimulateur mnémonique", price: 300, description: "Jet de vig pour résister : 20 / Rend une personne très volubile, proche d'un sérum de vérité. +1D Comm, Intim, Psy sur elle", rarity: "Rare", category: "poison" }
].each do |item|
  InventoryObject.find_or_create_by!(name: item[:name]) do |obj|
    obj.price = item[:price]
    obj.description = item[:description]
    obj.rarity = item[:rarity]
    obj.category = item[:category]
  end
end

# Cartes Pazaak
puts "Creating Pazaak cards..."
pazaak_cards = []

(1..5).each do |i|
  pazaak_cards << { name: "+#{i}", price: 100, description: "Ajoute #{i} à votre total.", rarity: "Commun", category: "pazaak" }
  pazaak_cards << { name: "-#{i}", price: 100, description: "Retire #{i} à votre total.", rarity: "Commun", category: "pazaak" }
  pazaak_cards << { name: "±#{i}", price: 150, description: "Permet d'ajouter ou retirer #{i}.", rarity: "Inhabituel", category: "pazaak" }
end

pazaak_cards << { name: "x2", price: 200, description: "Double la valeur de la dernière carte jouée.", rarity: "Rare", category: "pazaak" }
pazaak_cards << { name: "2&4", price: 250, description: "Transforme tous les 2 et 4 en -2 et -4.", rarity: "Rare", category: "pazaak" }
pazaak_cards << { name: "3&6", price: 250, description: "Transforme tous les 3 et 6 en -3 et -6.", rarity: "Rare", category: "pazaak" }

pazaak_cards.each do |card|
  InventoryObject.find_or_create_by!(name: card[:name]) do |obj|
    obj.price = card[:price]
    obj.description = card[:description]
    obj.rarity = card[:rarity]
    obj.category = card[:category]
  end
end

puts "Creating repairs..."

Repair.find_or_create_by!(qr_token: "2e3641baadd26652") do |r|
  r.name = "Vaisseau"
  r.description = "Réparation du vaisseau"
  r.required_parts = ["Microprocesseur", "Valve d'électrocablage", "Rotobrosseur", "Commutateur ionique", "Rétropropulseur"]
  r.code = "146322317"
end

Repair.find_or_create_by!(qr_token: "b640510b9d12c8d9") do |r|
  r.name = "Cuve a bacta"
  r.description = "La cuve a bacta est endommagee et necessite le remplacement de sa bombonne pour fonctionner a nouveau."
  r.required_parts = ["Bombonne de bacta"]
  r.code = "256"
end

Repair.find_or_create_by!(qr_token: "570d88da272fddc3") do |r|
  r.name = "Cuve a bacta (2e reparation)"
  r.description = "La cuve a bacta necessite une seconde intervention. Un silanbloc electromagnetique doit etre insere pour stabiliser le systeme."
  r.required_parts = ["Silanbloc electromagnetique"]
  r.code = "239"
end

Repair.find_or_create_by!(qr_token: "c0b1d07871b6f6bf") do |r|
  r.name = "Tireuse a biere"
  r.description = "La tireuse a biere est hors service. Une demi-valve vibroide doit etre remplacee pour retablir le debit."
  r.required_parts = ["Demi-valve vibroide"]
  r.code = "51"
end

Repair.find_or_create_by!(qr_token: "fffa6e1037b13293") do |r|
  r.name = "Antenne de communication"
  r.description = "L'antenne de communication est defaillante. Plusieurs composants doivent etre remplaces pour restaurer les transmissions."
  r.required_parts = ["Communicateur ionique", "Carte mere avec programme de transmission", "Electro-rivet"]
  r.code = "3811612"
end

Repair.find_or_create_by!(qr_token: "2483577ff211e7d9") do |r|
  r.name = "Vaporateur"
  r.description = "Le vaporateur ne fonctionne plus. Le piston quantomagnetique doit etre remplace."
  r.required_parts = ["Piston quantomagnetique"]
  r.code = "434"
end

Repair.find_or_create_by!(qr_token: "85556390454417a8") do |r|
  r.name = "Four Entrique"
  r.description = "Le four entrique est en panne. La magneto-charniere doit etre remplacee."
  r.required_parts = ["Magneto-charniere"]
  r.code = "637"
end

puts "Seed terminé !"
