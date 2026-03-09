import 'app_localizations.dart';

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get welcome => 'Bienvenue sur DigiXpense';
  @override
  String get dashboard => 'Tableau de bord';

  @override
  String get myDashboard => 'Mon tableau de bord';
  @override
  String get login => 'Connexion';
@override
  String get punchInOut => 'Pointage Entrée/Sortie';
  
  @override
  String get punchInOutList => 'Liste de pointage';
  
  @override
  String get myTeamAttendance => 'Présence de mon équipe';
  
  @override
  String get timesheets => 'Feuilles de temps';
  
  @override
  String get myTeamTimesheets => 'Feuilles de temps de mon équipe';
  
  @override
  String get payroll => 'Paie';
  
  @override
  String get myPayslips => 'Mes bulletins de paie';
  
  @override
  String get allPayslips => 'Tous les bulletins de paie';
   
  @override
  String get leaveCancellation => 'Annulation de congé';
   // New strings
  @override
  String get fullyCancel => 'Annulation complète';
  
  @override
  String get partialCancel => 'Annulation partielle';
  
  @override
  String get cardView => 'Vue carte';
  
  @override
  String get calendarView => 'Vue calendrier';
  
  @override
  String get month => 'Mois';
  
  @override
  String get week => 'Semaine';
  
  @override
  String get day => 'Jour';
  @override
  String get myTimesheets => 'Mes feuilles de temps';
  @override
  String get board => 'Tableau';
  @override
  String get setting => 'Paramètres';
  @override
  String get firstName => 'Prénom';
  @override
  String get middleName => 'Deuxième prénom';
  @override
  String get lastName => 'Nom de famille';
  @override
  String get personalMailId => 'Adresse e-mail personnelle';
  @override
  String get phoneNumber => 'Numéro de téléphone';
  @override
  String get gender => 'Genre';
  @override
  String get permanentAddress => 'Adresse permanente';
  @override
  String get street => 'Rue';
  @override
  String get city => 'Ville';
  @override
  String get searchCountry => 'Rechercher un pays';
  @override
  String get searchState => 'Rechercher un État';
  @override
  String get zipCode => 'Code postal';

  @override
  String get sameAsPermanentAddress => 'Identique à l\'adresse permanente';
  @override
  String get presentAddress => 'Adresse actuelle';
  @override
  String get localizationPreferences => 'Paramètres de localisation';
  @override
  String get timeZone => 'Fuseau horaire';
  @override
  String get defaultPayment => 'Paiement par défaut';
  @override
  String get defaultCurrency => 'Devise par défaut';
  @override
  String get selectLocale => 'Sélectionner la langue';
  @override
  String get pleasePickLanguage => 'Veuillez choisir une langue';
  @override
  String get defaultLanguage => 'Langue par défaut';
  @override
  String get selectDateFormat => 'Sélectionner le format de date';
  @override
  String get cancel => 'Annuler';
  @override
  String get submit => 'Soumettre';
  @override
  String get emailSettings => 'Paramètres de messagerie';
  @override
  String get enterEmail => 'Entrer l\'email';
  @override
  String get invalidEmails => 'Un ou plusieurs emails sont invalides';
  @override
  String get enterPhoneNumber => 'Veuillez entrer un numéro de téléphone';
  @override
  String get phoneNumberDigitsOnly => 'Le numéro doit comporter 10 chiffres';
  @override
  String get save => 'Enregistrer';
  @override
  String get personalInformation => 'Informations personnelles';
  @override
  String get personalDetails => 'Détails personnels';
  @override
  String get approvedExpensesTotal => 'Dépenses approuvées (Total)';

  @override
  String get expensesInProgressTotal => 'Dépenses en cours (Total)';

  @override
  String get approvedAdvancesTotal => 'Avances approuvées (Total)';

  @override
  String get advancesInProgressTotal => 'Avances en cours (Total)';
  @override
  String get expense => 'Dépense';

  @override
  String get approvals => 'Approbations';

  @override
  String get mail => 'Courrier';
  @override
  String get seeMore => 'Voir plus ▼';

  @override
  String get seeLess => 'Voir moins ▲';
  // French
  @override
  String get myExpenseTrends => 'Tendances de mes dépenses';

  @override
  String get myExpenseAmountByApprovalStatus =>
      'Montant de mes dépenses par statut d’approbation';

  @override
  String get mySettlementStatus => 'Mon statut de règlement';

  @override
  String get myExpensesByProject => 'Mes dépenses par projet';

  @override
  String get totalExpensesByCategory => 'Dépenses totales par catégorie';

  @override
  String get cashAdvance => 'Avance de fonds';
  @override
  String get myExpenses => 'Mes dépenses';

  @override
  String get myTeamExpenses => 'Dépenses de mon équipe';

  @override
  String get pendingApprovals => 'Approbations en attente';

  @override
  String get unProcessed => 'Non traité';

  @override
  String get myCashAdvances => 'Mes avances de fonds';

  @override
  String get myTeamCashAdvances => 'Avances de fonds de mon équipe';

  @override
  String get emailHub => 'Centre de courriel';

  @override
  String get approvalHub => 'Centre d’approbation';

  @override
  String get reports => 'Rapports';

  @override
  String get expensesReports => 'Rapports de dépenses';

  @override
  String get settings => 'Paramètres';

  @override
  String get help => 'Aide';

  @override
  String get logout => 'Déconnexion';

  @override
  String get hello => 'Bonjour';

  @override
  String get hiThere => 'Salut';

  @override
  String get welcomeBack => 'Bon retour';
  @override
  String get delete => 'Supprimer';
  @override
  String get unReported => 'Non signalé';
  @override
  String get approved => 'Approuvé';
  @override
  String get cancelled => 'Annulé';
  @override
  String get rejected => 'Rejeté';
  @override
  String get inProcess => 'En cours';
  @override
  String get all => 'Tous';
  @override
  String get expenseDashboard => 'Tableau de bord des dépenses';
  @override
  String get searchExpenses => 'Rechercher des dépenses...';
  @override
  String get addExpense => 'Ajouter une dépense';
  @override
  String get addPerDiem => 'Ajouter un per diem';
  @override
  String get addCashAdvanceReturn => 'Ajouter un remboursement d’avance';
  @override
  String get addMileage => 'Ajouter un kilométrage';
  @override
  String get allExpenses => 'Toutes les dépenses';
  @override
  String get generalExpenses => 'Dépenses générales';
  @override
  String get perDiem => 'Per diem';
  @override
  String get cashAdvanceReturn => 'Remboursement d’avance';
  @override
  String get mileage => 'Kilométrage';
  @override
  String get noExpensesFound => 'Aucune dépense trouvée';
  @override
  String get loading => 'Chargement...';
  @override
  String get view => 'Voir';
  @override
  String get unknownExpenseType => 'Type de dépense inconnu :';
  @override
  String get generalExpenseForm => 'Formulaire de dépense générale';
  @override
  String get projectId => 'ID du projet';
  @override
  String get projectName => 'Nom du projet';
  @override
  String get pleaseSelectProject => 'Veuillez sélectionner un projet';
  @override
  String get taxGroup => 'Groupe fiscal';
  @override
  String get pleaseSelectTaxGroup => 'Veuillez sélectionner un groupe fiscal';
  @override
  String get taxAmountRequired => 'Le montant de la taxe est requis';
  @override
  String get paidFor => 'Payé pour';
  @override
  String get pleaseSelectCategory => 'Veuillez sélectionner une catégorie';
  @override
  String get unit => 'Unité';
  @override
  String get uomId => 'ID de l’unité de mesure';
  @override
  String get uomName => 'Nom de l’unité de mesure';
  @override
  String get unitAmount => 'Montant unitaire';
  @override
  String get unitAmountRequired => 'Le montant unitaire est requis';
  @override
  String get quantity => 'Quantité';
  @override
  String get quantityRequired => 'La quantité est requise';
  @override
  String get lineAmount => 'Montant de la ligne';
  @override
  String get lineAmountInInr => 'Montant de la ligne en INR';
  @override
  String get accountDistribution => 'Répartition des comptes';
  @override
  String get totalAmount => 'Montant total :';
  @override
  String get comments => 'Commentaires';
  @override
  String get remove => 'Supprimer';
  @override
  String get itemize => 'Détailler';
  @override
  String get isReimbursable => 'Remboursable';
  @override
  String get isBillable => 'Facturable';
  @override
  String get finish => 'Terminer';
  @override
  String get next => 'Suivant';
  @override
  String get pleaseSelectRequestDate =>
      'Veuillez sélectionner une date de demande';
  @override
  String get requestDate => 'Date de la demande';
  @override
  String get selectDate => 'Sélectionner une date';
  @override
  String get paidTo => 'Payé à';
  @override
  String get selectFromMerchantList =>
      'Sélectionner dans la liste des marchands';
  @override
  String get enterMerchantManually =>
      'Marchand introuvable ? Saisir manuellement';
  @override
  String get selectMerchant => 'Sélectionner un marchand';
  @override
  String get merchantName => 'Nom du marchand';
  @override
  String get merchantId => 'ID du marchand';
  @override
  String get enterMerchantName => 'Saisir le nom du marchand';
  @override
  String get fieldRequired => 'Ce champ est requis';
  @override
  String get cashAdvanceRequest => 'Demande d’avance de fonds';
  @override
  String get pleaseSelectCashAdvanceField =>
      'Veuillez sélectionner un champ d’avance';
  @override
  String get requestId => 'ID de la demande';
  @override
  String get paidWith => 'Payé avec';
  @override
  String get clear => 'Effacer';
  @override
  String get zoomIn => 'Agrandir';
  @override
  String get zoomOut => 'Réduire';
  @override
  String get edit => 'Modifier';
  @override
  String get tapToUploadDocs => 'Appuyez pour téléverser des documents';
  @override
  String get capture => 'Capturer';
  @override
  String get upload => 'Téléverser';
  @override
  String get paidAmount => 'Montant payé';
  @override
  String get paidAmountRequired => 'Le montant payé est requis';
  @override
  String get enterValidAmount => 'Saisir un montant valide';
  @override
  String get currency => 'Devise *';
  @override
  String get pleaseSelectCurrency => 'Veuillez sélectionner une devise';
  @override
  String get rate => 'Taux';
  @override
  @override
  String get lightheme => 'Couleurs du thème clair';
  String get rateRequired => 'Le taux est requis';
  String get darktheme => 'Couleurs du thème sombre';
  @override
  String get enterValidRate => 'Saisir un taux valide';
  @override
  String get amountInInr => 'Montant en INR';
  @override
  String get notifications => 'Notifications';
  @override
  String get unread => 'Non lus';
  @override
  String get allNotifications => 'Toutes les notifications';
  @override
