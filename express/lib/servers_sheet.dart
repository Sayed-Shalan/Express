import 'package:express/main.dart';
import 'package:express/validation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ServersSheet extends StatefulWidget {
  final Server? init;
  final String? customText;

  const ServersSheet({
    Key? key,
    this.init,
    this.customText
  }) : super(key: key);

  @override
  State<ServersSheet> createState() => _ServersSheetState();
}

class _ServersSheetState extends State<ServersSheet> {
  Server? selected;
  String? customText;

  @override
  void initState() {
    selected = widget.init;
    customText = widget.customText;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Wrap(
          children: [
            Container(
              padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(15), topLeft: Radius.circular(15)),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'اختر السيرفر - Select server',
                        style: TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Column(
                        children: List.generate(
                            Server.values.length,
                            (index) => Column(
                                  children: [
                                    InkWell(
                                      onTap: (){
                                        setState(() {
                                          selected = Server.values[index];
                                        });
                                      },
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: Text(
                                                Server.values[index].title,
                                            style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.normal),
                                          )),
                                          if(Server.values[index] == selected)
                                            const Icon(Icons.check_circle, color: Color(0xff327dbe),)
                                        ],
                                      ),
                                    ),
                                    if (index != (Server.values.length - 1))
                                      Container(
                                        height: 1,
                                        margin: const EdgeInsets.symmetric(vertical: 10),
                                        width: MediaQuery.of(context).size.width,
                                        color: const Color(0xffEAEAEA),
                                      ),
                                  ],
                                )),
                      ),

                      if(selected == Server.custom)
                        Container(
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.symmetric(vertical: 12),
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Row(
                            children: [
                              Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.grey
                                ),
                                child: const Text('https://', style: TextStyle(color: Colors.black45, fontSize: 14, fontWeight: FontWeight.bold),),
                              ),
                              Expanded(
                                child: TextFormField(
                                  style: const TextStyle(color: Colors.black, fontSize: 14),
                                  initialValue: customText,
                                  onChanged: (value)=> customText = value,
                                  decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                                    fillColor: Colors.white,
                                    hintText: 'www.google.com',
                                    isDense: true,
                                    focusedBorder: InputBorder.none,
                                    border:  InputBorder.none,
                                    disabledBorder:  InputBorder.none,
                                    enabledBorder:  InputBorder.none,
                                    focusedErrorBorder:  InputBorder.none,

                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16,),
                      ElevatedButton(
                        onPressed: (){
                          if(selected == Server.custom){
                            bool isValid = ValidationUtil.validateWebsite('https://'+ (customText ?? ''));
                            if(!isValid){
                              Fluttertoast.showToast(
                                msg: 'الرابط غير صحيح',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.black,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                              return;
                            }
                          }
                          Navigator.of(context).pop({'server': selected, 'customText': 'https://'+(customText ?? '')});

                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            const Color(0xff327dbe),
                          ),
                          shadowColor: MaterialStateProperty.all(
                            const Color(0xff327dbe),
                          ),
                          foregroundColor: MaterialStateProperty.all(
                            const Color(0xff327dbe),
                          ),
                          elevation: MaterialStateProperty.all(4),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: Color(0xff327dbe), width: 1)),
                          ),
                          fixedSize: MaterialStateProperty.all<Size?>(Size(MediaQuery.of(context).size.width, 50))),
                        child:
                            const Text(
                              'تأكيد',
                              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                              maxLines: 1,
                            ),
                      ),
                      const SizedBox(height: 16,)
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
