# Museum Guide System

This project is a Flutter-based indoor navigation app for a museum. It models the museum as a graph of rooms and calculates the shortest path between a start location and a destination using the Floyd-Warshall shortest-path algorithm.

## What this system does

The app lets a user:

- choose a starting room
- choose a destination room
- calculate the optimal route through the museum
- see the total walking distance in meters
- view the exact sequence of rooms along the route
- explore a visual museum map with the path highlighted on screen

The system is designed to behave like a digital guide for visitors navigating a building with multiple connected rooms.

## Core idea

The museum is represented as a weighted graph:

- each room is a node
- each corridor/connection is an edge
- each edge has a distance value in meters

The graph data is stored in an adjacency matrix inside the Flutter app. The algorithm computes the shortest path between any two nodes and returns the ordered list of rooms to traverse.

## Key algorithm

The routing logic is implemented in the `FloydWarshall` class in `lib/main.dart`.

It works like this:

1. Build a 14x14 distance matrix for the museum.
2. Initialize direct connections between rooms with their travel distances.
3. Repeatedly compare paths through intermediate nodes.
4. Update the best-known route whenever a shorter route is found.
5. Reconstruct the final path from the start room to the destination room.

This is a classic all-pairs shortest path approach, which is ideal for a small fixed map like this museum layout.

## App structure

### Main screen
The app's main screen is `MuseumMapScreen`, which contains:

- a dark museum-themed UI
- a navigation panel for selecting start and destination
- a route summary with distance and room-by-room path
- an interactive SVG map of the museum

### Map and visualization
The museum layout is drawn using an SVG floor map and a custom painter:

- `SvgPicture.asset('assets/museum_map.svg')` loads the floor plan
- `NeonBlueprintOverlayPainter` draws the route as a glowing path
- start and end locations are marked with green and red pins
- path segments show distance labels such as `18m`

### Navigation panel
The left or bottom panel allows the user to:

- swap start and destination
- reset zoom on the map
- toggle the navigation panel on desktop layouts
- inspect the traversed room sequence

## Museum graph

The app contains a predefined set of rooms:

- Entrance Lobby
- Great Hall
- Cafe & Shop
- Elevators
- Restrooms
- Special Exhibit B
- Egypt Exhibit
- Special Exhibit A
- Curator Office
- Lecture Theatre
- Rome Gallery
- Greek Gallery
- Lower Exhibit A
- Lower Exhibit B

Each room has coordinates in the map and is connected by distances such as 10m, 12m, 15m, and so on.

## How the route is calculated in practice

When the user picks a start room and destination room:

- the app computes `route = fw.getPath(startNode, endNode)`
- it reads `fw.dist[startNode][endNode]` for the total cost
- the path is drawn on the map
- the route list is displayed in the panel

If no valid connection exists, the app shows a “No path found” message.

## Files of interest

- `lib/main.dart` — complete app logic, graph, algorithm, UI, and map rendering
- `assets/museum_map.svg` — museum blueprint used as the base map
- `test/widget_test.dart` — basic widget test

## Technologies used

- Flutter
- Dart
- SVG rendering
- Custom painting for route overlays
- Material Design UI

## Running the app

From the project root:

```bash
flutter pub get
flutter run
```

## Summary

This system is a small but complete indoor wayfinding app that turns a building blueprint into a weighted route graph, calculates the shortest route with Floyd-Warshall, and renders the result interactively for users in a clean museum navigation interface.
