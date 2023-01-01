import 'package:agora_rtc_engine/rtc_engine.dart';

class RtcEngineWrapper {
  late RtcEngine engine;
  bool isTorndown = false;

  void setEngine(RtcEngine engine) {
    this.engine = engine;
  }

  Future<void> teardown() async {
    if (!isTorndown) {
      await engine.leaveChannel();
      await engine.destroy();
      isTorndown = true;
    }
  }
}
