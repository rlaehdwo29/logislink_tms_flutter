import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechController extends GetxController {
  var isListening = false.obs; // 음성 인식 활성화 상태
  var speechText = "0200".obs; // 음성 인식 결과 텍스트 // code: 0200 "듣고있어요.." | 0300 "다시 말씀해주세요.."
  var currentLocaleId = "ko_KR".obs; // 현재 Locale ID
  final SpeechToText speech = SpeechToText();

  void toggleListening() {
    isListening.value = !isListening.value;
  }

  Future<void> initSpeech() async {
    isListening.value = false;
    speechText.value = "0200";    // code: 0200 "듣고있어요.." | 0300 "다시 말씀해주세요.."
    var available = await speech.initialize(
      onStatus: (status) {
        print("Speech status: $status");
        if (status == "notListening") {
          isListening.value = false;
          speechText.value = "0300"; // code: 0200 "듣고있어요.." | 0300 "다시 말씀해주세요.."
        }
      },
      onError: (error) {
        print("Speech error: $error");
        isListening.value = false;
        speechText.value = "0300"; // code: 0200 "듣고있어요.." | 0300 "다시 말씀해주세요.."
      },
    );
    if (available) {
      isListening.value = true;
      speech.listen(
          listenFor: const Duration(seconds: 100),
          pauseFor: const Duration(seconds: 5),  // 5초 동안 음성 입력 없으면 종료
          partialResults: false,
          cancelOnError: false,
          onResult: (result) {
            speechText.value = result.recognizedWords;
            isListening.value = false;
            speech.stop();
            //Navigator.of(context).pop({"returnValue" : true});
          });
    }
  }

  Future<void> startListening() async {
    if (!isListening.value) {
      var available = await speech.initialize(
        onStatus: (status) {
          print("Speech status: $status");
          if (status == "notListening") {
            isListening.value = false;
            speechText.value = "0300"; // code: 0200 "듣고있어요.." | 0300 "다시 말씀해주세요.."
          }
        },
        onError: (error) {
          print("Speech error: $error");
          isListening.value = false;
          speechText.value = "0300"; // code: 0200 "듣고있어요.." | 0300 "다시 말씀해주세요.."
        },
      );
      if (available) {
        isListening.value = true;
        speechText.value = "0200"; // code: 0200 "듣고있어요.." | 0300 "다시 말씀해주세요.."
        speech.listen(
            listenFor: const Duration(seconds: 100), // 최대 10초 동안 음성 인식 수행
            pauseFor: const Duration(seconds: 5),  // 5초 동안 음성 입력 없으면 종료
            partialResults: false,
            cancelOnError: false,
            onResult: (result) {
                speechText.value = result.recognizedWords;
                isListening.value = false;
                speech.stop();
                //Navigator.of(context).pop({"returnValue" : true});
              });
      }
    } else {
      isListening.value = false;
      speech.stop();
    }


  }
}