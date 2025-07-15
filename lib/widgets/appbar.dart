import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:youtube/widgets/Custome_text.dart';

class AppbarWidget extends StatelessWidget {
  const AppbarWidget(
      {super.key,
      required this.controller,
      required this.ffocusNode,
      this.ontap,
      this.onsubmitted, required this.suffix});

  final TextEditingController controller;
  final FocusNode ffocusNode;
  final void Function()? ontap;
  final void Function(String)? onsubmitted;
  final Widget suffix;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          FontAwesomeIcons.youtube,
          color: Colors.red,
        ),
        const Gap(15),
        const CustomeText(title: 'Youtube'),
        const Gap(15),
        Expanded(
          child: TextField(
            onTap: ontap,
            style: const TextStyle(color: Colors.black54, fontSize: 20),
            onSubmitted: onsubmitted,
            focusNode: ffocusNode,
            controller: controller,
            decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 1,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  size: 22,
                  color: Colors.black38,
                ),
                suffixIcon: suffix,
                hintStyle: const TextStyle(color: Colors.black45, fontSize: 17),
                border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12))),
                fillColor: Colors.white,
                filled: true,
                hintText: 'Search'),
          ),
        )
      ],
    );
  }
}
