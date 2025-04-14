class DateFormatter {
  static String formatDate(String? dateString) {
    if (dateString == null) return '2 hours ago';

    try {
      DateTime publishedAt = DateTime.parse(dateString);
      DateTime now = DateTime.now();
      Duration difference = now.difference(publishedAt);

      if (difference.inHours < 24) {
        return '${difference.inHours} hours ago';
      } else {
        return '${difference.inDays} days ago';
      }
    } catch (e) {
      return '2 hours ago';
    }
  }
}