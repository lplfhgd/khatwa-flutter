# Project Development Rules

## 1. Project Stack
- Flutter and Dart.
- GetX for state management and navigation.
- Firebase Authentication and Cloud Firestore when required.
- Dio for REST API requests.
- Singleton DioClient for shared Dio configuration.
- Service classes for external data access.
- Models for structured data.

## 2. Required Architecture
- Keep feature code inside lib/features/<feature_name>/.
- Keep shared configuration and reusable tools inside lib/core/.
- Keep genuinely shared widgets inside lib/shared/widgets/.
- Every feature should use the relevant folders:
  models/, services/, controllers/, bindings/, views/, widgets/.
- Do not create unnecessary folders or classes for trivial code.
- Do not change the agreed project structure without approval.

## 3. Layer Responsibilities
- Views contain UI and user input only.
- Controllers manage observable UI state and call Services.
- Services handle Firebase, Dio, and external data access.
- Models convert JSON or Firestore data to Dart objects.
- Bindings register dependencies.
- Views must not call Firebase or Dio directly.
- Controllers must not contain raw HTTP requests or Firestore queries.

## 4. GetX Rules
- Use GetxController with .obs and Obx for reactive state.
- Use Bindings for dependency registration.
- Do not put Get.put() inside build().
- Do not mix GetBuilder and Obx for the same state without a clear reason.
- Keep navigation consistent with the existing app routes.

## 5. API Rules
- Use the existing DioClient Singleton.
- Do not create another Dio instance in feature Services.
- Use typed Models instead of passing dynamic JSON through the UI.
- Handle loading, errors, and empty results.
- Never invent an API endpoint or response structure.
- Inspect existing API code and documentation first.

## 6. Firebase Rules
- Put Firebase operations in Service classes.
- Keep Firestore mapping out of Views.
- Respect existing Firestore Security Rules.
- Never weaken security rules just to make a feature work.
- Never add service-account files, private keys, passwords,
  or secrets to the repository.

## 7. Coding Rules
- Follow existing naming and formatting conventions.
- File names use snake_case.dart.
- Class names use PascalCase.
- Variables and methods use camelCase.
- Reuse existing widgets and utilities.
- Avoid duplicate code and unnecessary dependencies.
- Do not rewrite unrelated files.
- Do not change routes, main.dart, or shared configuration
  unless the task requires it.

## 8. AI Work Process
Before coding:
1. Read these instructions.
2. Inspect the relevant files and existing patterns.
3. Explain the planned changes and files to be modified.
4. Ask questions if requirements are unclear.

While coding:
- Implement only the requested task.
- Keep the change small and consistent with the project.
- Do not replace the app architecture.
- Do not invent missing business requirements.
- Do not silently add packages.

After coding:
1. Summarize every file changed.
2. Explain the important decisions.
3. Run dart format on changed Dart files.
4. Run flutter analyze when possible.
5. Report errors honestly; never claim a test passed unless it ran.
6. Provide manual test steps.
7. Mention any assumptions or unfinished work.

## 9. Student Responsibility
- Students must read and understand AI-generated code.
- Never accept code that the student cannot explain.
- AI-generated code must be reviewed and tested.
- Ask before broad refactoring or modifying unrelated features.