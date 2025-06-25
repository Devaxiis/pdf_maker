import 'package:flutter/material.dart';

class GithubPage extends StatefulWidget {
  const GithubPage({super.key});

  @override
  State<GithubPage> createState() => _GithubPageState();
}

class _GithubPageState extends State<GithubPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hello"),
      ),
   body: ListView(
     children:[
       Row(
       children: [
         Text("Salom")
       ],
     ),
   ],
   
   )
    );
  }
}
