import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class ProfileWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final int link;
  const ProfileWidget({
    Key key,
    this.icon,
    this.title,
    this.link,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      //highlightColor: Colors.deepPurple.withOpacity(0.4),
      //splashColor: Colors.purple.withOpacity(0.5),
      onTap: () {
        EasyLoading.showInfo("Belum tersedia.");
      },
      child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    color: Colors.black.withOpacity(.5),
                    size: 24,
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.5),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.black.withOpacity(.4),
                size: 16,
              )
            ],
          )),
    );
  }
}
