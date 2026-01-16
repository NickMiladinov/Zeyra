/// Weekly pregnancy development insights for the congratulations screen.
///
/// Each insight describes what's happening with baby development at that week.
/// Weeks 1-4 are pre-embryonic, 5-40 cover the full pregnancy range.
const Map<int, String> weeklyInsights = {
  0: 'your journey is just beginning!',
  1: 'conception is around the corner!',
  2: 'your egg is being fertilized!',
  3: 'your baby is developing fingernails!',
  4: 'your baby is the size of a poppy seed!',
  5: 'your baby\'s heart is starting to form!',
  6: 'your baby\'s heart is beating!',
  7: 'your baby is developing arm and leg buds!',
  8: 'your baby\'s fingers and toes are forming!',
  9: 'your baby is starting to move!',
  10: 'your baby\'s vital organs are developed!',
  11: 'your baby can open and close their fists!',
  12: 'your baby\'s reflexes are kicking in!',
  13: 'your baby has unique fingerprints!',
  14: 'your baby can make facial expressions!',
  15: 'your baby can sense light!',
  16: 'your baby\'s ears are in position!',
  17: 'your baby\'s skeleton is hardening!',
  18: 'your baby can hear your voice!',
  19: 'your baby is covered in a protective coating!',
  20: 'you\'re halfway there! Baby is swallowing!',
  21: 'your baby has eyebrows!',
  22: 'your baby\'s lips are forming!',
  23: 'your baby can hear music!',
  24: 'your baby\'s lungs are developing!',
  25: 'your baby has a sense of balance!',
  26: 'your baby\'s eyes are opening!',
  27: 'your baby is sleeping and waking regularly!',
  28: 'your baby can blink and dream!',
  29: 'your baby\'s muscles are getting stronger!',
  30: 'your baby is practicing breathing!',
  31: 'your baby\'s brain is developing rapidly!',
  32: 'your baby has toenails!',
  33: 'your baby\'s bones are hardening!',
  34: 'your baby\'s lungs are maturing!',
  35: 'your baby is gaining weight rapidly!',
  36: 'your baby is getting ready for birth!',
  37: 'your baby is considered full term!',
  38: 'your baby\'s organs are ready!',
  39: 'your baby is fully developed!',
  40: 'your baby is ready to meet you!',
  41: 'your baby is overdue but healthy!',
  42: 'any day now, you\'ll meet your baby!',
};

/// Get the weekly insight for a specific gestational week.
///
/// Returns a default message if the week is out of range.
String getWeeklyInsight(int week) {
  if (week < 0) return weeklyInsights[0]!;
  if (week > 42) return weeklyInsights[42]!;
  return weeklyInsights[week] ?? 'your baby is growing!';
}