String get exitWarning => 'Vous perdrez toutes les données non enregistrées. Voulez-vous quitter ?';
@override
String get duplicateReceiptWarning => 'Ce reçu semble être un doublon. Voulez-vous continuer ?';

@override
String get continueText => 'Continuer';
@override String get myTeamLeaveDashboard => 'Tableau de congés de mon équipe';
@override String get noEventsFor => 'Aucun événement pour';
@override String get duration => 'Durée';

@override String get mon => 'Lun';
@override String get tue => 'Mar';
@override String get wed => 'Mer';
@override String get thu => 'Jeu';
@override String get fri => 'Ven';
@override String get sat => 'Sam';
@override String get sun => 'Dim';

@override String get noLeaveData => 'Aucune donnée de congé';
@override String get remaining => 'Restant';
@override String get outOf => 'Sur';
@override String get balance => 'Solde';
@override String get leaveRequisition => 'Demande de congé';
@override String get myLeave => 'Mes congés';
@override String get myTeamLeave => 'Congés de mon équipe';
@override String get myTeamLeaveCancellation => 'Annulation de congé de mon équipe';
String get addLeaveRequest => 'Add Leave Request';
@override
String get newCreateLeaveRequest => 'Créer une demande de congé';

@override
String get duplicateReceiptDetected => 'Reçu en double détecté';

