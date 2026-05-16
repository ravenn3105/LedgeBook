class PreferencesModel {
  final String defaultCurrency;
  final String theme;
  final double? monthlyBudget;
  final bool onboardingComplete;

  PreferencesModel({
    this.defaultCurrency = 'INR',
    this.theme = 'system',
    this.monthlyBudget,
    this.onboardingComplete = false,
  });
}