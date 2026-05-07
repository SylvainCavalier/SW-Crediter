class SendSubsidyHolonewJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find_by(id: user_id)
    return unless user

    # Trouver ou créer un utilisateur "système" pour la République
    republic_sender = User.find_by(username: "République Galactique")
    # Fallback : utiliser le premier admin/MJ disponible, ou l'utilisateur lui-même
    republic_sender ||= User.first

    Holonew.create!(
      title: "ANOMALIE DÉTECTÉE — Dossier de subvention n°#{SecureRandom.hex(4).upcase}",
      content: "**BUREAU DES ALLOCATIONS BUDGÉTAIRES DU SECTEUR EXTERNE**\n" \
               "**Division du Contrôle et de la Conformité Financière**\n" \
               "Coruscant — District Fédéral du Sénat\n\n" \
               "Citoyen(ne) #{user.display_username},\n\n" \
               "Suite au traitement de votre demande de subvention républicaine " \
               "(Formulaire GR-7742-B/rev.38), nos services ont détecté une **anomalie de conformité** " \
               "dans votre dossier.\n\n" \
               "Conformément à l'Article 2247-F du Code Administratif Galactique et à la " \
               "Circulaire n°88-A/bis du Bureau de Vérification Fiscale Inter-Systèmes, " \
               "vous êtes prié(e) de vous présenter **en personne** au Bureau des Allocations " \
               "Budgétaires de la République, bâtiment Aurek-7, niveau 4287, Coruscant, " \
               "pour une **inspection et un redressement** de votre situation administrative.\n\n" \
               "Veuillez vous munir des documents suivants :\n" \
               "- Votre Numéro d'Identification Galactique (original holographique)\n" \
               "- Les 3 derniers relevés de votre compte de crédits républicains\n" \
               "- Une attestation de domicile datant de moins de 2 cycles standards\n" \
               "- Le formulaire GR-7742-B/rev.38 original dûment rempli (en triple exemplaire)\n\n" \
               "Le non-respect de cette convocation dans un délai de 30 rotations standards " \
               "entraînera l'application automatique des pénalités prévues par le Décret Exécutif 1138-C, " \
               "pouvant aller jusqu'à la saisie intégrale de vos avoirs.\n\n" \
               "Que la Force de l'Administration soit avec vous.\n\n" \
               "*Bureau des Allocations Budgétaires — Ne pas répondre à ce message.*",
      sender: republic_sender,
      sender_alias: "République Galactique",
      target_user: user.id
    )
  end
end
