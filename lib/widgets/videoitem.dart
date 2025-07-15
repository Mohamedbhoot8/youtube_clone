import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:youtube/widgets/Custome_text.dart';

class Videoitem extends StatelessWidget {
  const Videoitem(
      {super.key,
      required this.title,
      required this.chanelName,
      required this.views,
      required this.timing,
      required this.thimpenintal,
      required this.chanelimage,
      required this.publishedTime});

  final String title;
  final String chanelName;
  final String views;
  final String timing;
  final String thimpenintal;
  final String chanelimage;
  final String publishedTime;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Column(
      children: [
        Stack(
          children: [
            Image.network(
                width: double.infinity, fit: BoxFit.cover, thimpenintal),
            Positioned(
                bottom: 5,
                right: 10,
                child: Container(
                  color: Colors.black45,
                  padding: const EdgeInsets.all(5),
                  child: CustomeText(
                    title: timing,
                    weight: FontWeight.bold,
                    size: 13,
                  ),
                ))
          ],
        ),
        const Gap(15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              CircleAvatar(
                  radius: 20, backgroundImage: NetworkImage(chanelimage)),
              const Gap(15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: size.width * 0.8,
                    child: AutoSizeText(
                      title,
                      maxLines: 1,
                      minFontSize: 15,
                      maxFontSize: double.infinity,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white70),
                    ),
                  ),
                  SizedBox(
                    width: size.width * 0.8,
                    child: AutoSizeText(
                      '$chanelName   $views  $publishedTime',
                      maxLines: 1,
                      minFontSize: 15,
                      overflow: TextOverflow.ellipsis,
                      maxFontSize: double.infinity,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white30),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        const Gap(30)
      ],
    );
  }
}
