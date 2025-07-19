import 'app_localizations.dart';

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get welcome => 'Bienvenue sur DigiXpense';

  @override
  String get login => 'Connexion';

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
}
