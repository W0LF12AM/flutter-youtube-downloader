import 'dart:io';  
import 'package:dio/dio.dart';  
import 'package:flutter/material.dart';  
import 'package:google_fonts/google_fonts.dart';  
import 'package:path_provider/path_provider.dart';  
import 'package:video_player/video_player.dart';  
import 'package:youtube_downloader/widget/const.dart';  
import 'package:youtube_explode_dart/youtube_explode_dart.dart';  
  
class DatashowPage extends StatefulWidget {  
  const DatashowPage({super.key, required this.link});  
  
  final String link;  
  
  @override  
  State<DatashowPage> createState() => _DatashowPageState();  
}  
  
class _DatashowPageState extends State<DatashowPage> {  
  late Future<Map<String, dynamic>> _videoDataFuture;  
  String videoTitle = '';  
  String? videoUrl;  
  String? audioUrl;  
  
  @override  
  void initState() {  
    super.initState();  
    _videoDataFuture = ytDownloadFunc(widget.link);  
  }  
  
  Future<Map<String, dynamic>> ytDownloadFunc(String link) async {  
    final yt = YoutubeExplode();  
    Map<String, dynamic> videoData = {};  
  
    try {  
      final video = await yt.videos.get(link);  
      videoData['title'] = video.title;  
  
      final manifest = await yt.videos.streams.getManifest(link);  
      final videoStream = manifest.videoOnly.isNotEmpty ? manifest.videoOnly.first : null;  
      final audioStream = manifest.audioOnly.isNotEmpty ? manifest.audioOnly.first : null;  
  
      if (videoStream != null) {  
        videoUrl = videoStream.url.toString(); // Konversi Uri ke String  
        VideoPlayerController controller = VideoPlayerController.network(videoUrl!);  
        await controller.initialize();  
        videoData['controller'] = controller; // Simpan controller  
      } else {  
        videoData['controller'] = null; // Tidak ada stream video  
      }  
  
      if (audioStream != null) {  
        audioUrl = audioStream.url.toString(); // Konversi Uri ke String  
      }  
  
    } catch (e) {  
      print('Error: $e');  
    } finally {  
      yt.close();  
    }  
    return videoData; // Kembalikan data video  
  }  
  
  Future<void> downloadAudio(String url, String title) async {  
    await _downloadFile(url, title, 'audio');  
  }  
  
  Future<void> downloadVideo(String url, String title) async {  
    await _downloadFile(url, title, 'video');  
  }  
  
  Future<void> _downloadFile(String url, String title, String type) async {  
    Directory appDocDir = await getApplicationDocumentsDirectory();  
    String filePath = '${appDocDir.path}/$title.${type == 'audio' ? 'mp3' : 'mp4'}';  
  
    Dio dio = Dio();  
  
    // Tampilkan dialog untuk progres  
    showDialog(  
      context: context,  
      barrierDismissible: false,  
      builder: (context) {  
        return AlertDialog(  
          title: Text('Downloading ${type == 'audio' ? 'Audio' : 'Video'}'),  
          content: Column(  
            mainAxisSize: MainAxisSize.min,  
            children: [  
              LinearProgressIndicator(),  
              SizedBox(height: 10),  
              Text('Downloading...'),  
            ],  
          ),  
        );  
      },  
    );  
  
    try {  
      await dio.download(url, filePath, onReceiveProgress: (received, total) {  
        // Update progres di dialog  
        if (total != -1) {  
          double progress = received / total;  
          // Update dialog  
          Navigator.of(context).pop(); // Tutup dialog sebelumnya  
          showDialog(  
            context: context,  
            barrierDismissible: false,  
            builder: (context) {  
              return AlertDialog(  
                title: Text('Downloading ${type == 'audio' ? 'Audio' : 'Video'}'),  
                content: Column(  
                  mainAxisSize: MainAxisSize.min,  
                  children: [  
                    LinearProgressIndicator(value: progress),  
                    SizedBox(height: 10),  
                    Text('${(progress * 100).toStringAsFixed(0)}%'),  
                  ],  
                ),  
              );  
            },  
          );  
        }  
      });  
  
      // Tutup dialog setelah selesai  
      Navigator.of(context).pop(); // Tutup dialog  
      ScaffoldMessenger.of(context).showSnackBar(  
          SnackBar(content: Text('${type == 'audio' ? 'Audio' : 'Video'} downloaded to $filePath')));  
    } catch (e) {  
      print('Download error: $e');  
      Navigator.of(context).pop(); // Tutup dialog  
      ScaffoldMessenger.of(context)  
          .showSnackBar(SnackBar(content: Text('Failed to download ${type == 'audio' ? 'audio' : 'video'}')));  
    }  
  }  
  