@override
String get extractingReceipt => 'Nous extrayons votre reçu';
@override
String get pleaseWait => 'Veuillez patienter...';

@override
String get exitForm => 'Quitter le formulaire';
  @override
  String get policyViolations => 'Violations de la politique';
  @override
  String get checkPolicies => 'Vérifier les politiques';
  @override
  String get policy1001 => 'Politique 1001';
  @override
  String get expenseAmountUnderLimit =>
      'Montant de dépense inférieur à la limite';
  @override
  String get receiptRequiredAmount =>
      'Montant nécessitant un reçu : toute dépense doit avoir un reçu';
  @override
  String get descriptionMandatory =>
      'Si l’administrateur a rendu la description obligatoire pour toutes les dépenses';
  @override
  String get expiredPolicy =>
      'Une dépense expirée est considérée comme une violation de la politique';
  @override
  String get taxId => 'Identifiant fiscal';
  @override
  String get back => 'Retour';
  @override
  String get taxAmount => 'Montant de la taxe';
  @override
  String get cropImage => 'Recadrer l’image';
  @override
  String get referenceId => 'référence';
   @override
  String get employeeId => 'Identifiant employé';
   @override
  String get leaveCode => 'Code de congé';
  @override
  String get pleaseSelectMerchant => 'Veuillez sélectionner un commerçant';
  @override
  String get pleaseEnterMerchantName => 'Veuillez entrer un nom de commerçant';
  @override
  String get createPerDiem => 'Créer un per diem';
  @override
  String get editPerDiem => 'Modifier le per diem';
  @override
  String get viewPerDiem => 'Voir le per diem';
  @override
  String get perDiemDetails => 'Détails du per diem';
  @override
  String get expenseId => 'ID de dépense';

  @override
  String get close => 'Fermer';
@override String get reliever => 'Remplaçant';
@override String get department => 'Département';
@override String get dates => 'Dates';
@override String get notifyingUsers => 'Utilisateurs notifiés';
@override String get contactNumber => 'Numéro de contact';
@override String get availabilityDuringLeave => 'Disponibilité pendant le congé';
@override String get availability => 'Disponibilité';
@override String get outOfOfficeMessage => 'Message d’absence';
@override String get notifyHR => 'Notifier les RH';
@override String get notifyTeamMembers => 'Notifier les membres de l’équipe';
@override String get paidLeave => 'Congé payé';
@override String get totalDays => 'Nombre total de jours';
@override String get saveAsDraft => 'Enregistrer comme brouillon';
@override String get editLeaveRequest => 'Modifier la demande de congé';
@override String get newLeaveRequest => 'Nouvelle demande de congé';
@override String get leaveRequisitionId => 'ID de demande de congé';
@override String get delegatedAuthority => 'Autorité déléguée / Remplaçant';
@override String get locationDuringLeave => 'Lieu pendant le congé';
@override String get availableForUrgentMatters => 'Disponible pour les urgences';
@override String get notAvailable => 'Indisponible';
@override String get dayType => 'Type de jour';
@override String get fullDay => 'Journée complète';
@override String get firstHalf => 'Première moitié';
@override String get secondHalf => 'Deuxième moitié';
@override
String get appliedDate => 'Date de demande';

@override
String get ofLeave => 'de congé';

@override
String get total => 'Total';

@override
String get uploadFileOrDragDrop => 'Téléverser un fichier ou glisser-déposer';

@override
String get uploadAttachments => 'Pièces jointes';

