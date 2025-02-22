double calculateBMI(double weight, double height) {
  return weight / ((height / 100) * (height / 100));
}

double calculateZScore(double measuredValue, double mean, double stdDev) {
  return (measuredValue - mean) / stdDev;
}

String checkGrowthStatus(double weight, double height, double meanWeight, double stdWeight) {
  double zScore = calculateZScore(weight, meanWeight, stdWeight);
  if (zScore < -2) return "🚨 Growth Alert: Underweight";
  if (zScore > 2) return "🚨 Growth Alert: Overweight";
  return "✅ Growth is normal";
}
