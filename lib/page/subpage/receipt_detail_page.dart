import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:logislink_tms_flutter/common/config_url.dart';
import 'package:logislink_tms_flutter/common/model/receipt_model.dart';
import 'package:logislink_tms_flutter/common/style_theme.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReceiptDetailPage extends StatefulWidget{
  ReceiptModel item;

  ReceiptDetailPage({Key? key, required this.item}):super(key: key);

  _ReceiptDetailPageState createState() => _ReceiptDetailPageState();
}

class _ReceiptDetailPageState extends State<ReceiptDetailPage>{

  @override
  Widget build(BuildContext context) {
    var filePath = "$SERVER_URL$RECEIPT_PATH${widget.item.fileName}";
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
              centerTitle: true,
              title: Text(
                  "${widget.item.regdate}",
                  style: CustomStyle.appBarTitleFont(styleFontSize18,styleWhiteCol)
              ),
              toolbarHeight: 50.h,
              leading: IconButton(
                onPressed: (){
                  Navigator.of(context).pop();
                },
                color: styleWhiteCol,
                icon: Icon(Icons.arrow_back,size: 24.h, color: Colors.white),
              ),
            ),
    body: SafeArea(
      child: Container(
        alignment: Alignment.center,
          child: PhotoView(
        imageProvider: NetworkImage(
            filePath
        ),
        minScale: PhotoViewComputedScale.contained * 0.8,
        maxScale: PhotoViewComputedScale.covered * 2,
        enableRotation: true,
        tightMode: true,
      )
      )
    ),
    );
  }

}