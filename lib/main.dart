import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(const MuseumApp());
}

class AppColors {
  static const Color background = Color(0xFF181818);
  static const Color panelBackground = Color(0xFF202225);
  static const Color cardColor = Color(0xFF2C2F33);
  static const Color neonCyan = Color(0xFF00E5FF);
  static const Color neonBlue = Color(0xFF00B0FF);
  static const Color startNode = Colors.greenAccent;
  static const Color endNode = Colors.redAccent;
}

class MuseumApp extends StatelessWidget {
  const MuseumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'City Historical Museum Guide',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.background,
        cardColor: AppColors.cardColor,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.neonCyan,
          surface: AppColors.panelBackground,
        ),
      ),
      home: const MuseumMapScreen(),
    );
  }
}

// -----------------------------------------------------------------------------
// 1. FLOYD-WARSHALL ALGORITHM ENGINE
// -----------------------------------------------------------------------------
class FloydWarshall {
  static const double inf = 999999.0;
  final int numNodes;
  late List<List<double>> dist;
  late List<List<int>> next;

  FloydWarshall(List<List<double>> graph) : numNodes = graph.length {
    dist = List.generate(numNodes, (i) => List.from(graph[i]));
    next = List.generate(numNodes, (i) => List.filled(numNodes, -1));

    // Initialize next/predecessor matrix
    for (int i = 0; i < numNodes; i++) {
      for (int j = 0; j < numNodes; j++) {
        if (graph[i][j] != inf && i != j) {
          next[i][j] = j;
        }
      }
    }

    // Floyd-Warshall O(V^3)
    for (int k = 0; k < numNodes; k++) {
      for (int i = 0; i < numNodes; i++) {
        for (int j = 0; j < numNodes; j++) {
          if (dist[i][k] != inf &&
              dist[k][j] != inf &&
              dist[i][k] + dist[k][j] < dist[i][j]) {
            dist[i][j] = dist[i][k] + dist[k][j];
            next[i][j] = next[i][k];
          }
        }
      }
    }
  }

  /// Reconstructs the exact node traversal sequence from start to target
  List<int> getPath(int start, int target) {
    if (dist[start][target] == inf) return [];
    if (start == target) return [start];

    List<int> path = [start];
    int curr = start;
    while (curr != target) {
      curr = next[curr][target];
      if (curr == -1) return []; // Unreachable path
      path.add(curr);
    }
    return path;
  }
}

// -----------------------------------------------------------------------------
// 2. MAIN MAP SCREEN
// -----------------------------------------------------------------------------
class MuseumMapScreen extends StatefulWidget {
  const MuseumMapScreen({super.key});

  @override
  State<MuseumMapScreen> createState() => _MuseumMapScreenState();
}

