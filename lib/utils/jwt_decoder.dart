// lib/utils/jwt_decoder.dart
import 'dart:convert';

/// Décode un token JWT et retourne son payload sous forme de Map.
Map<String, dynamic> decodeJwt(String token) {
  final parts = token.split('.');
  if (parts.length != 3) {
    throw Exception('Invalid JWT format');
  }

  // Décode la partie payload (qui est encodée en base64url)
  String payloadBase64 = parts[1];

  // Les caractères de remplissage ('=') peuvent manquer, il faut les ajouter.
  // Assurez-vous que la chaîne est un multiple de 4 pour le décodage Base64.
  switch (payloadBase64.length % 4) {
    case 2:
      payloadBase64 += '==';
      break;
    case 3:
      payloadBase64 += '=';
      break;
  }

  // Utilisation de base64Url.decode (du package convert) pour le décodage sans risque de padding
  return json.decode(utf8.decode(base64.decode(
      payloadBase64))); // Utilisation de base64 standard si 'convert' n'est pas utilisé pour base64Url
}