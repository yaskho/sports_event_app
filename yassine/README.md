MatchApp 🏅

A Flutter-based mobile application for organizing, joining, and managing sports events. Users can create events, join existing ones, track participants, manage their profile, and receive notifications about events. Firebase is used for authentication, data storage, and real-time updates.




#Table of Contents:

Overview

Features:

Project Structure:

Screenshots
 (optional, if you want to add)

Getting Started

Dependencies

Architecture & Flow

Contributing


Overview:



This project allows sports enthusiasts to:

Create Events: Organize matches with sport type, date, time, location, and max players.

Join Events: Participate in events while checking capacity.

Manage Events: Add/remove participants or delete events if you are the organizer.

Profile Management: Update personal information, view joined/created events, and edit profile details.

Notifications: Receive alerts for event updates, reminders, or participant changes.

Location Integration: Pick event locations via maps and geocoding.

The app uses Object-Oriented Programming (OOP) principles for modular, maintainable, and reusable code.



Features



User Authentication: Firebase Authentication (email/password).

Event Management: Create, join, quit, delete, and track events.

Real-time Updates: Live updates for events and participants using Firestore streams.

Profile Management: Users can edit profile information like name, email, or avatar.

Notifications: Event reminders, participant updates, or organizer actions (Firebase Cloud Messaging).

Location Picker: Select event locations on Google Maps.

Categorized Events: Lists events by joined, not joined, and created by the user.

UI: Dark-themed Flutter UI with responsive design and smooth UX.



Project Structure
lib/
│
├─ models/
│   ├─ event_model.dart         # Event data structure and Firestore mapping
│   └─ user_model.dart          # User profile model
│
├─ services/
│   ├─ event_service.dart       # Event logic, Firestore CRUD operations
│   ├─ user_service.dart        # Profile update and user-related Firestore operations
│   └─ notification_service.dart # Handles sending/receiving notifications
│
├─ screens/
│   ├─ create_event.dart        # Screen to create new events
│   ├─ view_events.dart         # Screen to view/join events
│   ├─ localisation_screen.dart # Location picker screen
│   ├─ profile_screen.dart      # User profile view & edit
│   └─ auth/                   # Authentication screens (login/signup)
│
├─ widgets/
│   └─ event_card.dart          # Reusable UI widget to display an event
│
├─ main.dart                    # App entry point
└─ routes.dart                  # App routes and navigation



Architecture & Flow
OOP & Modular Design



Models:

EventModel → Stores event data (sport, participants, date/time, location).

UserModel → Stores user profile data.

Converts between Firestore documents and Dart objects.

Services:

EventService → Firestore operations: create, join, quit, delete, get events.

UserService → Firestore operations for profile update and fetching user data.

NotificationService → Handles sending and receiving notifications (Firebase Cloud Messaging).

Screens (UI Layer):

CreateEventScreen → Forms + calls EventService to create events.

ViewEventsScreen → Lists events, organized by status (joined/not joined/created).

EventDetailScreen → Allows joining, quitting, managing participants, and sending notifications.

ProfileScreen → View and edit user profile.

LocationPickerScreen → Handles Google Maps location selection.

Widgets:

EventCard → Reusable card to display event info in lists



Data Flow Example


Creating an Event:


User fills form → CreateEventScreen collects data → EventService.createEvent() → Firestore → NotificationService sends alerts


Joining an Event:

User taps Join → EventService.joinEvent() → Firestore updates participants → Stream updates UI → NotificationService triggers alerts


Editing Profile:


User edits data → ProfileScreen → UserService.updateProfile() → Firestore → UI updates in real-time





Getting Started





Clone the repository:

git clone https://github.com/yaskho/sports-event-app.git
cd sports-event-app


Install dependencies:

flutter pub get


Configure Firebase:

Add google-services.json (Android) / GoogleService-Info.plist (iOS)

Enable Firestore, Authentication, and Cloud Messaging in Firebase console

Run the app:

flutter run



Dependencies:




flutter ≥ 3.0

firebase_core

firebase_auth

cloud_firestore

firebase_messaging

google_maps_flutter

geolocator

geocoding

intl

(Add versions as per your pubspec.yaml)



Contributing:



Contributions are welcome!

Fork the repo

Create a feature branch (git checkout -b feature/new-feature)

Commit changes (git commit -m "Add new feature")

Push branch (git push origin feature/new-feature)

Create a pull request

License

MIT License © yassine and rassil