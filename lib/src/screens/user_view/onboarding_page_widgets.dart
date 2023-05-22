import 'package:flutter/material.dart';

Widget buildOnboardingValuePropPage() {
  return _pageHelper(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 30),
        _buildAppTitle(),
        SizedBox(height: 100),
        SizedBox(
          height: 150,
          child: _buildIconImage('icon_android.png'),
        ),
        SizedBox(height: 20),
        _textHelper(
            "Video call 1:1 with knowledgeable experts to get your questions answered"),
      ],
    ),
  );
}

Widget buildOnboardingExpertChoicePage() {
  return _pageHelper(
    Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 30),
        _buildAppTitle(),
        SizedBox(height: 50),
        _textHelper(
            "Choose your expert by viewing their category of expertise, reviews, and cost"),
        SizedBox(height: 20),
        SizedBox(
          height: 450,
          child: _buildImage('expert-listings.png'),
        ),
        SizedBox(height: 20),
      ],
    ),
  );
}

Widget buildOnboardingVideoCallPage() {
  return _pageHelper(
    Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 30),
        _buildAppTitle(),
        SizedBox(height: 50),
        _textHelper(
            "Have a conversation with a real person without needing to schedule ahead"),
        SizedBox(height: 20),
        SizedBox(
          height: 450,
          child: _buildImage('video-call.png'),
        ),
        SizedBox(height: 20),
      ],
    ),
  );
}

Widget buildOnboardingChatPage() {
  return _pageHelper(
    Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 30),
        _buildAppTitle(),
        SizedBox(height: 50),
        _textHelper(
            "Exchange messages between the expert that you can review later"),
        SizedBox(height: 20),
        SizedBox(
          height: 450,
          child: _buildImage('chat-messages.png'),
        ),
        SizedBox(height: 20),
      ],
    ),
  );
}

Widget buildExpertSignupPage() {
  return _pageHelper(
    Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 30),
        _buildAppTitle(),
        SizedBox(height: 50),
        _textHelper(
            "If you have a skill we can verify, sign up in the app to become one of our experts and earn money quickly"),
        SizedBox(height: 20),
        SizedBox(
          height: 450,
          child: _buildImage('join-us.jpg'),
        ),
        SizedBox(height: 20),
      ],
    ),
  );
}

Widget _buildIconImage(String assetName) {
  return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(
        'assets/images/$assetName',
        fit: BoxFit.fill,
      ));
}

Widget _buildImage(String assetName) {
  return Image.asset(
    'assets/images/$assetName',
    fit: BoxFit.fill,
  );
}

Widget _buildAppTitle() {
  const titleStyle = TextStyle(
      fontSize: 28.0,
      fontWeight: FontWeight.w700,
      fontFamily: 'Roboto',
      color: Colors.blue);
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Spacer(),
      Text(
        "Expert App",
        style: titleStyle,
      ),
      Spacer(),
    ],
  );
}

Widget _pageHelper(Widget body) {
  return Scaffold(
    backgroundColor: Colors.grey[100],
    body: SafeArea(
      child: body,
    ),
  );
}

Widget _textHelper(String text) {
  const bodyStyle = TextStyle(
      fontSize: 24.0, fontWeight: FontWeight.w600, fontFamily: 'Roboto');
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Text(
      text,
      style: bodyStyle,
    ),
  );
}
