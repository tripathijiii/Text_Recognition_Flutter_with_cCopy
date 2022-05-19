
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class OCR extends StatefulWidget {
  const OCR({ Key? key }) : super(key: key);

  @override
  State<OCR> createState() => _OCRState();
}
class _OCRState extends State<OCR> {
  bool whichone = false;
  XFile? imagefile;
  Uint8List _webimage = Uint8List(10);
  bool textscanning = false;
  String scannedtext = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Text Recognition"),),
      body: ListView(
        shrinkWrap: true,
        children: [Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if(textscanning) CircularProgressIndicator(),
      
            if (!textscanning && imagefile == null)
            Container(
              alignment: Alignment.center,
              height: 400,
              width: MediaQuery.of(context).size.width-60,
              color: Colors.grey.shade300,
            ),
            if(imagefile!=null)
            Image.file(File(imagefile!.path)),
            SizedBox(height: 40,),
            Row(mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(onPressed: (){
                  get_image(false);
                }, icon: Icon(Icons.photo), label: Text("pick an image")),
                SizedBox(width: 40,),
                ElevatedButton.icon(onPressed: (){
                  get_image(true);
                }, icon: Icon(Icons.camera), label: Text("take an image")),
              ],
            ),
            SizedBox(height: 30,),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    child: Text(scannedtext),
                  ),
                  if(scannedtext!="")
                  ElevatedButton.icon(onPressed: (){
                    Clipboard.setData(ClipboardData(text: scannedtext));
                  }, icon: Icon(Icons.copy), label: Text("COPY"))
                ],
              ),
            )
          ],
        )],
      ),
    );
  }
  void get_image(bool is_camera) async{
    try{
      final pickedimage;
      if(is_camera){
        pickedimage = await ImagePicker().pickImage(source: ImageSource.camera);
      }else{
        pickedimage = await ImagePicker().pickImage(source: ImageSource.gallery);
      }
      if( pickedimage !=null){
        whichone=true;
        textscanning = true;
        imagefile = pickedimage;
        setState(() {  });
        getRecognisedText(pickedimage);

      }
    }catch(e){
      textscanning=false;
      imagefile=null;
      scannedtext="error occured";
    }
  }
  void getRecognisedText(XFile imagefile) async{
    final input_image = InputImage.fromFilePath(imagefile.path);
    final textdetector = TextRecognizer();
    RecognizedText recognizedText = await textdetector.processImage(input_image);
    await textdetector.close();
    scannedtext="";
    for(TextBlock block in recognizedText.blocks){
      for(TextLine lines in block.lines){
        scannedtext = scannedtext + lines.text + "\n";  
      }
    }
    textscanning=false;
    setState(() {});
  }
}