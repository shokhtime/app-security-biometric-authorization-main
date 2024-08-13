import 'package:app_security/main.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreatePin extends StatefulWidget {
  const CreatePin({super.key});

  @override
  State<CreatePin> createState() => _CreatePinState();
}

class _CreatePinState extends State<CreatePin> {
  late final TextEditingController pinController;
  late final FocusNode focusNode;
  late final GlobalKey<FormState> formKey;

  final LocalAuthentication auth = LocalAuthentication();

  Future<void> authenticate() async {
    final bool didAuthenticate = await auth.authenticate(
      localizedReason: 'Ilovaga kirish uchun biometrik autentifikatsiya kerak',
    );

    if (didAuthenticate) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            return const MyHomePage(title: "Counter app");
          },
        ),
      );
    } else {
      Fluttertoast.showToast(
          msg: "Fail",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  bool isExists = false;

  @override
  void initState() {
    isPINExist().then(
      (value) {
        isExists = value;
      },
    );
    super.initState();
    formKey = GlobalKey<FormState>();
    pinController = TextEditingController();
    focusNode = FocusNode();
  }

  @override
  void dispose() {
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void savePIN(String pin) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (isExists) {
      if (pin == prefs.getString('pin')) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return const MyHomePage(title: "Counter app");
            },
          ),
        );
      } else {
        pinController.delete();
        return;
      }
    } else {
      await prefs.setString('pin', pin);

      Fluttertoast.showToast(
          msg: "Your PIN saved",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
      await authenticate();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return const MyHomePage(title: "Counter app");
          },
        ),
      );
    }
  }

  Future<bool> isPINExist() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('pin');
  }

  @override
  Widget build(BuildContext context) {
    const focusedBorderColor = Color.fromRGBO(23, 171, 144, 1);
    const fillColor = Color.fromRGBO(243, 246, 249, 0);
    const borderColor = Color.fromRGBO(23, 171, 144, 0.4);

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Color.fromRGBO(30, 60, 87, 1),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: borderColor),
      ),
    );

    /// Optionally you can use form to validate the Pinput
    return Scaffold(
      body: Center(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isExists ? "Create your PIN" : "Enter your PIN",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: Color.fromRGBO(23, 171, 144, 1),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Directionality(
                // Specify direction if desired
                textDirection: TextDirection.ltr,
                child: Pinput(
                  // You can pass your own SmsRetriever implementation based on any package
                  // in this example we are using the SmartAuth
                  controller: pinController,
                  focusNode: focusNode,
                  defaultPinTheme: defaultPinTheme,
                  separatorBuilder: (index) => const SizedBox(width: 8),
                  validator: (value) {
                    if (value!.trim().isNotEmpty) {
                      savePIN(value);
                    } else {
                      return "Pin is incorrect";
                    }
                    return null;
                  },
                  hapticFeedbackType: HapticFeedbackType.lightImpact,
                  onCompleted: (pin) {
                    debugPrint('onCompleted: $pin');
                  },
                  onChanged: (value) {
                    debugPrint('onChanged: $value');
                  },
                  cursor: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 9),
                        width: 22,
                        height: 1,
                        color: focusedBorderColor,
                      ),
                    ],
                  ),
                  focusedPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration!.copyWith(
                      borderRadius: BorderRadius.circular(19),
                      border: Border.all(color: focusedBorderColor, width: 3),
                    ),
                  ),
                  submittedPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration!.copyWith(
                      color: fillColor,
                      borderRadius: BorderRadius.circular(19),
                      border: Border.all(color: focusedBorderColor),
                    ),
                  ),
                  errorPinTheme: defaultPinTheme.copyBorderWith(
                    border: Border.all(color: Colors.redAccent),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: 56 * 4,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(23, 171, 144, 1),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    focusNode.unfocus();
                    formKey.currentState!.validate();
                  },
                  child: const Text('Set PIN'),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              IconButton(
                onPressed: () {
                  authenticate();
                },
                icon: const Icon(
                  Icons.fingerprint,
                  size: 50,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
