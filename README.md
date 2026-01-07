# OhYes Client

A native macOS client to notify the user when an OhYes reminder is due.

## Requirements

- macOS 13.0 or later (Apple Silicon)
- Xcode 14.0 or later
- Swift 5.9 or later

## Features

- **Main Window**: Displays text messages with newest messages at the top
- **File Menu**:
  - About: Shows application information
  - Exit: Quits the application
- **View Menu**:
  - Clear: Clears all messages from the view (⌘K)
- **SQLite Integration**: Connects to a local SQLite database with Todo table
- **Automatic Polling**: Checks for due todos every 60 seconds
- **Notifications**: Plays a sound and displays todo text when a reminder is due
- **Configuration**: Database location specified in a config file

## Installation

1. Clone the repository:
```bash
git clone [repository-url]
cd ohyes-client
```

2. Open the project in Xcode:
```bash
open OhYesClient.xcodeproj
```

3. Wait for Swift Package Manager to resolve dependencies (SQLite.swift)

4. Build and run the project (⌘R)

## Configuration

On first launch, the application creates a configuration file at:
```
~/Library/Application Support/OhYesClient/config.json
```

The default configuration:
```json
{
  "databasePath": "/Users/ron/sources/ohyes/target/todo.db"
}
```

You can modify this file to point to a different database location.

### Database Schema

The application expects a SQLite database with a `Todo` table:

```sql
CREATE TABLE Todo (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    text TEXT NOT NULL,
    comment TEXT,
    completed TEXT CHECK(completed IN ('Y', 'N')) NOT NULL DEFAULT 'N',
    due TIMESTAMP,
    priority INTEGER CHECK(priority >= 0 AND priority <= 9) NOT NULL DEFAULT 0
);
```

**Note**: Timestamps are stored as milliseconds since epoch.

## Building from Command Line

```bash
xcodebuild -project OhYesClient.xcodeproj -scheme OhYesClient -destination 'platform=macOS' build
```

## How It Works

1. **Startup**: The app connects to the configured SQLite database
2. **Polling**: Every 60 seconds, the app checks for todos where:
   - `completed` = 'N' (not completed)
   - `due` timestamp ≤ current time
3. **Notification**: When a due todo is found:
   - The `text` field is added to the top of the message view
   - A system beep sound plays
   - The todo ID is tracked to avoid duplicate notifications
4. **Display**: Messages appear in the main window with newest at the top

## Project Structure

```
OhYesClient/
├── OhYesClientApp.swift       # Main app entry point with menu configuration
├── ContentView.swift           # Main view displaying messages
├── Models/
│   ├── Message.swift           # Message data model
│   ├── MessageStore.swift      # Message state management
│   ├── Config.swift            # Configuration management
│   └── Todo.swift              # Todo data model matching database schema
├── Database/
│   └── DatabaseManager.swift   # SQLite database connection and queries
├── Services/
│   └── TodoPollingService.swift # Background polling service (60s interval)
└── Info.plist                  # App metadata
```

## Development

### Adding Messages

The `MessageStore` class manages messages. To add a message programmatically:

```swift
messageStore.addMessage("Your message here")
```

### Polling Service

The `TodoPollingService` automatically starts when the app launches and runs in the background. It:
- Checks for due todos every 60 seconds
- Filters for incomplete todos (`completed = 'N'`)
- Orders results by priority (descending) and due date (ascending)
- Plays a system beep when a todo is due
- Tracks notified todos to prevent duplicate notifications

## License

Copyright © 2024. All rights reserved.