@override
String get days => 'Jours';

  @override
  String get location => 'Lieu';
  @override
  String get country => 'Pays';
  @override
  String get pleaseSelectLocation => 'Veuillez sélectionner un lieu';
  @override
  String get user => 'Utilisateur';
  @override
  String get userName => 'Nom d’utilisateur';
  @override
  String get userId => 'ID utilisateur';
  @override
  String get code => 'Code';
  @override
  String get name => 'Nom';
  @override
  String get symbol => 'Symbole';
  @override
  String get editCashAdvanceReturn => 'Modifier le retour d’avance de fonds';
  @override
  String get viewCashAdvanceReturn => 'Voir le retour d’avance de fonds';
  @override
  String get receiptDetails => 'Détails du reçu';
  @override
  String get returnDate => 'Date de retour';
  @override
  String get paymentName => 'Nom du paiement';
  @override
  String get paymentId => 'ID de paiement';
  @override
  String get item => 'Élément';
  @override
  String get categoryName => 'Nom de la catégorie';
  @override
  String get categoryId => 'ID de catégorie';
  @override
  String get receiptDate => 'Date du reçu';
  @override
  String get pleaseSelectUnit => 'Veuillez sélectionner une unité';
  @override
  String get paymentInfo => 'Informations de paiement';
  @override
  String get cashAdvanceReturnForm =>
      'Formulaire de retour d’avance de trésorerie';
  @override
  String get mileageRegistration => 'Enregistrement du kilométrage';
  @override
  String get mileageDetails => 'Détails du kilométrage';
  @override
  String get mileageDate => 'Date du kilométrage';
  @override
  String get mileageType => 'Type de kilométrage';
  @override
  String get vehicle => 'Véhicule';
  @override
  String get confirm => 'Confirmer';
  @override
  String get turnOffRoundTrip => 'Désactiver l’aller-retour';
  @override
  String get endTrip => 'Terminer le trajet';
  @override
  String get startTrip => 'Commencer le trajet';
  @override
  String get addTrip => 'Ajouter un trajet';
  @override
  String get roundTrip => 'Aller-retour';
  @override
  String get totalDistance => 'Distance totale';
  @override
  String get fillAllTripLocations =>
      'Veuillez renseigner tous les emplacements du trajet avant de soumettre.';

  @override
  String get expenseDetails => 'Détails de la dépense';
  @override
  String get editExpenseApproval => 'Modifier l’approbation de la dépense';
  @override
  String get viewExpenseApproval => 'Voir les approbations de dépenses';

  @override
  @override
  String get deleteConfirmation => 'Are you sure you want to delete?';
  @override
  String get deleteWarning => 'This action cannot be undone.';
  @override
  String get unProcessedExpense => 'Dépense non traitée';
  @override
  String get cashAdvanceRequestForm =>
      'Formulaire de demande d’avance de trésorerie';
  @override
  String get requestedPercentage => 'Pourcentage demandé';
  @override
  String get unitEstimatedAmount => 'Montant estimé par unité';
  @override
  String get unitAmountIsRequired => 'Le montant par unité est requis';
  @override
  String get cashAdvanceRequisitionId =>
      'ID de réquisition d’avance de trésorerie';
  @override
  String get totalEstimatedAmountInInr => 'Montant estimé total en INR';
@override
String get employeeName => 'Nom de l’employé';
@override
String get justification => 'Justification';
@override
String get justificationRequired => 'Justification requise';

@override
String get enterJustification => 'Saisir la justification';

@override
String get pleaseEnterJustification => 'Veuillez saisir une justification';

@override
String get somethingWentWrong => 'Une erreur s’est produite :';
@override
String get timezoneName => 'Nom du fuseau horaire';

@override
String get timezoneCode => 'Code du fuseau horaire';

@override
String get timezoneId => 'ID du fuseau horaire';

@override
String get languageName => 'Nom de la langue';

