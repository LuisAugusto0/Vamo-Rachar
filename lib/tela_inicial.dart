import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vamo Rachar',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF64C27B),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: const IconButton(
                icon: Icon(Icons.account_circle_outlined,
                color: Colors.green, size: 50,),
                onPressed: null,
          ),
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(width: 150, height: 150, child: FittedBox(
                child:FloatingActionButton.large(
                  backgroundColor: Colors.white,
                  onPressed: null,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("assets/images/img.png", width:50,height: 50,),
                      const Text(
                        "Nova Divisão",
                        style: TextStyle(color: Colors.black),)
                    ],
                  ),
                ),
              ),
              // const FloatingActionButton.large(
              //   backgroundColor: Colors.white,
              //   onPressed: null,
              //   child: Column(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [
              //       Icon(Icons.alarm, color: Colors.greenAccent,),
              //       Text(
              //         "Histórico",
              //         style: TextStyle(color: Colors.black),)
              //     ],
              //   ),
              // ),
              ),
              SizedBox(width: 150, height: 150, child: FittedBox(
                child:FloatingActionButton.large(
                  backgroundColor: Colors.white,
                  onPressed: null,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.alarm, color: Colors.green,),
                      const Text(
                        "Histórico",
                        style: TextStyle(color: Colors.black),)
                    ],
                  ),
                ),
              ),
                // const FloatingActionButton.large(
                //   backgroundColor: Colors.white,
                //   onPressed: null,
                //   child: Column(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     children: [
                //       Icon(Icons.alarm, color: Colors.greenAccent,),
                //       Text(
                //         "Histórico",
                //         style: TextStyle(color: Colors.black),)
                //     ],
                //   ),
                // ),
              )],
          ),
        ],
      )
    );
  }
}
