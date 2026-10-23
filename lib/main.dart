import 'package:video_player/'
'video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart'; // Lo usaremos para lanzar los enlaces

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> channels = [];
  String? currentPlaying;
  VideoPlayerController? _controller;


  @override
  void initState() {
    super.initState();
    _loadChannels();
  }

  Future<void> _loadChannels() async {
  try {
    final content = await rootBundle.loadString('assets/nuevalista.m3u');
    final lines = content.split('\n');
    List<String> loadedChannels = [];

    for (var line in lines) {
      line = line.trim();
      if (line.isNotEmpty && line.startsWith('http')) {
        loadedChannels.add(line);
      }
    }

    setState(() {
      channels = loadedChannels;
    });
  } catch (e) {
    debugPrint('Error al cargar canales: $e');
  }
}

      
      

    Future<void> _playChannel(String url) async {
    setState(() {
      currentPlaying = url;
    });

    await _controller?.dispose();

    _controller = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((_) {
        setState(() {});
        _controller!.play();
      }).catchError((error) {
        debugPrint("Error al inicializar el vídeo: $error");
      });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi App TV - AceStream'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
    if (_controller != null && _controller!.value.isInitialized) ...[
      Container(
        height: 220,
        color: Colors.black,
        child: AspectRatio(
          aspectRatio: _controller!.value.aspectRatio,
          child: VideoPlayer(_controller!),
        ),
      ),
    
            
    ],

          if (currentPlaying != null)
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.teal.shade900,
              child: Row(
                children: [
                  const Icon(Icons.tv, color: Colors.tealAccent),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Reproduciendo: $currentPlaying',
                      style: const TextStyle(color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: channels.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: channels.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: InkWell(
                          onTap: () => _playChannel(channels[index]),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white10),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[900],
                            ),
                            child: Row(
                              children: [
                                Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    channels[index], 
                                    style: const TextStyle(fontSize: 16),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(Icons.play_arrow, color: Colors.tealAccent),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