  @override  
  void dispose() {  
    _videoDataFuture.then((data) {  
      if (data['controller'] != null) {  
        data['controller'].dispose();  
      }  
    });  
    super.dispose();  
  }  
  
  @override  
  Widget build(BuildContext context) {  
    return Scaffold(  
      backgroundColor: bgColor,  
      body: Padding(  
        padding: const EdgeInsets.symmetric(horizontal: 16),  
        child: FutureBuilder<Map<String, dynamic>>(  
            future: _videoDataFuture,  
            builder: (context, snapshot) {  
              if (snapshot.connectionState == ConnectionState.waiting) {  
                return Center(  
                  child: CircularProgressIndicator(),  
                );  
              } else if (snapshot.hasError) {  
                return Center(  
                  child: Text('Error: ${snapshot.error}'),  
                );  
              } else if (snapshot.hasData) {  
                final videoData = snapshot.data!;  
                final VideoPlayerController? controller = videoData['controller'];  
                final String videoTitle = videoData['title'];  
  
                return Column(  
                  mainAxisAlignment: MainAxisAlignment.center,  
                  crossAxisAlignment: CrossAxisAlignment.start,  
                  children: [  
                    Container(  
                        height: MediaQuery.sizeOf(context).height * 0.06,  
                        width: double.maxFinite,  
                        decoration: BoxDecoration(  
                            color: Colors.white,  
                            borderRadius: BorderRadius.circular(10)),  
                        child: Center(  
                          child: Padding(  
                            padding: const EdgeInsets.symmetric(horizontal: 16),  
                            child: Text(  
                              widget.link,  
                              overflow: TextOverflow.ellipsis,  
                              style: GoogleFonts.roboto(  
                                  fontSize:  
                                      MediaQuery.sizeOf(context).height * 0.02,  
                                  fontWeight: FontWeight.bold),  
                            ),  
                          ),  
                        )),  
                    SizedBox(height: 20),  
                    Text(  
                      videoTitle.isNotEmpty ? videoTitle : 'There is no video',  
                      style: GoogleFonts.roboto(  
                          color: Colors.white,  
                          fontSize: MediaQuery.sizeOf(context).height * 0.02,  
                          fontWeight: FontWeight.bold),  
                    ),  
                    SizedBox(height: 20),  
                    Container(  
                        width: double.maxFinite,  
                        height: MediaQuery.sizeOf(context).height * 0.2,  
                        decoration: BoxDecoration(  
                            color: Colors.white,  
                            borderRadius: BorderRadius.circular(10)),  
                        child: controller != null  
                            ? VideoPlayer(controller)  
                            : Center(child: Text('Video stream not available'))),  
                    SizedBox(height: 20),  
                    GestureDetector(  
                      onTap: () {  
                        if (videoUrl != null) {  
                          downloadVideo(videoUrl!, videoTitle);  
                        } else {  
                          ScaffoldMessenger.of(context).showSnackBar(  
                              SnackBar(content: Text('Video URL not available')));  
                        }  
                      },  
                      child: Container(  
                        height: MediaQuery.sizeOf(context).height * 0.06,  
                        width: double.maxFinite,  
                        decoration: BoxDecoration(  
                            color: Colors.white,  
                            borderRadius: BorderRadius.circular(10)),  
                        child: Center(  
                          child: Text(  
                            'Download Video',  
                            style: GoogleFonts.roboto(  
                                fontSize:  
                                    MediaQuery.sizeOf(context).height * 0.025,  
                                fontWeight: FontWeight.bold),  
                          ),  
                        ),  
                      ),  
                    ),  
                    SizedBox(height: 10),  
                    GestureDetector(  
                      onTap: () {  
                        if (audioUrl != null) {  
                          downloadAudio(audioUrl!, videoTitle);  
                        } else {  
                          ScaffoldMessenger.of(context).showSnackBar(  
                              SnackBar(content: Text('Audio URL not available')));  
                        }  
                      },  
                      child: Container(  
                        height: MediaQuery.sizeOf(context).height * 0.06,  
                        width: double.maxFinite,  
                        decoration: BoxDecoration(  
                            color: Colors.white,  
                            borderRadius: BorderRadius.circular(10)),  
                        child: Center(  
                          child: Text(  
                            'Download Audio',  
                            style: GoogleFonts.roboto(  
                                fontSize:  
                                    MediaQuery.sizeOf(context).height * 0.025,  
                                fontWeight: FontWeight.bold),  
                          ),  
                        ),  
                      ),  
                    ),  
                  ],  
                );  
              } else {  
                return Center(  
                  child: Text('No data available'),  
                );  
              }  
            }),  
      ),  
    );  
  }  
}  
