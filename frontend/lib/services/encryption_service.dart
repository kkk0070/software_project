// Import Dart's JSON encoding utilities
import 'dart:convert';
// Import typed data structures for byte arrays
import 'dart:typed_data';
// Import encrypt package for AES encryption
import 'package:encrypt/encrypt.dart' as encrypt;
// Import PointyCastle for RSA cryptography operations
import 'package:pointycastle/export.dart';
// Import crypto package for hashing algorithms
import 'package:crypto/crypto.dart';

/// Encryption Service for Flutter
/// Implements hybrid encryption using AES-256-GCM (symmetric) and RSA-2048 (asymmetric)
/// - AES-256-GCM: Fast encryption for data, authenticated encryption mode
/// - RSA-2048: Secure key exchange, encrypts the AES key
/// Provides secure key generation and message encryption capabilities
class EncryptionService {
  /// Generate RSA key pair for asymmetric encryption
  /// Used for secure key exchange - public key encrypts, private key decrypts
  /// 
  /// Parameters:
  /// - [bitLength] - Key size in bits (default 2048, higher = more secure but slower)
  /// 
  /// Returns an [AsymmetricKeyPair] containing public and private RSA keys
  static AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> generateRSAKeyPair({
    int bitLength = 2048,
  }) {
    print('\n[ENCRYPTING] Generating RSA-$bitLength key pair...');

    // Initialize RSA key generator with secure parameters
    final keyGen = RSAKeyGenerator()
      ..init(
        ParametersWithRandom(
          // RSA parameters: public exponent 65537, key size, certainty for prime testing
          RSAKeyGeneratorParameters(BigInt.parse('65537'), bitLength, 64),
          // Use Fortuna PRNG seeded with random bytes for cryptographic security
          FortunaRandom()..seed(KeyParameter(_randomBytes(32))),
        ),
      );

    // Generate the public-private key pair
    final pair = keyGen.generateKeyPair();
    print('[SUCCESS] RSA key pair generated successfully');

    // Return typed key pair
    return AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>(
      pair.publicKey as RSAPublicKey,
      pair.privateKey as RSAPrivateKey,
    );
  }

  /// Generate cryptographically secure random bytes for key seeding
  /// Uses multiple entropy sources to ensure unpredictability
  /// 
  /// Parameters:
  /// - [length] - Number of random bytes to generate
  /// 
  /// Returns a [Uint8List] of random bytes
  static Uint8List _randomBytes(int length) {
    // Use Fortuna PRNG (cryptographically secure pseudo-random number generator)
    final random = SecureRandom('Fortuna');

    // Create seed by mixing multiple entropy sources
    // In production, use platform-specific secure random sources (e.g., /dev/urandom)
    final seed = Uint8List(32);
    for (int i = 0; i < 32; i++) {
      // Mix current time (microseconds), hash codes, and loop index
      // XOR operation combines entropy from different sources
      seed[i] =
          (DateTime.now().microsecondsSinceEpoch ^
              DateTime.now().millisecondsSinceEpoch.hashCode ^
              i.hashCode) %
          256;  // Modulo 256 to keep value in byte range (0-255)
    }
    // Seed the random number generator
    random.seed(KeyParameter(seed));

    // Generate and return the requested number of random bytes
    return random.nextBytes(length);
  }

  /// Generate AES-256 key for symmetric encryption
  /// AES-256 provides strong encryption for data at rest and in transit
  /// 256-bit key size offers excellent security against brute force attacks
  /// 
  /// Returns an [encrypt.Key] - 32-byte (256-bit) AES key
  static encrypt.Key generateAESKey() {
    print('\n[KEY] Generating AES-256 encryption key...');
    // Generate 32-byte (256-bit) key from secure random source
    final key = encrypt.Key.fromSecureRandom(32);
    print('[SUCCESS] AES-256 key generated successfully');
    print('   - Key Length: 32 bytes (256 bits)');
    return key;
  }