@override
String get languageId => 'ID de la langue';

   @override
  String get totalEstimatedAmountIn => 'Montant estimé total';
  @override
  String get search => 'Rechercher';
  @override
  String get businessJustification => 'Justification commerciale';
  @override
  String get id => 'ID';
  @override
  String get paidAmountExceedsMaxPercentage =>
      'Le montant payé dépasse le pourcentage maximum autorisé';
  @override
  String get totalRequestedAmount => 'Montant total demandé';
  @override
  String get pdfViewerNotFound => 'Visionneuse PDF introuvable';
  @override
  String get noAppToViewPdf =>
      'Aucune application disponible pour afficher les fichiers PDF. Veuillez installer une application de lecture PDF.';
  @override
  String get ok => 'OK';
  @override
  String get getPdfReader => 'Obtenir un lecteur PDF';
  @override
  String get preview => 'Aperçu';
  @override
  String get processed => 'Traité';
  @override
  String get from => 'De :';
  @override
  String get attachments => 'Pièces jointes';
  @override
  String get noEmailsFound => 'Aucun e-mail trouvé';
  @override
  String get rejectEmail => 'Rejeter l’e-mail';
  @override
  String get reasonForRejection => 'Raison du rejet';
  @override
  String get emailRejectedSuccessfully => 'E-mail rejeté avec succès';
  @override
  String get errorRejectingEmail => 'Erreur lors du rejet de l’e-mail :';
  @override
  String get editReport => 'Modifier le rapport';
  @override
  String get viewReport => 'Voir le rapport';
  @override
  String get createReport => 'Créer un rapport';
  @override
  String get reportName => 'Nom du rapport';
  @override
  String get enterReportTitle => 'Entrez le titre du rapport';
  @override
  String get functionalArea => 'Domaine fonctionnel';
  @override
  String get expenseRequisition => 'Demande de dépense';
  @override
  String get cashAdvanceRequisition => 'Demande d’avance de fonds';
  @override
  String get dataset => 'Jeu de données';
  @override
  String get unknownDataset => 'Jeu de données inconnu';
  @override
  String get selectDataset => 'Sélectionnez un jeu de données';
  @override
  String get description => 'Description';
  @override
  String get addShortDescription => 'Ajoutez une brève description (optionnel)';
  @override
  String get tags => 'Étiquettes';
  @override
  String get enterTags => 'Entrez des étiquettes';
  @override
  String get applicableFor => 'Applicable pour';
  @override
  String get selectAudience => 'Sélectionnez un public';
  @override
  String get filterRule => 'Règle de filtre';
  @override
  String get addGroup => 'Ajouter un groupe';
  @override
  String get group => 'Groupe';
  @override
  String get removeGroup => 'Supprimer le groupe';
  @override
  String get addRuleToGroup => 'Ajouter une règle à ce groupe';
  @override
  String get availableColumnsHeader => 'Colonnes disponibles (En-tête)';
  @override
  String get availableColumnsLines => 'Colonnes disponibles (Lignes)';
  @override
  String get noColumnsAvailable =>
      'Aucune colonne disponible pour la sélection';
  @override
  String get table => 'Table';
  @override
  String get column => 'Colonne';
  @override
  String get condition => 'Condition';
  @override
  String get enterValueToMatch => 'Entrez une valeur à comparer';
  @override
  String get enterStartingValue => 'Entrez la valeur de départ';
  @override
  String get to => 'À';
  @override
  String get enterEndingValue => 'Entrez la valeur de fin';
  @override
  String get removeRule => 'Supprimer la règle';
  @override
  String get or => 'OU';
  @override
  String get and => 'ET';
  @override
  String get value => 'Valeur';
  @override
  String get addReport => 'Ajouter un rapport';
  @override
  String get noReportFound => 'Aucun rapport trouvé';
  @override
  String get reportAvailability => 'Disponibilité du rapport';
  @override
  String get generateReport => 'Générer le rapport';
  @override
  String get export => 'Exporter';
  @override
  String get applyFilters => 'Appliquer les filtres';
  @override
  String get noDataFound => 'Aucune donnée trouvée';
  @override
  String get totalRejectedAmount => 'Montant total rejeté';
  @override
  String get lastSettlementDate => 'Dernière date de règlement';
  @override
  String get basicFiltration => 'Filtration de base';
  @override
  String get advancedFiltering => 'Filtration avancée';
  @override
  String get groupIsEmpty =>
      'Le groupe est vide. Veuillez ajouter des règles ou supprimer le groupe.';
  @override
  String get pleaseSelectTableForRule =>
      'Veuillez sélectionner une table pour la règle dans le groupe';
  @override
  String get pleaseSelectColumnForRule =>
      'Veuillez sélectionner une colonne pour la règle dans le groupe';
  @override
  String get pleaseSelectConditionForRule =>
      'Veuillez sélectionner une condition pour la règle dans le groupe';
  @override
  String get pleaseEnterValueForRule =>
      'Veuillez entrer une valeur pour la règle';
  @override
  String get pleaseEnterFromToValuesForBetween =>
      'Veuillez entrer les valeurs "De" et "À" pour la condition "Entre" dans la règle';
  @override
  String get expenseReport => 'Rapport de dépenses';
  @override
  String get step => 'Étape';
  @override
  String get previous => 'Précédent';
  @override
  String get functionalEntity => 'Entité fonctionnelle';
  @override
  String get selectFunctionalEntity => 'Sélectionnez une entité fonctionnelle';
  @override
  String get sortBy => 'Trier par';
  @override
  String get selectSortField => 'Sélectionnez un champ de tri';
  @override
  String get sortOrder => 'Ordre de tri';
  @override
  String get selectOrder => 'Sélectionnez l’ordre';
  @override
  String get advancedFiltration => 'Filtration avancée';
  @override
  String get addNewGroup => 'Ajouter un nouveau groupe';
  @override
  String get chooseTablesToViewInReport =>
      'Choisissez les tables à afficher dans le rapport';
  @override
  String get transData => 'Données de transaction';
  @override
  String get documentAttachments => 'Pièces jointes';
  @override
  String get accountingDistributions => 'Répartitions comptables';
  @override
  String get expenseCategoryCustomFields =>
      'Champs personnalisés de catégorie de dépenses';
  @override
  String get transCustomFieldsValues =>
      'Valeurs des champs personnalisés de transaction';
  @override
  String get headerCustomFieldsValues =>
      'Valeurs des champs personnalisés d’en-tête';
  @override
  String get activityLog => 'Journal d’activité';
  @override
  String get workflowHistory => 'Historique du flux de travail';
  @override
  String get assignUsers => 'Attribuer des utilisateurs';
  @override
  String get availableUsers => 'Utilisateurs disponibles';
  @override
  String get moveAll => 'Déplacer tout';
  @override
  String get moveSelected => 'Déplacer la sélection';
  @override
  String get saveReport => 'Enregistrer le rapport';
  @override
  String get pleaseAssignAnyUser => 'Veuillez attribuer un utilisateur';
  @override
  String get print => 'Imprimer';
  @override
  String get printAll => 'Tout imprimer';
  @override
  String get totalAmountTrans => 'Montant total Trans';
  @override
  String get totalAmountReporting => 'Montant total du rapport';
  @override
  String get approvalStatus => 'Statut d\'approbation';
  @override
  String get expenseType => 'Type de dépense';
  @override
  String get expenseStatus => 'Statut de dépense';
  @override
  String get currencyCode => 'Code de devise';
  @override
  String get reportingCurrency => 'Devise du rapport';
  @override
  String get source => 'Source';
  @override
  String get totalTransAmount => 'Montant total Trans';
  @override
  String get noPreviewAvailable => 'Aucun aperçu disponible';
  @override
  String get filterations => 'Filtrations';
  @override
  String get generalSettings => 'Paramètres généraux';
  @override
  String get field => 'Champ';
  @override
  String get filteredBy => 'Filtré par';
  @override
  String get pleaseFillAllRequiredFields =>
      'Veuillez remplir tous les champs obligatoires';
  @override
  String get generalExpense => 'Dépense Générale';
  @override
  String get skip => 'Passer';

  @override
  String get selectDimensions => 'Sélectionner les dimensions';

  @override
  String get percentage => 'Pourcentage *';

  @override
  String get amount => 'Montant';
  @override
  String get askQuestionPrompt => "Posez une question sur vos données...";
  @override
  String get tryAsking => "Essayez de demander :";
  @override
  String get aiAnalytics => "Analyse IA";
  @override
  String get networkError =>
      "Erreur réseau. Veuillez vérifier votre connexion.";
  @override
  String get requestError =>
      "Désolé, je n'ai pas pu traiter votre demande. Veuillez réessayer.";
  @override
  String get expenseDistribution => "Répartition des dépenses";
  @override
  String get breakdownHeader => "Voici la répartition :";
  @override
  String get aiAnalyticsWelcome =>
      "Bienvenue dans l'analyse IA ! Je peux vous aider à analyser vos données de dépenses. Demandez-moi n'importe quoi !";
  @override
  String get report => 'Rapport';

  @override
  String get addSplit => 'Ajouter une répartition';

  @override
  String totalPercentageMustBe100(double current) =>
      'Le pourcentage total doit être égal à 100%. Actuel: ${current.toStringAsFixed(2)}%';
  @override
  String get expenseTrans => 'Transaction de dépense';
  @override
  String get lineNumber => 'Numéro de ligne';
  @override
  String get expenseCategoryId => 'ID de catégorie de dépense';
  @override
  String get unitPriceTrans => 'Prix unitaire Trans';
  @override
  String get lineAmountTrans => 'Montant de la ligne';
  @override
  String get type => 'Type';
  @override
  String get format => 'Format';
  @override
  String get errorLoadingImage => 'Erreur de chargement de l\'image';
  @override
  String get pdfDocument => 'Document PDF';

  String get fromDate => 'Date de début';
  @override
  String get toDate => 'Date de fin';
  @override
  String get noOfDays => 'Nombre de jours';

  @override
  String get totalAmountInInr => 'Montant total en INR';
  @override
  String get purpose => 'Objet';
  @override
  String get trackingHistory => 'Historique de suivi';
  @override
  String get noHistoryMessage =>
      'Cette dépense n’a pas d’historique. Veuillez envisager de la soumettre pour approbation.';
  @override
  String get update => 'Mettre à jour';
  @override
  String get updateAndAccept => 'Mettre à jour et accepter';
  @override
  String get reject => 'Rejeter';
  @override
  String get resubmit => 'Soumettre à nouveau';
  @override
  String get approve => 'Approuver';
  @override
  String get escalate => 'Escalader';
  @override
  String get action => 'Action';
  @override
  String get selectUser => 'Sélectionner un utilisateur';
  @override
  String get enterCommentHere => 'Entrez votre commentaire ici';
  @override
  String get commentRequired => 'Le commentaire est requis';
  @override
  String get submittedOn => 'Soumis le';
  @override
  String get allocationSettings => 'Paramètres d’allocation';
  @override
  String get noAllocationDataMessage =>
      'Aucune donnée d’allocation trouvée pour le lieu sélectionné. Essayez un autre lieu.';
  @override
  String get effectiveFrom => 'Effectif à partir du';
  @override
  String get allowanceCategory => 'Catégorie d’allocation';
  @override
  String get effectiveTo => 'Effectif jusqu’au';
  @override
  String get pleaseEnterNumberOfDays => 'Veuillez entrer le nombre de jours';
  @override
  String get numberOfDaysCannotBeNegative =>
      'Le nombre de jours ne peut pas être négatif';
  @override
  String get enteredDaysCannotExceedAllocated =>
      'Les jours saisis ne peuvent pas dépasser les jours alloués';
  @override
  String get pleaseEnterValidNumber => 'Veuillez entrer un nombre valide';
   @override String get wouldYouLikeToPunch => 'Voulez-vous pointer?';
  
  @override String get punchOut => 'Pointer Sortie';
  
  @override String get punchIn => 'Pointer Entrée';
  
  @override String get status => 'Statut';
  
  @override String get lastSession => 'Dernière Session';
  
  @override String get lastIn => 'Dernière Entrée';
  
  @override String get lastOut => 'Dernière Sortie';
  
  @override String get totalTime => 'Temps Total';
  
  @override String get selfieVerification => 'Vérification par selfie';
  
  @override String get retake => 'Reprendre';
  
  @override String get currentLocation => 'Emplacement actuel';
  
  @override String get myLocation => 'Ma position';
    @override String get myAttendanceList => 'Ma Liste de Présence';
  @override String get totalHours => 'Heures Totales';
  @override String get transactionId => 'ID de Transaction';
  @override String get punchInTime => 'Heure d\'Entrée';
  @override String get punchOutTime => 'Heure de Sortie';
  @override String get totalDuration => 'Durée Totale';
  @override String get captureType => 'Type de Capture';
  @override String get punchInGeofenceId => 'ID Géorepérage d\'Entrée';
  @override String get punchOutGeofenceId => 'ID Géorepérage de Sortie';
  @override String get isRegularized => 'Est Régularisé';
  @override String get punchInLocation => 'Emplacement d\'Entrée';
  @override String get punchOutLocation => 'Emplacement de Sortie';
   @override String get viewTeamMemberAttendance => 'Voir la présence des membres de l\'équipe';
  @override String get viewAttendanceTransaction => 'Voir la transaction de présence';
  @override String get fetchingLocation => 'Récupération de la localisation...';
  
  @override String get locationPermissionDenied => 'Permission de localisation refusée';
  
  @override String get failedToFetchLocation => 'Échec de la récupération de la localisation';
  
  @override String get cameraPermissionDenied => 'Permission de caméra refusée';
  
  
  @override String get punchFailed => 'Pointage échoué. Veuillez réessayer.';
  
  @override String get punchedInSuccessfully => 'Pointage d\'entrée réussi!';
  
  @override String get punchedOutSuccessfully => 'Pointage de sortie réussi!';
  
  @override String get noPreviousSession => 'Aucune session précédente';
  
  @override String get locationNotAvailable => 'Emplacement non disponible';
  
  @override String get takeSelfie => 'Prendre un selfie';
  
  @override String get boardDashboard => 'Tableau de bord du conseil';
  @override String get createBoard => 'Créer un conseil';
  @override String get boardName => 'Nom du conseil';
  @override String get boardTemplate => 'Modèle de conseil';
  @override String get referenceName => 'Nom de référence';
  @override String get boardTaskDetails => 'Détails de la tâche du conseil';
  @override String get taskName => 'Nom de la tâche';
  @override String get enterTaskName => 'Entrez le nom de la tâche';
  @override String get selectTags => 'Sélectionner une/des étiquette(s)';
  @override String get tagId => 'ID de l\'étiquette';
  @override String get tagName => 'Nom de l\'étiquette';
  @override String get selectUsers => 'Sélectionner un/des utilisateur(s)';
  @override String get estimatedHours => 'Heures estimées';
  @override String get cardType => 'Type de carte';
  @override String get priority => 'Priorité';
  @override String get low => 'Faible';
  @override String get high => 'Élevée';
  @override String get medium => 'Moyenne';
  @override String get urgent => 'Urgent';
  @override String get actualHours => 'Heures réelles';
  @override String get version => 'Version';
  @override String get parentTask => 'Tâche parente';
  @override String get taskId => 'ID de la tâche';
  @override String get selectDependency => 'Sélectionner une dépendance';
  @override String get checklist => 'Liste de contrôle';
  @override String get addItem => 'Ajouter un élément';
  @override String get showInCard => 'Afficher dans la carte';
  @override String get enterNotes => 'Entrez des notes';
  @override String get addAttachment => 'Ajouter une pièce jointe';
  @override String get posting => 'Publication...';
  @override String get comment => 'Commentaire';
  @override String get noCommentsYet => 'Pas encore de commentaires';
  @override String get grid => 'Grille';
  @override String get boardSettings => 'Paramètres du conseil';
  @override String get addShelf => 'Ajouter une étagère';
  @override String get addTask => 'Ajouter une tâche';
  @override String get noTasksFound => 'Aucune tâche trouvée';
  @override String get deleteTask => 'Supprimer la tâche';
  @override String get noDueDate => 'Pas de date d\'échéance';
  @override String get shelfName => 'Nom de l\'étagère';
  @override String get searchTasksUsersTags => 'Rechercher des tâches, utilisateurs, étiquettes...';
  @override String get assigned => 'Assigné';
  @override String get editShelf => 'Modifier l\'étagère';
  @override String get areYouSureDeleteTask => 'Êtes-vous sûr de vouloir supprimer cette tâche?';
  @override String get dueDate => 'Date d\'échéance';
  @override String get addBoardMembers => 'Ajouter des membres du conseil';
