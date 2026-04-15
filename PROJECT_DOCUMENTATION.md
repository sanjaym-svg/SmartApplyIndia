# SmartApply India - Project Documentation

## 1. Overview
SmartApply India is a modern Flutter application designed to assist job seekers. It features an ATS (Applicant Tracking System) engine, an AI service layer, and smart resume tailoring capabilities to enhance user employment prospects. The application is built using a clean structure with features modularized appropriately.

## 2. Technology Stack
*   **Framework:** Flutter (SDK ^3.11.0)
*   **State Management:** Provider (`provider: ^6.1.5+1`)
*   **Backend & Database:** Supabase (`supabase_flutter: ^2.12.0`) & Firebase Core / Auth.
*   **UI/UX Libraries:** 
    *   `google_fonts` (Typography)
    *   `flutter_animate` (Animations)
    *   `shimmer` (Loading states)
    *   `percent_indicator` (Progress indicators)
    *   `iconsax` & `cupertino_icons` (Iconography)
*   **Utilities:** `file_picker` (Resume uploading), `syncfusion_flutter_pdf` (PDF Parsing & Generation), `http` (Network requests).

## 3. Architecture & Folder Structure
The codebase follows a feature-first architectural pattern, making it scalable and easy to maintain.

```text
lib/
│── core/               # Shared utilities, theming, and generic widgets
│   ├── config/         # Application configurations
│   ├── theme/          # App theme definitions (AppTheme.darkTheme)
│   └── widgets/        # Reusable UI components
│
│── features/           # Independent feature modules
│   ├── auth/           # Authentication UI (Login, Signup)
│   ├── bookmarks/      # Saved jobs management
│   ├── jobs/           # Job discovery and listing
│   ├── profile/        # User profile and settings
│   ├── resume/         # Resume builder and viewer
│   └── splash/         # Initial splash screen
│
│── models/             # Data models representing domain entities
│   └── job_model.dart  # Core Job entity definition
│
│── navigation/         # Routing and navigation wrappers
│   └── app_shell.dart  # Main Shell holding the BottomNavigationBar structure
│
│── services/           # Business logic, state, and external integrations
│   ├── ai_service.dart       # AI integration (e.g., Resume optimization)
│   ├── ats_engine.dart       # ATS parsing and scoring logic
│   ├── auth_service.dart     # Authentication backend interactions
│   ├── auth_state.dart       # Global authentication state (Provider)
│   ├── bookmark_service.dart # Global bookmarks state (Provider)
│   ├── job_service.dart      # Fetching and managing jobs data
│   ├── resume_service.dart   # Managing user resumes (Provider)
│   └── supabase_service.dart # Supabase client management
│
└── main.dart           # App entry point, Provider initialization
```

## 4. Key Components and Processes

### 4.1 State Management (Provider)
The application relies heavily on Provider for global state management. In `main.dart`, the `MultiProvider` injects the following instances down the widget tree:
*   `AuthState`: Tracks the user's authentication session and status.
*   `ResumeService`: Manages resume configurations and locally cached resume data.
*   `BookmarkService`: Keeps track of user-bookmarked jobs globally, allowing immediate UI updates across different screens.

### 4.2 ATS processing and AI capabilities
The presence of `ats_engine.dart` and `ai_service.dart` defines the core USP of the application. 
*   **ATS Engine:** Likely utilizes keyword matching, text extraction via `syncfusion_flutter_pdf`, and heuristic comparisons between resumes and job descriptions to provide compatibility scores.
*   **AI Service:** Potentially uses AI (e.g., OpenAI or Gemini via HTTP) to propose resume improvements, rewrite bullet points, or auto-generate cover letters directly addressing ATS gaps.

### 4.3 Backend Integration (Supabase & Firebase)
*   Supabase is initialized early in the process (`SupabaseService().init()`) inside `main.dart`. It implies that the core database (jobs, user profiles) and potentially authentication rely on Supabase.
*   Firebase is also listed in dependencies (`firebase_core`, `firebase_auth`), indicating a potential hybrid setup (e.g., Firebase for Auth, Supabase for Database) or transitioning between the two.

### 4.4 Flow 
1.  **Splash Screen (`features/splash`):** App initialization, verifying auth state and backend connection.
2.  **Authentication (`features/auth`):** If no valid session is found, users are directed here to sign in or register.
3.  **App Shell (`navigation/app_shell.dart`):** Once authenticated, the user lands in the shell which houses a bottom navigation bar.
4.  **Jobs (`features/jobs`):** The primary feed of available jobs loaded via `job_service.dart`.
5.  **Resume builder/viewer (`features/resume`):** Allows users to create/upload their resume and evaluate it against open roles via the ATS Engine.

## 5. Development Guidelines
*   **Feature Modules:** Any new logical domain (e.g., "Interviews") should be added under `lib/features/` with its own UI components.
*   **Services:** External network calls, AI integrations, or local storage access should go into `lib/services/`. Emitting state changes should be done carefully extending `ChangeNotifier` if global state is required.
*   **Widgets:** Any UI piece used in more than one feature should be extracted to `lib/core/widgets/`.
