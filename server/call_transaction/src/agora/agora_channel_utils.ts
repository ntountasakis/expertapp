import {v4 as uuidv4} from "uuid";

/*
https://docs.agora.io/en/Voice/API%20Reference/flutter/v5.1.0/API/class_irtcengine.html#ariaid-title60
channelName
The channel name. This parameter signifies the channel in which users
engage in real-time audio and video interaction. Under the premise of the same App ID,
users who fill in the same channel ID enter the same channel for audio and video interaction.
The string length must be less than 64 bytes. Supported characters:
The 26 lowercase English letters: a to z.
The 26 uppercase English letters: A to Z.
The 10 numeric characters: 0 to 9.
Space
"!", "#", "$", "%", "&", "(", ")", "+", "-", ":", ";", "<", "=", ".", ">", "?",
"@", "[", "]", "^", "_", "{", "}", "|", "~", ","
*/

export function agoraGenerateChannelName(): string {
  return uuidv4();
}

/*
User ID This parameter is used to identify the user in the channel for real-time audio and video interaction.
You need to set and manage user IDs yourself, and ensure that each user ID in the same channel is unique.
This parameter is a 32-bit unsigned integer. The value range is 1 to 232-1.
*/

export function agoraGenerateChannelUid(): number {
  return between(1, Math.pow(2, 32));
}

/*
 Returns a random number between min (inclusive) and max (exclusive)
 */
function between(min: number, max: number): number {
  return Math.floor(
      Math.random() * (max - min) + min
  );
}