@override String get sendToMail => 'Envoyer par e-mail';
@override String get send => 'Envoyer';
@override String get download => 'Télécharger';
@override String get payslipsNotAvailable => 'Fiches de paie non disponibles';
@override String get tableView => 'Vue tableau';
@override String get timeTracker => 'Suivi du temps';
@override String get start => 'Démarrer';
@override String get eventType => 'Type d’événement';
@override String get periodType => 'Type de période';
@override String get periodTypeIsRequired => 'Le type de période est requis';
@override String get timeSheetRequestForm => 'Formulaire de demande de feuille de temps';
@override String get dateRange => 'Plage de dates';
@override String get lineItem => 'Élément';
@override String get addLine => 'Ajouter une ligne';
@override String get addTimer => 'Ajouter un minuteur';
@override String get timeSheetPendingApprovals => 'Approbations de feuilles de temps en attente';
@override String get employees => 'Employés';
@override String get employeeGroups => 'Groupes d’employés';
@override String get timesheetRequisitionId => 'ID de demande de feuille de temps';

@override String get pause => 'Pause';
@override String get resume => 'Reprendre';
@override String get complete => 'Terminer';
@override String get generateTimeSheet => 'Générer la feuille de temps';
@override String get generateAndSubmit => 'Générer et soumettre';
@override String get noTimeRunsFound => 'Aucun enregistrement trouvé';
@override String get active => 'ACTIF';
@override String get runId => 'ID d’exécution';
@override String get segment => 'Segment';
@override String get timeRunId => 'ID du temps';
@override String get sequence => 'Séquence';
@override String get end => 'Fin';
@override String get noEventsFound => 'Aucun événement trouvé';
@override String get event => 'Événement';
@override String get occurred => 'Survenu';
@override String get started => 'Commencé';
@override String get ended => 'Terminé';
@override String get eventTypeOccurred => 'Type d’événement survenu';
@override String get details => 'Détails';
@override String get viewDetails => 'Voir les détails';
@override String get segmentId => 'ID du segment';
@override String get segmentSequence => 'Séquence du segment';
@override String get startTime => 'Heure de début';
@override String get endTime => 'Heure de fin';
@override String get durationInHours => 'Durée en heures';
@override String get endEvent => 'Événement de fin';
@override String get updateDetails => 'Mettre à jour les détails';
@override String get editSegment => 'Modifier le segment';

  // ... ALL previous strings remain
  @override
