import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_downloader/pages/dataShow_page.dart';
import 'package:youtube_downloader/widget/const.dart';

class InputlinkPage extends StatelessWidget {
  const InputlinkPage({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController linkController = TextEditingController();

    return Scaffold(
      backgroundColor: bgColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                height: MediaQuery.sizeOf(context).height * 0.06,
                width: double.maxFinite,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                child: TextField(
                  style: GoogleFonts.roboto(
                      fontSize: MediaQuery.sizeOf(context).height * 0.02,
                      fontWeight: FontWeight.bold),
                  controller: linkController,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      hintText: 'Link',
                      hintStyle: GoogleFonts.roboto(
                          fontSize: MediaQuery.sizeOf(context).height * 0.02,
                          fontWeight: FontWeight.bold)),
                )),
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.02,
            ),
            //button
            GestureDetector(
              onTap: () {
                String link = linkController.text;

                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => DatashowPage(
                              link: link,
                            )));
              },
              child: Container(
                height: MediaQuery.sizeOf(context).height * 0.06,
                width: double.maxFinite,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                child: Center(
                  child: Text(
                    'Proceed',
                    style: GoogleFonts.roboto(
                        fontSize: MediaQuery.sizeOf(context).height * 0.025,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
