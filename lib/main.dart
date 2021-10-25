import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

// Uncomment lines 7 and 10 to view the visual layout at runtime.
// import 'package:flutter/rendering.dart' show debugPaintSizeEnabled;

Future<String> getFilePath() async {
  Directory appDocumentsDirectory = await getApplicationDocumentsDirectory(); // 1
  String appDocumentsPath = appDocumentsDirectory.path; // 2
  String filePath = '$appDocumentsPath/TextFile.txt'; // 3


  return filePath;
}


void main() {
  // debugPaintSizeEnabled = true;
  runApp(
    MaterialApp(
      home: MyApp()
    ),
  );
}

class MyApp extends StatefulWidget {

  @override
  _MyAppState createState() => _MyAppState();

}

class _MyAppState extends State<MyApp> {

  List<MyCard> cardList =[];

  @override
  Widget build(BuildContext context) {
    readFile();
    Color color = Theme.of(context).primaryColor;

    Widget navigationSection = Container(
      height: (MediaQuery.of(context).size.height-MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom -kToolbarHeight )* 1/12,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            //onTap: (){},
            child: _buildButtonColumn(color, Icons.list, 'List')
          ),
          GestureDetector(
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddCard()),
              ).then((value) {
                readFile();
              });
            },
            child: _buildButtonColumn(color, Icons.add_box, 'AddCard'),
          ),
        ],
      ),
    );

    Widget mainSection = Container(
      height: (MediaQuery.of(context).size.height-MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom -kToolbarHeight) * 11/12,
      padding: const EdgeInsets.all(32),
      child: this.cardList.isEmpty ? Center(child: Text('Empty')) : ListView.builder(
        itemCount: cardList.length,
        itemBuilder: (context, index){
          return cardList[index];
        }),
      );


    return MaterialApp(
      title: 'FlashCards',
      home: Scaffold(
        appBar: AppBar(
          title: Text('FlashCards'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            mainSection,
            navigationSection,
          ],
        ),
      ),
    );
  }

  Column _buildButtonColumn(Color color, IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color),
        Container(
          margin: const EdgeInsets.only(top: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  void readFile() async {
    File file = File(await getFilePath()); // 1
    List <String> fileContent = await file.readAsLines(); // 2
    setState(() {
      cardList.clear();
    });
    if(fileContent.isNotEmpty){
      fileContent.forEach((element) {
        List<String> tmp = element.split('@');
        MyCard tmpCard = new MyCard(question: tmp[0], answer: tmp[1]);
        setState(() {cardList.add(tmpCard);});
      });
    }

  }
}


class MyCard extends StatefulWidget {
  MyCard({@required this.question, @required this.answer });
  final question;
  final answer;

  @override
  _MyCardState createState() => _MyCardState();
}

class _MyCardState extends State<MyCard> {
  bool clicked = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          Text(widget.question),
          FlatButton(
            onPressed: () {
              setState((){clicked = !clicked;});
            },
            child: clicked?Text(widget.answer) : Text(
              "Reveal answer",
            ),
          )
        ],
      ),
    );
  }
}

class AddCard extends StatefulWidget{
  @override
  _AddCardState createState() => _AddCardState();
}

class _AddCardState extends State<AddCard> {
  var question;
  var answer;
  //final fieldText = TextEditingController();

  @override
  Widget build(BuildContext context) {


    Color color = Theme.of(context).primaryColor;

    Widget navigationSection = Container(
      height: (MediaQuery.of(context).size.height-MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom -kToolbarHeight )* 1/12,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: (){
              Navigator.pop(context);
            },
              child: _buildButtonColumn(color, Icons.list, 'List')
          ),
          GestureDetector(
            //onTap: (){},
            child: _buildButtonColumn(color, Icons.add_box, 'AddCard'),
          ),
        ],
      ),
    );

    Widget mainSection = Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          TextField(
            //controller: fieldText,
            onChanged: (text) {
              setState(() {
                this.question = text;
              });
            },

            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Question'),
          ),
          TextField(
            onChanged: (text) {
              setState(() {
                this.answer = text;
              });
            },
            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Answer'),

          ),
          OutlineButton(
            onPressed: (){
              getFilePath();
              saveFile(question, answer);

              Widget okButton = FlatButton(
                child: Text("Ok"),
                onPressed:  () {Navigator.of(context).pop();},
              );

              AlertDialog alert = AlertDialog(
                title: Text("Notice"),
                content: Text("Added FlashCard"),
                actions: [okButton],
              );

              // show the dialog
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return alert;
                },
              );

            },
            child: Text('Save')
          ),

          OutlineButton(
              onPressed: (){
                getFilePath();
                clearFile();

                Widget okButton = FlatButton(
                  child: Text("Ok"),
                  onPressed:  () {Navigator.of(context).pop();},
                );

                AlertDialog alert = AlertDialog(
                  title: Text("Notice"),
                  content: Text("Cleared Flashcards"),
                  actions: [okButton],
                );

                // show the dialog
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return alert;
                  },
                );

              },
              child: Text('Clear')
          )

        ],
      )

    );

    return MaterialApp(
      title: 'AddCard',
      home: Scaffold(
        appBar: AppBar(
          title: Text('AddCard'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            mainSection,
            navigationSection,
          ],
        ),
      ),
    );
  }

  Column _buildButtonColumn(Color color, IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color),
        Container(
          margin: const EdgeInsets.only(top: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: color,
            ),
          ),
        ),
      ],
    );
  }



  void saveFile(arg1, arg2) async {
    File file = File(await getFilePath());
    file.writeAsString(arg1 +"@"+ arg2 + "\n", mode: FileMode.append );
  }

  void clearFile() async {
    File file = File(await getFilePath());
    file.writeAsString("", mode: FileMode.write );
  }


}

