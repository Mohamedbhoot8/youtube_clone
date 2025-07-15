import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:youtube/constans.dart';
import 'package:youtube/widgets/Custome_text.dart';
import 'package:youtube/widgets/videoitem.dart';

class VideoDitals extends StatefulWidget {
  const VideoDitals({super.key, required this.id});

  final String id;

  @override
  State<VideoDitals> createState() => _VideoDitalsState();
}

class _VideoDitalsState extends State<VideoDitals> {
  VideoPlayerController? _controller;
  bool isLoading = true;
  bool isdisc = false;
  bool iscomment = false;
  bool iscomment1 = false;
  Map<String, dynamic>? videosinfo;
  List videos = [];

  List relatedvideos = [];
  List commentlist = [];

  @override
  void initState() {
    super.initState();
    getvideo();
    getRelatedvideo();
    getcomments();
  }

  Future<void> getRelatedvideo() async {
    try {
      final uri =
          '${AppConstans.baseurl}/v2/video/related?videoId=${widget.id}';
      final url = Uri.parse(uri);
      final response = await http.get(url, headers: AppConstans.headers);

      if (response.statusCode != 200) {
        throw Exception('فشل في تحميل الفيديوهات المرتبطة');
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;

      if (json.containsKey('items') &&
          json['items'] is List &&
          json['items'].isNotEmpty) {
        final result = json['items'] as List;

        setState(() {
          relatedvideos = result;
        });
      } else {
        setState(() {
          relatedvideos = [];
        });
      }
    } catch (e) {
      debugPrint('خطأ أثناء جلب الفيديوهات المرتبطة: $e');
      setState(() {
        relatedvideos = [];
      });
    }
  }

  Future<void> getvideo() async {
    final uri =
        '${AppConstans.baseurl}/v2/video/details?videoId=${widget.id}&urlAccess=normal&videos=auto&audios=auto';
    final url = Uri.parse(uri);

    final response = await http.get(url, headers: AppConstans.headers);
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    // ignore: non_constant_identifier_names
    final VideoList = json['videos']['items'];
    if (VideoList == null || VideoList.isEmpty || VideoList[0]['url'] == null) {
      throw Exception('Invalid video link');
    }
    final videolink = VideoList[0]['url'];

    videos = VideoList;

    _controller = VideoPlayerController.networkUrl(Uri.parse(videolink));
    await _controller!.initialize();
    _controller!.play();

    setState(() {
      videosinfo = json;
      isLoading = false;
    });
  }

  Future<void> getcomments() async {
    final uri =
        '${AppConstans.baseurl}/v2/video/comments?videoId=${widget.id}&sortBy=top';
    final url = Uri.parse(uri);
    final response = await http.get(url, headers: AppConstans.headers);
    final json = jsonDecode(response.body) as Map;
    final result = json['items'];
    setState(() {
      commentlist = result;
    });
  }

  List<TextSpan> _formatDescription(String text) {
    final words = text.split(' ');

    return words.map((word) {
      final isLink = word.startsWith('http') ||
          word.startsWith('https') ||
          word.startsWith('www.');

      final isHashtag = word.startsWith('#');

      final bool highlight = isLink || isHashtag;

      return TextSpan(
        text: '$word ',
        style: TextStyle(
          color: highlight ? Colors.blue : Colors.white60,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      );
    }).toList();
  }

  void togglevideo() {
    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
      }
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isVideoReady =
        _controller != null && _controller!.value.isInitialized;
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          toolbarHeight: 0,
        ),
        body: isLoading || !isVideoReady
            ? const Center(
                child: CupertinoActivityIndicator(),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ///video
                  GestureDetector(
                    onTap: togglevideo,
                    child: Stack(
                      children: [
                        AspectRatio(
                            aspectRatio: _controller!.value.aspectRatio,
                            child: VideoPlayer(_controller!)),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: SizedBox(
                                width: 50,
                                height: 50,
                                child: Icon(Icons.arrow_back_ios)),
                          ),
                        )
                      ],
                    ),
                  ),
                  // about
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Gap(8),
                        AutoSizeText(
                          videosinfo!['title'],
                          maxLines: 2,
                          minFontSize: 17,
                          overflow: TextOverflow.ellipsis,
                          maxFontSize: double.infinity,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const Gap(5),
                        GestureDetector(
                            onTap: () {
                              setState(() {
                                isdisc = !isdisc;
                              });
                            },
                            child: RichText(
                              maxLines: isdisc ? 10 : 2,
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                children: _formatDescription(
                                    videosinfo!['description'] ?? ''),
                              ),
                            )),
                        const Gap(15),
                        AutoSizeText(
                          '  ${videosinfo!['viewCount']} views             ${videosinfo!['publishedTimeText']}',
                          maxLines: 1,
                          minFontSize: 8,
                          overflow: TextOverflow.ellipsis,
                          maxFontSize: double.infinity,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white38),
                        ),
                        const Gap(15),
                        Row(
                          children: [
                            CircleAvatar(
                                radius: 17,
                                backgroundImage: NetworkImage(
                                    videosinfo!['channel']['avatar'][0]
                                        ['url'])),
                            const Gap(5),
                            Text(
                              videosinfo!['channel']['name'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70),
                            ),
                            const Gap(10),
                            Text(
                              videosinfo!['channel']['subscriberCountText'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white30),
                            ),
                            const Spacer(),
                            Expanded(
                              child: Container(
                                height: 20,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15)),
                                child: const Center(
                                  child: Text(
                                    'Subscribe',
                                    style: TextStyle(
                                        fontSize: 7.5,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),

                  // comment

                  GestureDetector(
                    onTap: () {
                      setState(() {
                        iscomment = !iscomment;
                      });
                    },
                    child: AnimatedContainer(
                        duration: const Duration(seconds: 1),
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        padding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[900]),
                        child: Row(
                          children: [
                            CustomeText(
                                title:
                                    'Comments ${videosinfo!['commentCountText'] ?? ''}'),
                            const Spacer(),
                            Icon(
                              iscomment
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                            ),
                          ],
                        )),
                  ),

                  Visibility(
                    visible: iscomment,
                    child: SizedBox(
                        height: isdisc ? 100 : 200,
                        child: ListView.builder(
                          itemCount: commentlist.length,
                          itemBuilder: (context, index) {
                            final comment = commentlist[index];
                            return GestureDetector(
                              onTap: () => setState(() {
                                iscomment1 = !iscomment1;
                              }),
                              child: ListTile(
                                trailing: const Icon(Icons.more_vert_sharp),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AutoSizeText(comment['channel']['name']),
                                    AutoSizeText(
                                      minFontSize: 15,
                                      maxLines: iscomment1 ? 15 : 1,
                                      overflow: TextOverflow.ellipsis,
                                      comment['contentText'],
                                      style:
                                          const TextStyle(color: Colors.grey),
                                    )
                                  ],
                                ),
                                leading: CircleAvatar(
                                  radius: 20,
                                  backgroundImage: NetworkImage(
                                      comment['channel']['avatar'][0]['url']),
                                ),
                              ),
                            );
                          },
                        )),
                  )

                  // relatedvideo
                  ,
                  const Gap(10),
                  Expanded(
                      child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: relatedvideos.length,
                    itemBuilder: (context, index) {
                      final item = relatedvideos[index];
                      final channel = item['channel'];
                      final thumbnails = item['thumbnails'];
                      final avatar = channel?['avatar'];
                      return Videoitem(
                          title: item['title'] ?? '',
                          chanelName: channel?['name'] ?? '',
                          views: item['viewCountText'] ?? '',
                          timing: item['lengthTex'] ?? '',
                          thimpenintal:
                              (thumbnails != null && thumbnails.isNotEmpty)
                                  ? thumbnails[1]['url']
                                  : 'https://via.placeholder.com/150',
                          chanelimage: (avatar != null && avatar.isNotEmpty)
                              ? avatar[0]['url']
                              : 'https://via.placeholder.com/50',
                          publishedTime: item['publishedTimeText'] ?? '');
                    },
                  ))
                ],
              ));
  }
}