String get timeDetails => 'Détails du temps';
@override String get branchEmployees => 'Employés de la succursale';
@override String get departmentEmployees => 'Employés du département';
@override
String get myLeaveCancellations => 'Mes annulations de congé';
@override String get viewType => 'Type de vue';
@override String get leaveFullCancellation => 'Annulation complète du congé';
@override String get reasonForCancellation => 'Raison de l’annulation';
@override String get pleaseEnterCancellationReason => 'Veuillez saisir la raison de l’annulation';
@override String get leavePartialCancellation => 'Annulation partielle du congé';
  // NEW - Board Creation & Management
 @override String get visibilityOfYourBoard => 'Visibilité de votre conseil';
  @override String get public => 'Public';
  @override String get visibleToEveryone => 'Visible par tous';
  @override String get private => 'Privé';
  @override String get onlySelectedUsers => 'Seulement les utilisateurs sélectionnés';
  @override String get enterBoardName => 'Entrez le nom du conseil';
  @override String get boardNameIsRequired => 'Le nom du conseil est requis';
  @override String get selectTemplate => 'Sélectionner un modèle';
  @override String get pleaseSelectATemplate => 'Veuillez sélectionner un modèle';
  @override String get templateIsRequired => 'Le modèle est requis';
  @override String get selectGroups => 'Sélectionner des groupes';
  @override String get areYouSureDeleteBoard => 'Êtes-vous sûr de vouloir supprimer ce conseil?';
  @override String get thisActionCannotBeUndone => 'Cette action ne peut pas être annulée.';
  @override String get deleteBoard => 'Supprimer le conseil';
