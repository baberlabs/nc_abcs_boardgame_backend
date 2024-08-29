# Northchess Backend

This is the back-end implementation of **Northchess**, a chess game built using **Dart**. The backend provides the necessary server-side functionality to support the chess game developed using Flutter. This project is created as part of the **Northcoders Bootcamp** to demonstrate our skills in server development and real-time communication.

## Frontend Integration

The frontend of this project can be found here: **[Northchess Frontend](https://github.com/henryloach/nc_abcs_boardgame_frontend)**.

It is built using Flutter and Dart, and it communicates with this backend server to provide a complete chess game experience.

## Features

-   **WebSocket Server**: Handles real-time communication between players.
-   **Game Management**: Manages game instances, including player connections and game state.
-   **HTTP Endpoints**: Provides basic HTTP routes for health checks and server information.

## Tech Stack

-   **Language**: Dart
-   **Framework**: Dart's `dart:io` library
-   **Dependencies**:
    -   `test`: For unit testing the server.
    -   `lints`: For maintaining code quality and consistency.

## How to Run

1. Ensure that you have the **Dart SDK** installed on your local machine.
2. Clone the repository.
3. Run `dart pub get` to install the required dependencies.
4. Start the server by running:

```bash
$ dart run bin/server.dart
```

The server will listen on port 8080 by default. You can change the port in the start method of `server.dart`.

## Running Tests

To run the tests for the server, use:

```bash
$ dart test
```

## Northcoders Bootcamp

This project is built as part of the Northcoders Bootcamp, a program designed to train developers in modern software engineering techniques. It showcases our ability to work with Flutter, Dart, and game development concepts.

## Contributors

Brought to life by **Team ABCs** of Northcoders' June 2024 Software Development Cohort:

-   **[Ahmad Mustuffar](https://github.com/amustaffar)**
-   **[Baber Khan](https://github.com/baberlabs)**
-   **[Christian Loach](https://github.com/henryloach)**
-   **[Svitlana Horodylova](https://github.com/horodylova)**

Feel free to check out our GitHub profiles for other projects and contributions!
Thank you for checking out our project! 🎉