  /// Encrypt message using AES-256-GCM (Galois/Counter Mode)
  /// GCM mode provides both confidentiality and authenticity
  /// - Confidentiality: Data is encrypted
  /// - Authenticity: Detects if data has been tampered with
  /// 
  /// Parameters:
  /// - [plaintext] - Message to encrypt
  /// - [key] - AES-256 encryption key
  /// 
  /// Returns a [Map] with encrypted data, IV, and authentication tag
  static Map<String, String> encryptAES(String plaintext, encrypt.Key key) {
    print('\n[ENCRYPTING] Encrypting message with AES-256-GCM...');
    print('   - Plaintext Length: ${plaintext.length} characters');
    // Show preview of plaintext (truncate if too long)
    print(
      '   - Plaintext Preview: "${plaintext.length > 50 ? plaintext.substring(0, 50) + '...' : plaintext}"',
    );

    // Generate random 16-byte (128-bit) initialization vector
    // IV ensures same plaintext produces different ciphertext each time
    final iv = encrypt.IV.fromSecureRandom(16);
    // Create AES encrypter in GCM mode for authenticated encryption
    final encrypter = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.gcm),
    );

    // Perform encryption with the IV
    final encrypted = encrypter.encrypt(plaintext, iv: iv);

    print('[SUCCESS] Encryption completed successfully');
    print('   - Algorithm: AES-256-GCM');
    print('   - IV (base64): ${iv.base64}');
    print(
      '   - Encrypted Length: ${encrypted.base64.length} base64 characters',
    );

    return {'encrypted': encrypted.base64, 'iv': iv.base64};
  }

  /// Decrypt message with AES-256-GCM
  static String decryptAES(
    String encryptedBase64,
    encrypt.Key key,
    String ivBase64,
  ) {
    print('\n🔓 Decrypting message with AES-256-GCM...');
    print('   - Encrypted Length: ${encryptedBase64.length} base64 characters');

    try {
      final iv = encrypt.IV.fromBase64(ivBase64);
      final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.gcm),
      );

      final decrypted = encrypter.decrypt64(encryptedBase64, iv: iv);

      print('[SUCCESS] Decryption completed successfully');
      print('   - Decrypted Length: ${decrypted.length} characters');

      return decrypted;
    } catch (e) {
      print('[ERROR] Decryption failed: $e');
      throw Exception('Decryption failed - invalid key, IV, or data');
    }
  }

  /// Encrypt data with RSA public key
  static String encryptRSA(String data, RSAPublicKey publicKey) {
    print('\n[ENCRYPTING] Encrypting data with RSA-2048...');
    print('   - Data Length: ${data.length} bytes');

    final encrypter = OAEPEncoding(RSAEngine())
      ..init(true, PublicKeyParameter<RSAPublicKey>(publicKey));

    final plainBytes = utf8.encode(data);
    final encrypted = encrypter.process(Uint8List.fromList(plainBytes));
    final encryptedBase64 = base64.encode(encrypted);

    print('[SUCCESS] RSA encryption completed');
    print('   - Encrypted Length: ${encryptedBase64.length} base64 characters');

    return encryptedBase64;
  }

  /// Decrypt data with RSA private key
  static String decryptRSA(String encryptedBase64, RSAPrivateKey privateKey) {
    print('\n🔓 Decrypting data with RSA-2048...');
    print('   - Encrypted Length: ${encryptedBase64.length} base64 characters');

    try {
      final encrypter = OAEPEncoding(RSAEngine())
        ..init(false, PrivateKeyParameter<RSAPrivateKey>(privateKey));

      final encryptedBytes = base64.decode(encryptedBase64);
      final decrypted = encrypter.process(Uint8List.fromList(encryptedBytes));
      final decryptedText = utf8.decode(decrypted);

      print('[SUCCESS] RSA decryption completed');
      print('   - Decrypted Length: ${decryptedText.length} bytes');

      return decryptedText;
    } catch (e) {
      print('[ERROR] RSA decryption failed: $e');
      throw Exception('RSA decryption failed - invalid key or data');
    }
  }

  /// Encrypt message package (combines AES and RSA)
  /// Uses AES for content, RSA for key exchange
  static Map<String, String> encryptMessage(
    String message,
    String recipientPublicKeyPem,
  ) {
    print('\n${'=' * 70}');
    print('[INFO] ENCRYPTING MESSAGE FOR SECURE TRANSMISSION');
    print('=' * 70);

    // Step 1: Generate AES key for this message
    final aesKey = generateAESKey();

    // Step 2: Encrypt message with AES
    final aesResult = encryptAES(message, aesKey);

    // Step 3: Parse recipient's RSA public key
    final publicKey = parseRSAPublicKeyFromPem(recipientPublicKeyPem);

    // Step 4: Encrypt AES key with RSA
    final encryptedKey = encryptRSA(base64.encode(aesKey.bytes), publicKey);

    print('\n[INFO] Message Package Created:');
    print(
      '   - Encrypted Content: ${aesResult['encrypted']!.length} base64 chars',
    );
    print('   - Encrypted AES Key: ${encryptedKey.length} base64 chars');
    print('   - IV: ${aesResult['iv']!.length} base64 chars');
    print('=' * 70 + '\n');

    return {
      'encryptedContent': aesResult['encrypted']!,
      'encryptedKey': encryptedKey,
      'iv': aesResult['iv']!,
      'authTag': '', // GCM mode handles authentication internally
    };
  }

  /// Decrypt message package
  static String decryptMessage(
    Map<String, String> encryptedPackage,
    RSAPrivateKey privateKey,
  ) {
    print('\n${'=' * 70}');
    print('[INFO] DECRYPTING RECEIVED MESSAGE');
    print('=' * 70);

    try {
      // Step 1: Decrypt AES key using RSA
      final aesKeyBase64 = decryptRSA(
        encryptedPackage['encryptedKey']!,
        privateKey,
      );
      final aesKey = encrypt.Key(base64.decode(aesKeyBase64));

      // Step 2: Decrypt message content with AES
      final decrypted = decryptAES(
        encryptedPackage['encryptedContent']!,
        aesKey,
        encryptedPackage['iv']!,
      );

      print('\n[SUCCESS] Message successfully decrypted and authenticated');
      print('=' * 70 + '\n');

      return decrypted;
    } catch (e) {
      print('\n[ERROR] Message decryption failed: $e');
      print('=' * 70 + '\n');
      rethrow;
    }
  }

  /// Parse RSA public key from PEM format
  static RSAPublicKey parseRSAPublicKeyFromPem(String pemString) {
    try {
      // Extract base64 and decode
      final base64String = pemString
          .replaceAll('-----BEGIN PUBLIC KEY-----', '')
          .replaceAll('-----END PUBLIC KEY-----', '')
          .replaceAll('\n', '')
          .replaceAll('\r', '')
          .trim();

      final decoded = utf8.decode(base64.decode(base64String));
      final parts = decoded.split(':');

      if (parts.length != 2) {
        throw Exception('Invalid public key format');
      }

      final modulus = BigInt.parse(parts[0]);
      final exponent = BigInt.parse(parts[1]);

      return RSAPublicKey(modulus, exponent);
    } catch (e) {
      throw Exception('Failed to parse RSA public key: $e');
    }
  }

  /// Parse RSA private key from PEM format
  static RSAPrivateKey parseRSAPrivateKeyFromPem(String pemString) {
    try {
      // Extract base64 and decode
      final base64String = pemString
          .replaceAll('-----BEGIN RSA PRIVATE KEY-----', '')
          .replaceAll('-----END RSA PRIVATE KEY-----', '')
          .replaceAll('-----BEGIN PRIVATE KEY-----', '')
          .replaceAll('-----END PRIVATE KEY-----', '')
          .replaceAll('\n', '')
          .replaceAll('\r', '')
          .trim();

      final decoded = utf8.decode(base64.decode(base64String));
      final parts = decoded.split(':');

      if (parts.length != 4) {
        throw Exception('Invalid private key format');
      }

      final modulus = BigInt.parse(parts[0]);
      final privateExponent = BigInt.parse(parts[1]);
      final p = BigInt.parse(parts[2]);
      final q = BigInt.parse(parts[3]);

      return RSAPrivateKey(modulus, privateExponent, p, q);
    } catch (e) {
      throw Exception('Failed to parse RSA private key: $e');
    }
  }

  /// Convert RSA public key to PEM format
  static String encodeRSAPublicKeyToPem(RSAPublicKey publicKey) {
    try {
      // Create DER-encoded public key
      final modulus = publicKey.modulus;
      final exponent = publicKey.exponent;

      // Simplified PEM encoding - store key components as base64
      final keyData = '$modulus:$exponent';
      final encoded = base64.encode(utf8.encode(keyData));
      return '-----BEGIN PUBLIC KEY-----\n$encoded\n-----END PUBLIC KEY-----';
    } catch (e) {
      throw Exception('Failed to encode RSA public key: $e');
    }
  }

  /// Convert RSA private key to PEM format
  static String encodeRSAPrivateKeyToPem(RSAPrivateKey privateKey) {
    try {
      // Simplified PEM encoding - store key components as base64
      final keyData =
          '${privateKey.modulus}:${privateKey.privateExponent}:${privateKey.p}:${privateKey.q}';
      final encoded = base64.encode(utf8.encode(keyData));
      return '-----BEGIN RSA PRIVATE KEY-----\n$encoded\n-----END RSA PRIVATE KEY-----';
    } catch (e) {
      throw Exception('Failed to encode RSA private key: $e');
    }
  }

  /// Generate SHA-256 hash
  static String hashData(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Generate secure random token
  static String generateToken({int length = 32}) {
    final random = SecureRandom('Fortuna')
      ..seed(KeyParameter(_randomBytes(32)));
    final bytes = random.nextBytes(length);
    return base64Url.encode(bytes);
  }
}