@override String get boardOwnerName => 'Nom du propriétaire du conseil';
  @override String get defaultSortingOrder => 'Ordre de tri par défaut';
  @override String get byAssignee => 'Par assigné';
  @override String get enableTimeTracking => 'Activer le suivi du temps';
  @override String get referenceType => 'Type de référence';
  @override String get boardTheme => 'Thème du conseil';
  @override String get plannedStartDate => 'Date de début prévue';
@override String get plannedEndDate => 'Date de fin prévue';
@override String get actualStartDate => 'Date de début réelle';
@override String get actualEndDate => 'Date de fin réelle';
@override String get addTimeSheets => 'Ajouter des feuilles de temps';
  @override String get areaName => 'Nom de la zone';
  @override String get dark => 'Sombre';
  @override String get light => 'Clair';
  @override String get systemDefault => 'Par défaut du système';
  @override String get backgroundImage => 'Image de fond';
  @override String get url => 'URL';
  @override String get fileUpload => 'Téléchargement de fichier';
  @override String get imageUrl => 'URL de l\'image';
  @override String get uploadImage => 'Télécharger une image';
  @override String get removeMemberFromBoard => 'Retirer le membre du conseil?';
  @override String get selfiePlaceholder => 'Ajouter un selfie';
   @override String get members => 'Membres';
}
