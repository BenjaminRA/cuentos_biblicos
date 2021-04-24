import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class ReaderPage extends StatefulWidget {
  @override
  _ReaderPageState createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  bool _hasSpeech = false;
  double level = 0.0;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  String lastWords = "";
  String lastError = "";
  String lastStatus = "";
  String _currentLocaleId = "es_CL";
  List<LocaleName> _localeNames = [];
  int minPalabras = 5;
  int currentParrafo = 0;
  int profundidadBusqueda = 3;
  List<double> minConfiabilidad = [0.9, 0.7];
  final SpeechToText speech = SpeechToText();

  String debugText = '';

  bool loading = false;
  String image = '';
  List<String> parrafos = [
    'en el principio creo dios los cielos y la tierra y la tierra estaba desordenada y vacia y las tinieblas estaban sobre la faz del abismo y el espíritu de dios se movía sobre la faz de las aguas',
    'Y dijo dios sea la luz y fue la luz y vió dios que la luz era buena y separó dios la luz de las tinieblas y llamó dios a la luz día, y a las tinieblas llamó noche y fue la tarde y la mañana un día',
    'luego dijo dios haya expansión en medio de las aguas, y separe las aguas de las aguas e hizo dios la expansión y separó las aguas que estaban debajo de la expansión de las aguas que estaban sobre la expansión y fue así y llamó dios a la expansión cielos y fue la tarde y la mañana el día segundo',
    'dijo también dios júntense las aguas que están debajo de los cielos en un lugar y descúbrase lo seco y fue así y llamó dios a lo seco Tierra y a la reunión de las aguas llamó mares y vio dios que era bueno después dijo dios produzca la tierra hierba verde hierba que dé semilla árbol de fruto que dé fruto según su género que su semilla esté en él sobre la tierra y fue así produjo pues la tierra hierba verde hierba que da semilla según su naturaleza y árbol que da fruto, cuya semilla está en él, según su género y vio dios que era bueno y fue la tarde y la mañana el día tercero',
    'dijo luego dios haya lumbreras en la expansión de los cielos para separar el día de la noche y sirvan de señales para las estaciones para días y años y sean por lumbreras en la expansión de los cielos para alumbrar sobre la tierra y fue así e hizo dios las dos grandes lumbreras la lumbrera mayor para que señorease en el día y la lumbrera menor para que señorease en la noche hizo también las estrellas y las puso dios en la expansión de los cielos para alumbrar sobre la tierra y para señorear en el día y en la noche y para separar la luz de las tinieblas y vio dios que era bueno y fue la tarde y la mañana el día cuarto',
    'dijo dios produzcan las aguas seres vivientes y aves que vuelen sobre la tierra en la abierta expansión de los cielos y creó dios los grandes monstruos marinos y todo ser viviente que se mueve que las aguas produjeron según su género y toda ave alada según su especie y vio dios que era bueno y dios los bendijo diciendo fructificad y multiplicaos y llenad las aguas en los mares y multiplíquense las aves en la tierra y fue la tarde y la mañana el día quinto',
    'luego dijo dios produzca la tierra seres vivientes según su género bestias y serpientes y animales de la tierra según su especie y fue así e hizo dios animales de la tierra según su género y ganado según su género y todo animal que se arrastra sobre la tierra según su especie y vio dios que era bueno entonces dijo dios hagamos al hombre a nuestra imagen conforme a nuestra semejanza y señoree en los peces del mar en las aves de los cielos en las bestias en toda la tierra y en todo animal que se arrastra sobre la tierra y creó dios al hombre a su imagen a imagen de dios lo creó varón y hembra los creó y los bendijo dios y les dijo fructificad y multiplicaos llenad la tierra y sojuzgadla y señoread en los peces del mar en las aves de los cielos, y en todas las bestias que se mueven sobre la tierra y dijo dios he aquí que os he dado toda planta que da semilla que está sobre toda la tierra y todo árbol en que hay fruto y que da semilla os serán para comer y a toda bestia de la tierra y a todas las aves de los cielos y a todo lo que se arrastra sobre la tierra en que hay vida toda planta verde les será para comer y fue así y vio dios todo lo que había hecho y he aquí que era bueno en gran manera y fue la tarde y la mañana el día sexto',
    'fueron pues acabados los cielos y la tierra y todo el ejército de ellos y acabó dios en el día séptimo la obra que hizo y reposó el día séptimo de toda la obra que hizo y bendijo dios al día séptimo y lo santificó porque en él reposó de toda la obra que había hecho en la creación'
  ];

  List<String> urls = [
    'https://lh3.googleusercontent.com/pw/ACtC-3dxbhZMprWMqo8pgaO5skRjufJglNGqQbMCO1xB4mlfiL3JxEDReid1g5xQogUTp6iiiIznabjOdE4sQSFa_cHPDaCdJsCiMjUp0Gqlhc9yUgJ46xWVmVuT0Ni8MjiqInhutsAY1Pfet0sR2Er3B4aM-Q=w1734-h975-no',
    'https://lh3.googleusercontent.com/pw/ACtC-3fqALbu-v6VKZ8PqyAEIXtkOaad4LLc-X98mnYQnF1Jtulvi-wgMqrzCpNb4Gya8iIDT1HxptawNswlwRxVm4vCb9veY86l-CsZ8mkYjbF90THC4wBBwp43Lx_aee6VGvFxzg0Yr6aLHGKxUYKugVWx9A=w1733-h975-no',
    'https://lh3.googleusercontent.com/pw/ACtC-3c8q2XwyvZizm9rBHzRiGVbuu5tTjFFbvtdJawp7_Z9Q4SV-agmTxxYqEuKlniBGoZBGg9b2PyTcK07HIKqv3F8Wf4BmS-YT-aWv-4VLb5t_fN1z3ASYsiFaUMxpFaJpz0bzCBZ8Pje5ZCEDRdRVIaxog=w1733-h975-no',
    'https://lh3.googleusercontent.com/pw/ACtC-3c8WFjZoPNVXX5VbtPA5prBD-TUw_hcpdQAyhQBb_NIxR867fLN0gPaJndDgv8h5cnPSttU6v7bjXtrcgJmS21uwizTYMfDBIsv0pvf6p8ygYauJjij9kSYbCGKbBMOEKa9bmoAXQ5D4GDO6t7IgSf4YQ=w1733-h975-no',
    'https://lh3.googleusercontent.com/pw/ACtC-3fQKuPDspTEYfWFeStwroqLISjC8U3Em8xDK0vQPoRmF-6KFe1P3STpNQLWOTHEhySCAIbGdFotvy7NPtZyMtU07WTKdxBkZJRe738plwO6INa7-B2YQWoSQ942m98DpO-VsM2IAcSF4NtArRXUWzlkpg=w1733-h975-no',
    'https://lh3.googleusercontent.com/pw/ACtC-3fE7cHdobxoJjwuY1Nmkw68PWDW_DdL6qVocM_qowhaPi9nhKmdDRd8FbTzFi-Vd3N1qflzEpAjXfVHfMc4hTQzhbCKqGPjHzbZmS4cNtZkP5zCPs3K4_P1opFFX1rYXDEtjOYLBPmRuVQ30JwDUxM0SQ=w1733-h975-no',
    'https://lh3.googleusercontent.com/pw/ACtC-3dM-tQI2NE7I6qYWnOMO1xDpuGX1WGt-czw1ErV3PPhJCspJFmlXuZjknMHGmO5_FrX8iubt7awUnDQBdfi_kh9i_kLzC6A3XuX3xibwULW9mSgFKGmppnNADI-C2O9I8HXixnsLQvNtwUxSU5T39AZKg=w1733-h975-no',
    'https://lh3.googleusercontent.com/pw/ACtC-3c4HYqjb51FgI480ca_Ri4lds6-IfmJs9LoqZa2iI3HVT7DVMC4Cfz5sK4MTH0A9uMTfsXN4hFstSYnukCnqgcfpto4WRyojDmpu8_SGcvkZ7Vqv14htK15yhvNmYXlWXelfINKgyCJL3hL6Yy9I8PAJw=w1733-h975-no'
  ];

  Future<void> initSpeechState() async {
    bool hasSpeech = await speech.initialize(
        onError: errorListener, onStatus: statusListener);
    if (hasSpeech) {
      _localeNames = await speech.locales();

      var systemLocale = await speech.systemLocale();
      _currentLocaleId = systemLocale.localeId;
    }

    if (!mounted) return;

    setState(() {
      _hasSpeech = hasSpeech;
    });
  }

  double busquedaPorPalabras(String text, String parrafo) {
    List<String> palabras = text.split(' ');
    int encontradas = 0;

    for (String palabra in palabras) {
      bool encontrada = parrafo.contains(palabra);
      encontradas += encontrada ? 1 : 0;
      // if (encontrada)
      //   print('palabra encontrada: $palabra - confiabilidad: ${encontradas / palabras.length}');
    }

    return encontradas / palabras.length;
  }

  Future<void> getParrafo(String text) async {
    if (text != '') {
      text = replaceAcentos(text.toLowerCase());
      print('texto: $text');

      for (int i = currentParrafo;
          i < currentParrafo + profundidadBusqueda;
          ++i) {
        if (i < parrafos.length) {
          String parrafo = replaceAcentos(parrafos[i]);
          print('busqueda de texto completo en parrafo en parrafo ${i + 1}');
          if (parrafo.contains(text)) {
            print('encontrado en parrafo ${i + 1}');
            setState(() {
              loading = false;
              image = urls[i];
              currentParrafo = i;
              debugText =
                  'encontrado en parrafo ${i + 1} con busqueda de texto completo';
            });
            return;
          }
        }
      }

      double currentConfiabilidad = 0.0;
      bool encontrado = false;
      int auxCurrentParrafo = currentParrafo;

      for (double currentMinConfiabilidad in minConfiabilidad) {
        if (encontrado) break;
        print(
            'busqueda por palabras con confiabilidad mayor a $currentMinConfiabilidad');
        for (int i = currentParrafo;
            i < currentParrafo + profundidadBusqueda && !encontrado;
            ++i) {
          if (i < parrafos.length) {
            String parrafo = replaceAcentos(parrafos[i]);
            print('busqueda por palabras en parrafo ${i + 1}');
            double confiabilidad = busquedaPorPalabras(text, parrafo);
            print('confiabilidad $confiabilidad en parrafo ${i + 1}');
            if (confiabilidad >= currentMinConfiabilidad &&
                confiabilidad > currentConfiabilidad) {
              encontrado = true;
              currentConfiabilidad = confiabilidad;
              auxCurrentParrafo = i;
              if (confiabilidad == 1.0) break;
            }
          }
        }
      }

      if (encontrado) {
        print(
            'encontrado en parrafo ${auxCurrentParrafo + 1} con busqueda por palabras');
        setState(() {
          loading = false;
          currentParrafo = auxCurrentParrafo;
          image = urls[currentParrafo];
          debugText =
              'encontrado en parrafo ${auxCurrentParrafo + 1} con busqueda por palabras: ${(currentConfiabilidad * 100).toInt()}% de confiabilidad';
        });
      }
    }
    setState(() => loading = false);
  }

  String replaceAcentos(String text) {
    String aux = text;
    aux = aux.replaceAll('á', 'a');
    aux = aux.replaceAll('é', 'e');
    aux = aux.replaceAll('í', 'i');
    aux = aux.replaceAll('ó', 'o');
    aux = aux.replaceAll('ú', 'u');
    return aux;
  }

  @override
  void initState() {
    super.initState();
    initSpeechState().then((value) => startListening());
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    super.dispose();
    disposeSettings();
  }

  void disposeSettings() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void startListening() {
    // lastWords = "";
    // lastError = "";
    speech.listen(
      onResult: resultListener,
      listenFor: Duration(seconds: 5),
      localeId: _currentLocaleId,
      onSoundLevelChange: soundLevelListener,
      cancelOnError: false,
      listenMode: ListenMode.confirmation,
    );
    setState(() {});
  }

  void pauseListening() {
    speech.cancel();
    setState(() {
      level = 0.0;
    });
  }

  void stopListening() {
    speech.stop();
    setState(() {
      level = 0.0;
    });
  }

  void cancelListening() {
    speech.cancel();
    setState(() {
      level = 0.0;
      currentParrafo = 0;
    });
    disposeSettings();
    Navigator.of(context).pop();
  }

  void resultListener(SpeechRecognitionResult result) {
    setState(() {
      lastWords = "${result.recognizedWords} - ${result.finalResult}";
    });
    if (result.finalResult) {
      Future.delayed(Duration(seconds: 1)).then((value) => startListening());
      print(
          'palabras reconocidas: ${result.recognizedWords.split(' ').length}');
      if (result.recognizedWords.split(' ').length >= minPalabras) {
        setState(() => loading = true);
        getParrafo(result.recognizedWords);
      } else {}
    }
  }

  void soundLevelListener(double level) {
    minSoundLevel = min(minSoundLevel, level);
    maxSoundLevel = max(maxSoundLevel, level);
    // print("sound level $level: $minSoundLevel - $maxSoundLevel ");
    setState(() {
      this.level = level;
    });
  }

  void errorListener(SpeechRecognitionError error) {
    // print("Received error status: $error, listening: ${speech.isListening}");
    setState(() {
      lastError = "${error.errorMsg} - ${error.permanent}";
    });
    if (error.permanent) {
      Future.delayed(Duration(seconds: 1)).then((value) => startListening());
    }
  }

  void statusListener(String status) {
    // print(
    // "Received listener status: $status, listening: ${speech.isListening}");
    setState(() {
      lastStatus = "$status";
    });
  }

  _switchLang(selectedVal) {
    print(selectedVal);
    setState(() {
      _currentLocaleId = selectedVal;
    });
    print(selectedVal);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: loading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : image == ''
                      ? Center(
                          child: Text(
                            'No se encontraron coincidencias',
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : Image.network(
                          image,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Text(stackTrace.toString());
                          },
                        ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FlatButton(
                    colorBrightness: Brightness.dark,
                    onPressed: !speech.isListening ? startListening : null,
                    child: Text('Resumir'),
                  ),
                  FlatButton(
                    colorBrightness: Brightness.dark,
                    onPressed: speech.isListening ? pauseListening : null,
                    child: Text('Pausar'),
                  ),
                  FlatButton(
                    colorBrightness: Brightness.dark,
                    onPressed: speech.isListening ? cancelListening : null,
                    child: Text('Detener'),
                  ),
                ],
              ),
            )
          ],
        )
        // ListView(
        //   children: [
        //     Container(
        //       height: 400.0,
        //       padding: EdgeInsets.all(20.0),
        //       child: loading
        //           ? Center(
        //               child: CircularProgressIndicator(),
        //             )
        //           : image == ''
        //               ? Center(
        //                   child: Text('No se encontraron coincidencias'),
        //                 )
        //               : Image.network(
        //                   image,
        //                   errorBuilder: (context, error, stackTrace) {
        //                     return Text(stackTrace.toString());
        //                   },
        //                 ),
        //     ),
        //     Row(
        //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //       children: [
        //         FlatButton(
        //           onPressed: speech.isListening ? pauseListening : null,
        //           child: Text('Pause'),
        //         ),
        //         FlatButton(
        //           onPressed: speech.isListening ? cancelListening : null,
        //           child: Text('Stop'),
        //         ),
        //       ],
        //     ),
        // Container(
        //   margin: EdgeInsets.only(top: 20.0),
        //   alignment: Alignment.center,
        //   child: Text(
        //     lastWords,
        //     textScaleFactor: 1.5,
        //     textAlign: TextAlign.center,
        //   ),
        // ),
        // Container(
        //   margin: EdgeInsets.only(top: 20.0),
        //   alignment: Alignment.center,
        //   child: Text(
        //     debugText,
        //     textScaleFactor: 1.5,
        //     textAlign: TextAlign.center,
        //     style: TextStyle(color: Colors.red),
        //   ),
        // )
        // ],
        // ),
        );
  }
}
