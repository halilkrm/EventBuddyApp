<div align="center">

# 🎉 EventBuddyApp

An iOS event and invitation application built with **SwiftUI**, **Firebase Authentication**, and **Cloud Firestore**.

![Swift](https://img.shields.io/badge/Swift-iOS-F05138?logo=swift&logoColor=white)
![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-0D96F6?logo=swift&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-Auth%20%2B%20Firestore-FFCA28?logo=firebase&logoColor=black)

</div>

---

## Overview

The current source code implements an authenticated event workflow backed by Firebase.

Users can create events, invite users by email, view events according to participant status, accept or reject pending invitations, delete events when they are the owner, and sign out.

---

## Implemented Features

### Authentication

- Firebase Authentication state observation
- Authenticated user session stored in `MainViewModel`
- Sign-out through `Auth.auth().signOut()`

### Event Creation

The event form includes:

- title
- date
- location
- description
- comma-separated invitee email addresses

The save action calls `EventListViewModel.addEvent(...)`.

### Firestore Event Storage

New event documents are added to:

```text
events
```

The stored fields used by the current source are:

```text
title
date
description
location
createdById
participants
```

`participants` is a map from user UID to status.

### Invitation Statuses

The current code uses these status strings:

| Status | Current code behavior |
|---|---|
| `owner` | Event owner |
| `pending` | Invitation waiting for response |
| `accepted` | Accepted invitation |
| `rejected` | Rejected invitation |

### Email-to-UID Resolution

Invitee emails are queried from the Firestore `users` collection.

The current source reads:

```text
email
uid
```

from matching user documents before building the participant map.

### Firestore Snapshot Listeners

`EventListViewModel` installs separate snapshot listeners for:

- events where the current user is `owner`
- events where the current user is `accepted`
- events where the current user is `pending`

Owned and accepted events are merged into the main event list. Pending events are published separately.

### Invitation Actions

- Accept: updates `participants.<userID>` to `accepted`
- Reject: updates `participants.<userID>` to `rejected`

### Delete Check

Before deleting an event, the current code checks:

```swift
event.participants[userID] == "owner"
```

Only then does it call Firestore document deletion.

---

## Main Source Files

```text
EventBuddy/
└── EventBuddy/
    ├── AddEventView.swift
    ├── EventListViewModel.swift
    ├── MainViewModel.swift
    ├── Event.swift
    └── ...
```

---

## Firebase Data Shape Used by the Code

```text
events/{eventId}
├── title
├── date
├── description
├── location
├── createdById
└── participants
    └── {userId}: owner | pending | accepted | rejected
```

The invite lookup code also queries:

```text
users
├── email
└── uid
```

---

## Getting Started

### Requirements

- macOS
- Xcode
- iOS Simulator or physical iOS device
- Firebase project

### Clone

```bash
git clone https://github.com/halilkrm/EventBuddyApp.git
cd EventBuddyApp
```

Open the included Xcode project.

### Firebase

The current source imports and uses:

- Firebase Authentication
- Cloud Firestore

A Firebase configuration compatible with the project is required to run those flows.

---

## Current Code Notes

- Firestore collection and field names are hard-coded in the source.
- Email invitation lookup depends on matching documents in the `users` collection.
- The Firestore `in` query used for email lookup has service-side query constraints.
- The repository includes Firebase configuration for the checked-in project; forks should use configuration appropriate to their own Firebase project.

---

## License

This repository contains an MIT License.
