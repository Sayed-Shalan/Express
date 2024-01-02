
class ValidationUtil {

  /// ********************************************************************************
  static bool validateWebsite(String? input) {
    if (input == null || input.length < 4) return false;
    var isValidUrl = Uri.tryParse(input)?.hasScheme ?? false;
    if (isValidUrl) return true;
    return false;
  }

}
