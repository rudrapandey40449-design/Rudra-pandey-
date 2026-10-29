import 'dart:math';
import 'dart:typed_data';

class FaceMathUtil {
  /// Computes Cosine Similarity between two normalized vectors: (A . B) / (||A|| * ||B||)
  static double computeCosineSimilarity(List<double> vectorA, List<double> vectorB) {
    if (vectorA.length != vectorB.length) {
      throw Exception("Vectors must have the same length");
    }

    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;

    for (int i = 0; i < vectorA.length; i++) {
      dotProduct += vectorA[i] * vectorB[i];
      normA += vectorA[i] * vectorA[i];
      normB += vectorB[i] * vectorB[i];
    }

    if (normA == 0.0 || normB == 0.0) return 0.0;

    return dotProduct / (sqrt(normA) * sqrt(normB));
  }

  /// Euclidean Distance
  static double computeEuclideanDistance(List<double> vectorA, List<double> vectorB) {
    if (vectorA.length != vectorB.length) {
      throw Exception("Vectors must have the same length");
    }

    double sum = 0.0;
    for (int i = 0; i < vectorA.length; i++) {
      double diff = vectorA[i] - vectorB[i];
      sum += diff * diff;
    }
    return sqrt(sum);
  }
}
