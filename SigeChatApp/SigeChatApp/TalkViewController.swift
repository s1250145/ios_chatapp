//
//  TalkViewController.swift
//  SigeChatApp
//
//  Created by 山口瑞歩 on 2019/11/13.
//  Copyright © 2019 山口瑞歩. All rights reserved.
//

import UIKit
import MessageKit
import MessageInputBar
import SwiftyJSON
import Alamofire

struct Message: MessageType {
    var messageId: String
    var sender: Sender
    var sentDate: Date
    var kind: MessageKind

    private init(kind: MessageKind, sender: Sender, messageId: String, date: Date) {
        self.messageId = messageId
        self.sender = sender
        self.sentDate = date
        self.kind = kind
    }

    init(text: String, sender: Sender, messageId: String, date: Date) {
        self.init(kind: .text(text), sender: sender, messageId: messageId, date: date)
    }
}

class TalkViewController: MessagesViewController, MessageInputBarDelegate {
    var messageList: [Message] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "しげぽん"

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messageInputBar.delegate = self

        // 自分にはアイコンを表示しないための設定
        let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout
        layout?.setMessageOutgoingAvatarSize(.zero)
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        layout?.setMessageOutgoingMessageTopLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: insets))
        layout?.setMessageOutgoingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: insets))
        layout?.textMessageSizeCalculator.messageLabelFont = UIFont.init(name: "AppleSDGothicNeo-Light", size: 20)!
    }

    // 送信ボタン押下時
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        let message = Message(text: text, sender: currentSender(), messageId: UUID().uuidString, date: Date())
        insertMessage(message)
        sendMessageToBot(text)
        inputBar.inputTextView.text = String() // 入力欄をクリア
        messagesCollectionView.scrollToBottom(animated: true)
    }

    func sendMessageToBot(_ msg: String) {
        let url = "https://chat-bot-259102.appspot.com/talk?msg=\(msg)"
        let encodedURL = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        Alamofire.request(encodedURL!, method: .get, encoding: JSONEncoding.default).responseString {
            response in
            switch response.result {
            case .success:
                let message = Message(text: response.result.value!, sender: self.senderBot(), messageId: UUID().uuidString, date: Date())
                self.insertMessage(message)
                self.messagesCollectionView.scrollToBottom(animated: true)
            case .failure(let err):
                print(err)
            }
        }
    }

    func insertMessage(_ message: Message) {
        messageList.append(message)
        messagesCollectionView.reloadData()
    }
}

// Messageの設定
extension TalkViewController: MessagesDataSource, MessagesDisplayDelegate, MessagesLayoutDelegate, MessageLabelDelegate {
    // MessageDataSource

    func currentSender() -> Sender {
        return Sender(id: "1", displayName: "Me")
    }

    func senderBot() -> Sender {
        return Sender(id: "2", displayName: "しげぽん")
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }

    // MessagesDisplayDelegate

    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        // Color of bubble
        let receive = UIColor(displayP3Red: 176/255, green: 196/255, blue: 222/255, alpha: 1)
        let me = UIColor(displayP3Red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
        return isFromCurrentSender(message: message) ? me : receive
    }

    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        // Location of bubble
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }

    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return .black
    }

    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let bot = Avatar(image: UIImage.init(named: "Avatar"), initials: message.sender.displayName)
        avatarView.set(avatar: bot)
    }

    // MessageLabelDelegate
    
    func didSelectAddress(_ addressComponents: [String: String]) {
        print("Address Selected: \(addressComponents)")
    }

    func didSelectPhoneNumber(_ phoneNumber: String) {
        print("Phone Number Selected: \(phoneNumber)")
    }

    func didSelectURL(_ url: URL) {
        print("URL Selected: \(url)")
    }
}
