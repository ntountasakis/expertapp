export interface ChatMessage {
    authorUid: string;
    chatText: string;
    millisecondsSinceEpochUtc: number;
    recipientUid: string;
}