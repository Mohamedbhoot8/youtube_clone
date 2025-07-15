import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:youtube/constans.dart';
import 'package:youtube/pages/Video_ditals.dart';

import 'package:youtube/widgets/appbar.dart';
import 'package:youtube/widgets/videoitem.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController controller = TextEditingController();
  FocusNode focusNodee = FocusNode();
  List items = [];
  bool isClear = false;
  bool isloading = false;
Future<void> searchVideoss(String text) async {
  final uri =
      '${AppConstans.baseurl}/v2/search/videos?keyword=$text&uploadDate=all&duration=all&sortBy=relevance';
  final url = Uri.parse(uri);

  try {
    final response = await http.get(url, headers: AppConstans.headers);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;

      final items = json['items'];
      if (items != null && items is List) {
        setState(() {
          this.items = items;
        });
      } else {
        print("❗️ No results found");
        setState(() {
          this.items = [];
        });
      }
    } else {
      print("❌ Server error: ${response.statusCode}");
    }
  } catch (e) {
    print("❌ Exception during search: $e");
    setState(() {
      items = [];
    });
  }
}

   /*Future<void> searchVideos(String text) async {
    final uri =
        '${AppConstans.baseurl}/v2/search/videos?keyword=$text&uploadDate=all&duration=all&sortBy=relevance';
    final url = Uri.parse(uri);
    final response = await http.get(url, headers: AppConstans.headers);

    final json = jsonDecode(response.body) as Map;
    final result = json['items'] as List;
    setState(() {
      items = result;
    });
  }
*/
  @override
  void initState() {
    searchVideoss('amrdiap');
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    focusNodee.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        setState(() {
          isClear = false;
        });
      },
      child: Scaffold(
        appBar: AppBar(
            title: AppbarWidget(
          suffix: isClear
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      controller.clear();
                    });
                  },
                  child: const Icon(
                    Icons.cancel,
                    color: Colors.blue,
                  ),
                )
              : const SizedBox.shrink(),
          controller: controller,
          ffocusNode: focusNodee,
          ontap: () {
            setState(() {
              isClear = true;
            });
          },
          // ignore: non_constant_identifier_names
          onsubmitted: (Value) {
            setState(() {
              searchVideoss(Value);
            });
          },
        )),
        body: ListView.builder(
            padding: const EdgeInsets.only(top: 10),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final id = item['id'];
              return GestureDetector(
                onTap: () async {
                  setState(() {
                    isloading = true;
                  });

                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (contex) => VideoDitals(id: id)));

                  setState(() {
                    isloading = false;
                  });
                },
                child: Videoitem(
                  publishedTime: item['publishedTimeText'] ?? '',
                  chanelimage: item['channel']['avatar'][0]['url'],
                  chanelName: item['channel']['name'],
                  title: item['title'],
                  timing: item['lengthText'] ?? '',
                  views: item['viewCountText'],
                  thimpenintal: item['thumbnails'][0]['url'],
                ),
              );
            }),
      ),
    );
  }
}