class _MuseumMapScreenState extends State<MuseumMapScreen>
    with SingleTickerProviderStateMixin {
  // 14 Room Nodes List (Aligned with SVG labels)
  final List<String> roomNames = [
    'Entrance Lobby',       // 0
    'Great Hall',           // 1
    'Cafe & Shop',          // 2
    'Elevators',            // 3
    'Restrooms',            // 4
    'Special Exhibit B',    // 5 (Top Left)
    'Egypt Exhibit',        // 6
    'Special Exhibit A',    // 7 (Top Right)
    'Curator Office',       // 8
    'Lecture Theatre',      // 9
    'Rome Gallery',         // 10
    'Greek Gallery',        // 11
    'Lower Exhibit A',      // 12 (Lower Middle-Right)
    'Lower Exhibit B',      // 13 (Lower Far-Right)
  ];

  // Canvas positions (X, Y) calibrated for an 850x500 viewport
  final List<Offset> roomCoords = const [
    Offset(425, 430), // 0: Entrance Lobby
    Offset(425, 230), // 1: Great Hall
    Offset(235, 430), // 2: Cafe & Shop
    Offset(75,  430), // 3: Elevators
    Offset(75,   75), // 4: Restrooms
    Offset(235,  75), // 5: Special Exhibit B
    Offset(425,  75), // 6: Egypt Exhibit
    Offset(640,  75), // 7: Special Exhibit A
    Offset(745,  55), // 8: Curator Office
    Offset(810, 115), // 9: Lecture Theatre
    Offset(640, 230), // 10: Rome Gallery
    Offset(800, 230), // 11: Greek Gallery
    Offset(620, 430), // 12: Lower Exhibit A
    Offset(780, 430), // 13: Lower Exhibit B
  ];

  late FloydWarshall fw;
  late AnimationController _glowController;
  final TransformationController _transformationController = TransformationController();
  
  int startNode = 0;  // Default: Entrance Lobby
  int endNode = 11;   // Default: Greek Gallery
  bool _showPanel = true;

  @override
  void initState() {
    super.initState();
    const double inf = FloydWarshall.inf;

    // 14x14 Corrected Adjacency Matrix matching blueprint connections
    List<List<double>> graph = [
      // 0    1    2    3    4    5    6    7    8    9   10   11   12   13
      [  0,  15,  12, inf, inf, inf, inf, inf, inf, inf, inf, inf,  12, inf], // 0: Entrance
      [ 15,   0, inf, inf, inf, inf,  20, inf, inf, inf,  18, inf, inf, inf], // 1: Great Hall
      [ 12, inf,   0,  10, inf, inf, inf, inf, inf, inf, inf, inf, inf, inf], // 2: Cafe & Shop
      [inf, inf,  10,   0,  35, inf, inf, inf, inf, inf, inf, inf, inf, inf], // 3: Elevators
      [inf, inf, inf,  35,   0,  12, inf, inf, inf, inf, inf, inf, inf, inf], // 4: Restrooms
      [inf, inf, inf, inf,  12,   0, inf, inf, inf, inf, inf, inf, inf, inf], // 5: Spec Ex B
      [inf,  20, inf, inf, inf, inf,   0,  15, inf, inf, inf, inf, inf, inf], // 6: Egypt Exhibit
      [inf, inf, inf, inf, inf, inf,  15,   0,   8, inf, inf, inf, inf, inf], // 7: Spec Ex A
      [inf, inf, inf, inf, inf, inf, inf,   8,   0,  10, inf, inf, inf, inf], // 8: Curator
      [inf, inf, inf, inf, inf, inf, inf, inf,  10,   0, inf,  18, inf, inf], // 9: Lecture
      [inf,  18, inf, inf, inf, inf, inf, inf, inf, inf,   0,  15,  14, inf], // 10: Rome Gallery
      [inf, inf, inf, inf, inf, inf, inf, inf, inf,  18,  15,   0, inf, inf], // 11: Greek Gallery
      [ 12, inf, inf, inf, inf, inf, inf, inf, inf, inf,  14, inf,   0,  10], // 12: Lower Ex A
      [inf, inf, inf, inf, inf, inf, inf, inf, inf, inf, inf, inf,  10,   0], // 13: Lower Ex B
    ];

    fw = FloydWarshall(graph);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  void _swapLocations() {
    setState(() {
      final temp = startNode;
      startNode = endNode;
      endNode = temp;
    });
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    List<int> route = fw.getPath(startNode, endNode);
    double totalDistance = fw.dist[startNode][endNode];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Museum Guide', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.panelBackground,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.crop_free),
            tooltip: 'Reset Zoom',
            onPressed: _resetZoom,
          ),
          Builder(
            builder: (context) {
              final isDesktop = MediaQuery.of(context).size.width >= 800;
              if (!isDesktop) return const SizedBox.shrink();
              return IconButton(
                icon: Icon(_showPanel ? Icons.visibility_off : Icons.visibility),
                tooltip: 'Toggle Panel',
                onPressed: () {
                  setState(() {
                    _showPanel = !_showPanel;
                  });
                },
              );
            }
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 800;

          Widget mapCanvas = _buildMapCanvas(route);
          Widget panel = _buildNavigationPanel(route, totalDistance, isDesktop);

          if (isDesktop) {
            return Row(
              children: [
                if (_showPanel)
                  Container(
                    width: 320,
                    color: AppColors.panelBackground,
                    child: panel,
                  ),
                Expanded(child: mapCanvas),
              ],
            );
          } else {
            return Column(
              children: [
                Expanded(flex: 3, child: mapCanvas),
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.panelBackground,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    child: panel,
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildNavigationPanel(List<int> route, double totalDistance, bool isDesktop) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isDesktop ? 20.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.near_me, color: AppColors.neonCyan),
                  SizedBox(width: 8),
                  Text(
                    'Indoor Navigation',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.swap_vert, color: AppColors.neonCyan),
                tooltip: 'Swap locations',
                onPressed: _swapLocations,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // START SELECTOR
          const Text('START LOCATION',
              style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          _buildDropdown(
            value: startNode,
            onChanged: (val) {
              if (val != null) setState(() => startNode = val);
            },
          ),
          const SizedBox(height: 12),

          // END SELECTOR
          const Text('DESTINATION',
              style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          _buildDropdown(
            value: endNode,
            onChanged: (val) {
              if (val != null) setState(() => endNode = val);
            },
          ),

          const Divider(height: 24, color: Colors.white24),

          // ROOM TRAVERSAL LIST
          const Text('TRAVERSED ROOMS:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.neonCyan)),
          const SizedBox(height: 8),

          route.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Center(child: Text('No path found.', style: TextStyle(color: Colors.grey))),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: route.length,
                  itemBuilder: (context, index) {
                      int node = route[index];
                      bool isStart = index == 0;
                      bool isEnd = index == route.length - 1;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        child: ListTile(
                          dense: true,
                          leading: CircleAvatar(
                            radius: 12,
                            backgroundColor: isStart
                                ? AppColors.startNode
                                : (isEnd ? AppColors.endNode : AppColors.neonCyan),
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(fontSize: 11, color: Colors.black, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(
                            roomNames[node],
                            style: TextStyle(
                              fontWeight: (isStart || isEnd) ? FontWeight.bold : FontWeight.normal,
                              color: Colors.white,
                            ),
                          ),
                          subtitle: Text(
                            isStart ? 'Start Point' : (isEnd ? 'Destination' : 'Predecessor Room'),
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ),
                      );
                    },
                  ),

          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF121212),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.neonCyan.withOpacity(0.5)),
            ),
            child: Text(
              totalDistance >= FloydWarshall.inf
                  ? 'Total Distance: Unreachable'
                  : 'Total Distance: ${totalDistance.toInt()} meters',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.neonCyan),
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDropdown({required int value, required ValueChanged<int?> onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          value: value,
          dropdownColor: AppColors.cardColor,
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.neonCyan),
          items: List.generate(
            roomNames.length,
            (i) => DropdownMenuItem(value: i, child: Text(roomNames[i])),
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildMapCanvas(List<int> route) {
    return Container(
      color: AppColors.background,
      child: InteractiveViewer(
        transformationController: _transformationController,
        minScale: 0.1,
        maxScale: 4.0,
        constrained: false, // Allows panning beyond viewport if needed
        boundaryMargin: const EdgeInsets.all(100),
        child: Center(
          child: SizedBox(
            width: 850,
            height: 500,
            child: Stack(
              children: [
                // LAYER 1: SVG Map Background from assets
                SvgPicture.asset(
                  'assets/museum_map.svg',
                  width: 850,
                  height: 500,
                  fit: BoxFit.contain,
                  placeholderBuilder: (BuildContext context) => const Center(
                    child: CircularProgressIndicator(color: AppColors.neonCyan),
                  ),
                ),

                // LAYER 2: Animated Floyd-Warshall Path Overlay
                AnimatedBuilder(
                  animation: _glowController,
                  builder: (context, child) {
                    return CustomPaint(
                      size: const Size(850, 500),
                      painter: NeonBlueprintOverlayPainter(
                        roomCoords: roomCoords,
                        path: route,
                        startNode: startNode,
                        endNode: endNode,
                        pulseValue: _glowController.value,
                        distMatrix: fw.dist,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 3. STREAMLINED OVERLAY PAINTER (PATH + PINS ONLY)
// -----------------------------------------------------------------------------
class NeonBlueprintOverlayPainter extends CustomPainter {
  final List<Offset> roomCoords;
  final List<int> path;
  final int startNode;
  final int endNode;
  final double pulseValue;
  final List<List<double>> distMatrix;

  NeonBlueprintOverlayPainter({
    required this.roomCoords,
    required this.path,
    required this.startNode,
    required this.endNode,
    required this.pulseValue,
    required this.distMatrix,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw Pulsing Neon Path
    if (path.length > 1) {
      Path pathLine = Path();
      pathLine.moveTo(roomCoords[path[0]].dx, roomCoords[path[0]].dy);
      for (int i = 1; i < path.length; i++) {
        pathLine.lineTo(roomCoords[path[i]].dx, roomCoords[path[i]].dy);
      }

      // Layer 1: Outer Neon Aura (Wide Blur)
      final auraPaint = Paint()
        ..color = AppColors.neonBlue.withOpacity(0.4 + (0.2 * pulseValue))
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = 18.0 + (4.0 * pulseValue)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 12.0 + (4.0 * pulseValue));

      // Layer 2: Middle Glow Line
      final glowPaint = Paint()
        ..color = AppColors.neonCyan.withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = 8.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

      // Layer 3: Inner White Core Tube
      final corePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = 3.0;

      canvas.drawPath(pathLine, auraPaint);
      canvas.drawPath(pathLine, glowPaint);
      canvas.drawPath(pathLine, corePaint);

      // Draw Distance Labels along the path
      for (int i = 0; i < path.length - 1; i++) {
        int u = path[i];
        int v = path[i + 1];
        double distance = distMatrix[u][v];

        Offset p1 = roomCoords[u];
        Offset p2 = roomCoords[v];
        Offset mid = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);

        TextSpan span = TextSpan(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12.0,
            fontWeight: FontWeight.bold,
          ),
          text: '${distance.toInt()}m',
        );
        TextPainter tp = TextPainter(
          text: span,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        );
        tp.layout();

        Rect bgRect = Rect.fromCenter(
          center: mid,
          width: tp.width + 12,
          height: tp.height + 6,
        );
        
        Paint bgPaint = Paint()
          ..color = AppColors.cardColor
          ..style = PaintingStyle.fill;
        Paint borderPaint = Paint()
          ..color = AppColors.neonCyan
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

        canvas.drawRRect(RRect.fromRectAndRadius(bgRect, const Radius.circular(6)), bgPaint);
        canvas.drawRRect(RRect.fromRectAndRadius(bgRect, const Radius.circular(6)), borderPaint);
        
        tp.paint(canvas, mid - Offset(tp.width / 2, tp.height / 2));
      }
    }

    // Start Node Pin (Green Glow)
    final startAura = Paint()
      ..color = AppColors.startNode.withOpacity(0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
    final startPin = Paint()..color = AppColors.startNode;
    canvas.drawCircle(roomCoords[startNode], 12, startAura);
    canvas.drawCircle(roomCoords[startNode], 8, startPin);

    // End Node Pin (Red Glow)
    final endAura = Paint()
      ..color = AppColors.endNode.withOpacity(0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
    final endPin = Paint()..color = AppColors.endNode;
    canvas.drawCircle(roomCoords[endNode], 12, endAura);
    canvas.drawCircle(roomCoords[endNode], 8, endPin);
  }

  @override
  bool shouldRepaint(covariant NeonBlueprintOverlayPainter oldDelegate) {
    return oldDelegate.path != path ||
        oldDelegate.startNode != startNode ||
        oldDelegate.endNode != endNode ||
        oldDelegate.pulseValue != pulseValue;
  }
}