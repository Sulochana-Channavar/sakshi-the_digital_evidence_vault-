# sakshi-the_digital_evidence_vault-
🔐 Sakshi Vault — Digital Evidence Protection System

Sakshi Vault is a secure mobile application designed to capture, preserve, and manage digital evidence with legal integrity.
The app ensures that evidence remains tamper-proof and legally admissible using hashing, chain-of-custody tracking, and automated legal report generation.

## Project Purpose
Many victims hesitate to report incidents immediately due to lack of proof or fear of evidence manipulation.
Sakshi Vault provides a safe digital vault where users can:
- Capture or upload evidence securely
- Record emergency panic videos instantly
- Write incident descriptions
- Maintain chain of custody
- Generate court-ready legal reports
  
## Key Features
Panic Mode Recording
- Triple-tap detection triggers automatic video recording
- Evidence saved instantly
- Auto hash generation
- Chain of custody updated automatically

Secure Evidence Capture
- Camera capture & gallery upload
- SHA-256 hash generation
- Tamper detection system

Written Complaint Support
- Users can submit incident descriptions even without media
- Caption + detailed explanation stored with evidence
- Automatically added to legal reports

Court Mode Protection
- Editing locked after evidence creation
- Prevents accidental or malicious modification
  
Chain of Custody
 Tracks every action:
- Evidence captured
- Uploaded
- Verified
- Tamper detection events

Legal Report Generator (Section 65B)
- Generates court-ready digital evidence reports
- Includes hash, timestamps, and incident description

Secure Authentication
- Login & Registration system
- Biometric authentication support

Tech Stack
- Flutter (Frontend)
- Dart
- SHA-256 Cryptographic Hashing
- Local Secure Storage
- Camera API
- Image Picker
- Local Authentication (Biometrics)

## App Architecture:
Login Screen
     ↓
Vault Dashboard
     ↓
Evidence Capture / Upload
     ↓
Hash Generation
     ↓
Chain of Custody Tracking
     ↓
Legal Report Generation

## Project Structure:
lib/
│
├── models/
│   └── evidence.dart
│
├── screens/
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── vault_screen.dart
│   └── evidence_detail_screen.dart
│
├── services/
│   ├── auth_service.dart
│   └── legal_report_service.dart
│
└── widgets/
    └── panic_detector.dart

## Installation:
Clone Repository:
 git clone https://github.com/YOUR_USERNAME/sakshi-vault.git
 cd sakshi-vault

Install Dependencies:
flutter pub get

Run App:
flutter run

## Security Design:
- SHA-256 hashing ensures file integrity
- Evidence tamper detection
- Immutable chain-of-custody logs
- Court Mode locking
- Biometric authentication

## Use Cases
- Workplace harassment reporting
- Domestic violence documentation
- Legal evidence preservation
- Law enforcement digital collection
- Personal safety documentation

Screenshots
(Add screenshots here)

Author
Sulochana
Flutter Developer | Legal Tech Enthusiast

License
This project is developed for educational and research purposes.

Future Improvements
- Cloud backup with encryption
- Police portal integration
- AI incident summarization
- GPS & timestamp certification
- Blockchain evidence verification

Contributions
Contributions and suggestions are welcome!
Feel free to fork and submit pull requests.
