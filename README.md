# StrongNet WiFi Management Suite

StrongNet is a full-stack internet service management solution composed of a Dart Frog backend API and a Flutter client application. The platform supports administrators, customers, and business owners in managing service packages, customer accounts, invoicing, payments, and financial reports.

## Repository Structure
- **`backend_api/`** – Dart Frog REST API backed by PostgreSQL. Houses routing logic under `routes/`, data models in `lib/models/`, shared middleware in `lib/middlewares/`, and database connectivity via `lib/database.dart`.
- **`project_wifi/`** – Flutter application delivering role-based experiences. UI pages live under `lib/pages/`, data models under `lib/models/`, services for networking and exports under `lib/services/`, and shared styling/utilities in `lib/utils/`.
- **`summary.md`** – High-level walkthrough of both projects’ architecture, data flow, and integration notes.

## High-Level Architecture
1. **Authentication** – `backend_api/routes/login/` verifies bcrypt-hashed credentials; `routes/register/` provisions customer users and linked records. The Flutter app (`project_wifi/lib/pages/login_page.dart`) stores session details with `shared_preferences` and `flutter_secure_storage`.
2. **Core Domain Modules**
   - Packages (`paket`): CRUD endpoints (`backend_api/routes/paket/`) matched by Flutter admin screens (`project_wifi/lib/pages/admin/paket/`).
   - Customers (`pelanggan`): Registration, onboarding, and management, syncing `backend_api/routes/pelanggan/` with admin tooling in `project_wifi/lib/pages/admin/pelanggan/`.
   - Invoices (`tagihan`): Generation and lifecycle management via `backend_api/routes/tagihan/`; surfaced in admin and customer views under `project_wifi/lib/pages/admin/tagihan/` and `project_wifi/lib/pages/user/tagihan/`.
   - Payments (`pembayaran`): Multipart uploads processed server-side (`backend_api/routes/pembayaran/`) with image compression and verification workflows mirrored in `project_wifi/lib/pages/admin/pembayaran/` and `lib/pages/user/pembayaran/`.
3. **Reporting & Dashboards** – Server aggregations (`backend_api/routes/dashboard/`, `routes/report/`, `routes/pdf/`) feed Flutter dashboards (`project_wifi/lib/pages/admin/dashboard_admin_page.dart`, `lib/pages/report_page.dart`, `lib/pages/user/dashboard_user_page.dart`).

## Backend (`backend_api/`)
- **Tech Stack**: Dart Frog, PostgreSQL, `package:postgres` for DB access, `package:bcrypt` for password hashing, `package:image` for payment proof processing.
- **Configuration**:
  - Database connection defaults in `lib/database.dart`; adapt host, port, db name, user, and password for your environment.
  - Ensure PostgreSQL has tables matching the expected schema (`users`, `pelanggans`, `pakets`, `tagihans`, `pembayarans`).
- **Running Locally**:
  1. Install the Dart SDK and Dart Frog CLI (`dart pub global activate dart_frog_cli`).
  2. Install dependencies:
     ```bash
     dart pub get
     ```
  3. (Optional) Run database migrations/seed scripts to populate baseline data.
  4. Start the development server:
     ```bash
     dart_frog dev
     ```
  5. API exposed at `http://localhost:8080` by default (adjust if you bind a different port).
- **Key Endpoints** (representative):
  - `POST /login` – Authenticates existing users.
  - `POST /register` – Registers new customers and linked customer metadata.
  - `GET|POST /paket` – Manage service packages.
  - `GET|POST /pelanggan` – Retrieve and create customer records.
  - `GET|POST /tagihan` & `GET|PUT|DELETE /tagihan/{id}` – Manage invoices.
  - `GET|POST /pembayaran` – List and receive payment submissions with proof images.
  - `GET /dashboard`, `GET /dashboard_user/{pelangganId}` – Dashboard statistics for admin and individual customers.
  - `GET /report?year=YYYY` – Yearly payment status matrix; `GET /report/total_income?year=YYYY` for income summaries.

## Flutter App (`project_wifi/`)
- **Tech Stack**: Flutter, `http` for networking, `shared_preferences` & `flutter_secure_storage` for session persistence, `image` for client-side compression, and `intl` for localization.
- **Configuration**:
  - Update `lib/utils/constants.dart` to point `AppConstants.baseUrl` at your backend instance (e.g., LAN IP vs. localhost).
  - Ensure platform-specific configs (`android/`, `ios/`, etc.) have appropriate network permissions (e.g., cleartext traffic for dev LAN URLs).
- **Running Locally**:
  1. Install Flutter SDK and platform toolchains.
  2. Fetch dependencies:
     ```bash
     flutter pub get
     ```
  3. Launch emulator or connect a device.
  4. Start the app:
     ```bash
     flutter run
     ```
- **Role-Based Navigation**:
  - `admin` role: Access to dashboards, package/customer management, invoice creation, payment verification, and financial reports via `MainLayout` (`project_wifi/lib/widgets/main_layout.dart`).
  - `pelanggan` role: Customer dashboards, invoice list, payment upload workflow, and profile management.
  - `owner` role: High-level dashboards and reports.
- **Networking Layer**: `lib/services/api_service.dart` centralizes REST calls, handles JSON serialization (`lib/models/`), performs multipart uploads, and enforces timeouts.

## Development Tips
- Sync backend connection parameters with Flutter’s `AppConstants.baseUrl`.
- Consider adding environment-specific configuration (e.g., `.env`) and secrets management before production deployment.
- Expand automated tests in both projects (`backend_api/test/`, `project_wifi/test/`).
- Document database migrations and sample seed data for easier onboarding.
- For GitHub Pages or screenshots, embed assets under `project_wifi/assets/` and reference them in the README as needed.

## License
No explicit license is defined. Add one (e.g., MIT) if you plan to open-source the repository.
