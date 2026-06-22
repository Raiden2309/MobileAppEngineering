
---

# Academic Workload & Burnout Monitoring Application

This repository contains the cross-platform frontend application built using **Flutter** and **Firebase**. The system is designed to bridge the gap between students managing academic stress and lecturers tracking classroom engagement, featuring built-in **AI-driven workload analysis** to detect and prevent student burnout.

## App Architecture

The codebase follows a modular feature-by-role design architecture using `Provider` for state management and separation of concerns (`controllers`, `models`, `providers`, `views`).

```
lib/
├── modules/
│   ├── auth/                 # Authentication flows (Email, OTP, Google Sign-In)
│   ├── new_user_setup/       # Interactive onboarding and profile generation
│   └── role/
│       ├── student/          # Task management, study planners, burnout monitors
│       └── lecturer/         # Class analytics, student burnout trackers, task assigners
├── shared/
│   ├── services/             # AI Engine, Caching, and Notifications
│   └── styles/               # Design system colors and typographies
└── main.dart                 # Application entry point

```

---

## Core Features

### 🔐 1. Authentication & Onboarding

* **Multi-Platform Sign-In**: Integrated OAuth mechanisms via Google Sign-In variants for Web, Mobile, and Desktop platforms.
* **Role-Based Access Control**: Strict routing partition separating Student interfaces from Lecturer management hubs during setup.

### 🎓 2. Student Suite

* **Burnout Alert System**: Real-time workload monitor assessing pending academic stressors and triggering active warnings.
* **Dynamic Study Planner**: Automated study block distribution mapping out a weekly schedule around locked personal time.
* **Semester Progress Dashboard**: Micro and macro views tracking completion timelines for assigned subjects.

### 🧑‍🏫 3. Lecturer Analytics Dashboard

* **Burnout Index Radar**: Deep breakdown graphs visualizing individual student mental fatigue and critical workload limits.
* **Classroom Engagement Monitors**: Aggregated completion statistics reflecting general course engagement.
* **Universal Task Issuer**: Direct distribution pipelines enabling assignment creation, updates, and scheduling filters across active classes.

### 🧠 4. Core Shared Services

* **AI Service (`ai_service.dart`)**: Predictive engine scoring individual workload complexities to evaluate imminent burnout risks.
* **Notification Engine**: Local and push mechanics signaling upcoming deadlines, schedule revisions, and wellness thresholds.
* **Local Cache Architecture**: Secure storage parameters enabling quick data loads and offline structural state preservation.

---

## Technical Stack

* **Framework**: Flutter (Dart)
* **Supported Platforms**: Android, iOS, Web, macOS, Windows, Linux
* **State Management**: Provider Architecture
* **Backend Integration**: Firebase Suite (Authentication, Functions, Firestore Configuration)
* **Code Analysis**: Custom strict Dart rules configuration (`analysis_options.yaml`)

---

## Getting Started

### Prerequisites

* Flutter SDK installed on your local machine.
* Firebase CLI setup if backend changes are required.

### Installation

1. Clone the repository:
```bash
git clone 
```

2. Navigate into the project directory:
 ```bash
cd MobileAppEngineering-01283203caec7cb46939f7bb40df7b545896cabd
```

3. Fetch the required dependencies:
```bash
 flutter pub get
```

4. Run the application on your desired platform:
```bash
flutter run
```

### Running Tests

The project contains unit and state provider testing directories mimicking both user roles:   

```bash
flutter test

```
