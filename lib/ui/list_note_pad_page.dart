import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:notepadapp/common/strings.dart';
import 'package:notepadapp/models/note.dart';
import 'package:notepadapp/provider/dbprovider.dart';
import 'package:provider/provider.dart';

class NotePadScreen extends StatefulWidget {

  @override
  State<NotePadScreen> createState() => _NotePadScreenState();
}

class _NotePadScreenState extends State<NotePadScreen> {

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DBProvider(),
      child: Consumer<DBProvider>(
          builder: (context, dbProvider, child) {
            return Scaffold(
                appBar: widgetAppBar(context),
                body: FutureBuilder<List<Note>>(
                          future: dbProvider.getAllData(),
                          builder: (context, snapshot){
                            if(snapshot.hasData){
                              return widgetListNotes(context, dbProvider.list, dbProvider, titleController, descriptionController);
                            } else {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                          }
                      ),
                floatingActionButton: FloatingActionButton(
                  onPressed: () {
                      widgetDialogAdd(context, dbProvider, titleController, descriptionController);
                    },
                backgroundColor: Theme.of(context).primaryColor,
                  child: const Icon(Icons.create),
              ),
            );
          }
      ),
    );
  }
}

  widgetDialogEdit(BuildContext context, DBProvider dbProvider, TextEditingController titleController, TextEditingController descriptionController, Note note){
  return  showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'label',
      barrierColor: Colors.black54,
      transitionDuration: Duration(milliseconds: 500),
      pageBuilder: (ctx, a1, a2){
        return Dismissible(
          direction: DismissDirection.vertical,
          key: const Key('dismissible'),
          child: Material(
            child: Container(
              padding: EdgeInsets.only(top: 24),
              height: 200,
              decoration: BoxDecoration(
                color: Theme.of(context).backgroundColor.withOpacity(0.4),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.width*0.2,
                        width: MediaQuery.of(context).size.width*0.2,
                        child: GestureDetector(
                          child: Icon(Icons.arrow_back_outlined, color: Colors.black,),
                          onTap: (){
                            Navigator.of(context).pop();
                            titleController.clear();
                            descriptionController.clear();
                          },
                        ),
                      ),
                      Container(
                        child:FittedBox(
                          fit: BoxFit.scaleDown,
                          child:
                          Text(Strings.note, overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.raleway(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18,),  ),
                        ),
                      ),
                      Spacer(),
                      Container(
                        height: MediaQuery.of(context).size.width*0.2,
                        width: MediaQuery.of(context).size.width*0.2,
                        child: GestureDetector(
                          child: Icon(Icons.delete, color: Colors.black,),
                          onTap: (){
                            showAlertDialogDelete(context, dbProvider, note.number, titleController, descriptionController);
                          },
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.all(20),
                    child: TextFormField(
                      controller: titleController,
                      autofocus: true,
                      autocorrect: false,
                      keyboardType: TextInputType.text,
                      minLines: 1,
                      maxLines: 1,
                      decoration: InputDecoration(
                        disabledBorder: InputBorder.none,
                        hintStyle: GoogleFonts.raleway(color: Colors.black),
                        hintText: Strings.inputTitle,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(20),
                    child: TextFormField(
                      controller: descriptionController,
                      autofocus: true,
                      autocorrect: false,
                      keyboardType: TextInputType.multiline,
                      minLines: 1,
                      maxLines: 8,
                      decoration: InputDecoration(
                        disabledBorder: InputBorder.none,
                        hintStyle: GoogleFonts.raleway(color: Colors.black),
                        hintText: Strings.inputDescription,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(20),
                    child: ElevatedButton(
                      onPressed: ()async  {
                        await dbProvider.update(note ,titleController.text.trim(), descriptionController.text.trim()) == true ?
                        successToast(context, titleController, descriptionController) : errorToast(context);
                      },
                      child: Text(Strings.update, style: GoogleFonts.raleway(color: Colors.white, fontWeight: FontWeight.bold ),),
                      style: ElevatedButton.styleFrom(shape: StadiumBorder(), primary: Colors.black,
                          padding: EdgeInsets.only(left: 30, right: 30, top: 15, bottom: 15)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child){
        return SlideTransition(
          position: Tween(begin: Offset(0,1), end: Offset(0,0)).animate(anim1),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8*anim1.value, sigmaY: 8*anim1.value),
            child: FadeTransition(
              opacity: anim1,
              child: child,
            ),
          ),
        );
      }
  );
}

  widgetDialogAdd(BuildContext context, DBProvider dbProvider, TextEditingController titleController,
      TextEditingController descriptionController){
    return  showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: 'label',
        barrierColor: Colors.black54,
        transitionDuration: Duration(milliseconds: 500),
        pageBuilder: (ctx, a1, a2){
          return Dismissible(
            direction: DismissDirection.vertical,
            key: const Key('dismissible'),
            child: Material(
              child: Container(
                padding: EdgeInsets.only(top: 24),
                height: 200,
                decoration: BoxDecoration(
                    color: Theme.of(context).backgroundColor.withOpacity(0.4),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.width*0.2,
                          width: MediaQuery.of(context).size.width*0.2,
                          child: GestureDetector(
                            child: Icon(Icons.arrow_back_outlined, color: Colors.black,),
                            onTap: (){
                              Navigator.of(context).pop();
                              titleController.clear();
                              descriptionController.clear();
                            },
                          ),
                        ),
                        Container(
                          child:FittedBox(
                            fit: BoxFit.scaleDown,
                            child:
                            Text(Strings.newNote, overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.raleway(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18,),  ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.all(20),
                      child: TextFormField(
                        controller: titleController,
                        autofocus: true,
                        autocorrect: false,
                        keyboardType: TextInputType.text,
                        minLines: 1,
                        maxLines: 1,
                        decoration: InputDecoration(
                          disabledBorder: InputBorder.none,
                          hintStyle: GoogleFonts.raleway(color: Colors.black),
                          hintText: Strings.inputTitle,
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(20),
                      child: TextFormField(
                        controller: descriptionController,
                        autofocus: true,
                        autocorrect: false,
                        keyboardType: TextInputType.multiline,
                        minLines: 1,
                        maxLines: 8,
                        decoration: InputDecoration(
                          disabledBorder: InputBorder.none,
                          hintStyle: GoogleFonts.raleway(color: Colors.black),
                          hintText: Strings.inputDescription,
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(20),
                      child: ElevatedButton(
                        onPressed: ()async  {
                          await dbProvider.create(titleController.text.trim(), descriptionController.text.trim()) == true ?
                              successToast(context, titleController, descriptionController) : errorToast(context);
                        },
                        child: Text(Strings.save, style: GoogleFonts.raleway(color: Colors.white, fontWeight: FontWeight.bold ),),
                        style: ElevatedButton.styleFrom(shape: StadiumBorder(), primary: Colors.black,
                            padding: EdgeInsets.only(left: 30, right: 30, top: 15, bottom: 15)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        transitionBuilder: (ctx, anim1, anim2, child){
          return SlideTransition(
              position: Tween(begin: Offset(0,1), end: Offset(0,0)).animate(anim1),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8*anim1.value, sigmaY: 8*anim1.value),
                child: FadeTransition(
                  opacity: anim1,
                  child: child,
                ),
              ),
          );
        }
    );
  }

  showAlertDialogDelete(BuildContext context, DBProvider dbProvider, int i,
      TextEditingController titleController, TextEditingController descriptionController) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(Strings.deleteNote, style: GoogleFonts.raleway(color: Colors.black, fontWeight: FontWeight.w600),),
          actions: [
            TextButton(
              child: Text(Strings.no, style: GoogleFonts.raleway(color: Colors.black),),
              onPressed:  () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(Strings.yes, style: GoogleFonts.raleway(color: Colors.black),),
              onPressed:  () {
                dbProvider.delete(i);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                titleController.clear();
                descriptionController.clear();
              },
            ),
          ],
        );
      },
    );
  }

  widgetMenuEdit(BuildContext context, DBProvider dbProvider, Note note) {
    showDialog(
        context: context,
        builder: (context){
          return SimpleDialog(
            children: [
              SimpleDialogOption(
                child: Container(
                    padding: EdgeInsets.only(top: 5, bottom: 10),
                    child: Text(Strings.upTop, style: GoogleFonts.raleway(color: Colors.black, fontWeight: FontWeight.bold),)),
                onPressed: () {
                  Navigator.of(context).pop();
                  dbProvider.upTop(note);
                },
              ),
              SimpleDialogOption(
                child: Container(
                    padding: EdgeInsets.only(top: 10, bottom: 5),
                    child: Text(Strings.delete, style: GoogleFonts.raleway(color: Colors.black, fontWeight: FontWeight.bold),)),
                onPressed: () {
                  Navigator.of(context).pop();
                  dbProvider.delete(note.number);
                },
              ),
            ],
          );
        }
    );
  }

  errorToast(BuildContext context) {
    return MotionToast.error(
        title:  Text(Strings.error ,style: GoogleFonts.raleway(color: Colors.black),),
        description:  Text(Strings.errorAction, style: GoogleFonts.raleway(color: Colors.black),)
    ).show(context);
  }

  successToast(BuildContext context, TextEditingController titleController, TextEditingController descriptionController) {
    titleController.clear();
    descriptionController.clear();
    Navigator.of(context).pop();
    return MotionToast.success(
        title:  Text(Strings.success, style: GoogleFonts.raleway(color: Colors.black), ),
        description:  Text(Strings.successAction, style: GoogleFonts.raleway(color: Colors.black),),
        width:  300
    ).show(context);
  }

  widgetListNotes(BuildContext context, List<Note> items, DBProvider dbProvider,
      TextEditingController titleController, TextEditingController descriptionController){
    return Container(
      padding: EdgeInsets.all(5),
      color: Theme.of(context).primaryColor.withOpacity(0.4),
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: (){
              titleController.text=items[index].title;
              descriptionController.text=items[index].description;
              widgetDialogEdit(context, dbProvider, titleController, descriptionController, items[index]);
            },
            onLongPress: () {
              widgetMenuEdit(context, dbProvider, items[index]);
            },
            child: Container(
              margin: EdgeInsets.all(5),
              height: 100,
              alignment: Alignment.center,
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(left: 10, top: 5),
                    height: 27,
                    child: Row(
                      children: [
                        Icon(Icons.description, color: Colors.orange,),
                        Container(
                          width: MediaQuery.of(context).size.width*0.8,
                          padding: EdgeInsets.only(left: 10),
                          child: Text(items[index].title, overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.raleway(color: Colors.black, fontWeight: FontWeight.w600),),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    thickness: 2,
                    color: Theme.of(context).primaryColor.withOpacity(0.4),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 5.0, bottom: 5.0, left: 10, right: 10),
                    child: Text(items[index].description, style: GoogleFonts.raleway(color: Colors.black, fontWeight: FontWeight.w400), overflow: TextOverflow.ellipsis,),
                  ),
                  Container(
                    alignment: Alignment.bottomRight,
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: Text(items[index].data(), overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.raleway(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w400),),
                  ),
                ],
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                color: Colors.white,
              ),
            ),
          );
        },
      )
    );
  }

  widgetAppBar(BuildContext context){
    return PreferredSize(
        child: AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).primaryColor,
          title: Container(
            child: Row(
              children: [
                Container(
                  height: 50,
                  width: 50,
                  alignment: Alignment.center,
                  child: Text('Pad', style: GoogleFonts.raleway(color: Colors.white, fontWeight: FontWeight.bold, ),  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    color: Colors.black,
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 10),
                  child: Text('Notes', style: GoogleFonts.raleway(color: Colors.black, fontWeight: FontWeight.bold),),
                ),
              ],
            ),
          ),
        ),
        preferredSize: Size.fromHeight(70))
    ;
  }



