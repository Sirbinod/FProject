/// An SMS library for flutter
library sms;

import 'dart:async';

import 'package:flutter/services.dart';
import './contact.dart';

enum SmsMessageKind {
  Sent,
  Received,
  Draft,
}

/// A SMS Message
class SmsMessage implements Comparable<SmsMessage> {
  int _id;
  int _threadId;
  String _address;
  String _body;
  bool _read;
  DateTime _date;
  DateTime _dateSent;
  SmsMessageKind _kind;

  SmsMessage(this._address, this._body,
      {int id, int threadId, bool read, DateTime date, DateTime dateSent}) {
    this._id = id;
    this._threadId = threadId;
    this._read = read;
    this._date = date;
    this._dateSent = dateSent;
  }

  /// Read message fron JSON
  ///
  /// Format:
  ///
  /// ```json
  /// {
  ///   "address": "phone-number-here",
  ///   "body": "text message here"
  /// }
  /// ```
  SmsMessage.fromJson(Map data) {
    this._address = data["address"];
    this._body = data["body"];
    if (data.containsKey("_id")) {
      this._id = data["_id"];
    }
    if (data.containsKey("thread_id")) {
      this._threadId = data["thread_id"];
    }
    if (data.containsKey("read")) {
      this._read = data["read"] as int == 1;
    }
    if (data.containsKey("date")) {
      this._date = new DateTime.fromMillisecondsSinceEpoch(data["date"]);
    }
    if (data.containsKey("date_sent")) {
      this._dateSent =
          new DateTime.fromMillisecondsSinceEpoch(data["date_sent"]);
    }
  }

  /// Convert SMS to map
  Map get toMap {
    Map res = {};
    if (_address != null) {
      res["address"] = _address;
    }
    if (_body != null) {
      res["body"] = _body;
    }
    if (_id != null) {
      res["_id"] = _id;
    }
    if (_threadId != null) {
      res["thread_id"] = _threadId;
    }
    if (_read != null) {
      res["read"] = _read;
    }
    if (_date != null) {
      res["date"] = _date.millisecondsSinceEpoch;
    }
    if (_dateSent != null) {
      res["date_sent"] = _dateSent.millisecondsSinceEpoch;
    }
    return res;
  }

  /// Get message id
  int get id => this._id;

  /// Get thread id
  int get threadId => this._threadId;

  /// Get sender, alias phone number
  String get sender => this._address;

  /// Get address, alias phone number
  String get address => this._address;

  /// Get message body
  String get body => this._body;

  /// Check if message is read
  bool get isRead => this._read;

  /// Get date sent
  DateTime get dateSent => this._dateSent;

  /// Get date
  DateTime get date => this._date;

  /// Get message kind
  SmsMessageKind get kind => this._kind;

  /// Set message kind
  set kind(SmsMessageKind kind) => this._kind = kind;

  /// Set message date
  set date(DateTime date) => this._date = date;

  @override
  int compareTo(SmsMessage other) {
    return other._id - this._id;
  }
}

/// A SMS thread
class SmsThread {
  int _id;
  String _address;
  Contact _contact;
  List<SmsMessage> _messages = [];

  SmsThread(int id) : this._id = id;

  /// Create a thread from a list of message, the id will be taken from
  /// the first message
  SmsThread.fromMessages(List<SmsMessage> messages) {
    if (messages == null || messages.length == 0) {
      return;
    }
    this._id = messages[0].threadId;
    this._address = messages[0].address;
    for (var msg in messages) {
      if (msg.threadId == _id) {
        this._messages.add(msg);
      }
    }
    this.findContact();
  }

  /// Add a message at the end
  void addMessage(SmsMessage msg) {
    if (msg.threadId == _id) {
      _messages.add(msg);
      if (this._address == null) {
        this._address = msg.address;
      }
    }
  }

  /// Add a message at the start
  void addNewMessage(SmsMessage msg) {
    if (msg.threadId == _id) {
      _messages.insert(0, msg);
      if (this._address == null) {
        this._address = msg.address;
      }
    }
  }

  /// Set contact through contact query
  void findContact() async {
    ContactQuery query = new ContactQuery();
    Contact contact = await query.queryContact(this._address,
        onError: (Object e) => print(e.toString()));
    if (contact != null) {
      this._contact = contact;
    }
  }

  /// Get messages from thread
  List<SmsMessage> get messages => this._messages;

  /// Get address
  String get address => this._address;

  /// Set messages in thread
  set messages(List<SmsMessage> messages) => this._messages = messages;

  /// Get thread id
  int get id => this._id;

  /// Get thread id (for compatibility)
  int get threadId => this._id;

  /// Get contact info
  Contact get contact => this._contact;

  /// Set contact info
  set contact(Contact contact) => this._contact = contact;
}

/// A SMS receiver that creates a stream of SMS
///
///
/// Usage:
///
/// ```dart
/// var receiver = SmsReceiver();
/// receiver.onSmsReceived.listen((SmsMessage msg) => ...);
/// ```
class SmsReceiver {
  static SmsReceiver _instance;
  final EventChannel _channel;
  Stream<SmsMessage> _onSmsReceived;

  factory SmsReceiver() {
    if (_instance == null) {
      final EventChannel eventChannel = const EventChannel(
          "plugins.babariviere.com/recvSMS", const JSONMethodCodec());
      _instance = new SmsReceiver._private(eventChannel);
    }
    return _instance;
  }

  SmsReceiver._private(this._channel);

  /// Create a stream that collect received SMS
  Stream<SmsMessage> get onSmsReceived {
    if (_onSmsReceived == null) {
      print("Creating sms receiver");
      _onSmsReceived = _channel.receiveBroadcastStream().map((dynamic event) {
        SmsMessage msg = new SmsMessage.fromJson(event);
        msg.kind = SmsMessageKind.Received;
        return msg;
      });
    }
    return _onSmsReceived;
  }
}

/// Called when SMS is sent (don't check if it's delivered
typedef void SmsHandlerSucc();

/// Called when sending SMS failed
typedef void SmsHandlerFail(Object e);

/// A SMS sender
class SmsSender {
  static SmsSender _instance;
  final MethodChannel _channel;

  factory SmsSender() {
    if (_instance == null) {
      final MethodChannel methodChannel = const MethodChannel(
          "plugins.babariviere.com/sendSMS", const JSONMethodCodec());
      _instance = new SmsSender._private(methodChannel);
    }
    return _instance;
  }

  SmsSender._private(this._channel);

  /// Send an SMS
  ///
  /// Take a message in argument + 2 functions that will be called on success or on error
  ///
  /// This function will not set automatically thread id, you have to do it
  Future<Null> sendSms(SmsMessage msg,
      {SmsHandlerSucc onSuccess, SmsHandlerFail onError}) async {
    if (msg == null || msg.address == null || msg.body == null) {
      if (onError != null) {
        if (msg == null) {
          onError("no given message");
        } else if (msg.address == null) {
          onError("no given address");
        } else if (msg.body == null) {
          onError("no given body");
        }
      }
      return;
    }
    await _channel.invokeMethod("sendSMS", msg.toMap).then((dynamic val) {
      msg.date = new DateTime.now();
      if (onSuccess != null) {
        onSuccess();
      }
    }, onError: (dynamic e) {
      if (onError != null) {
        onError(e);
      }
    });
  }
}

enum SmsQueryKind { Inbox, Sent, Draft }

/// A SMS query
class SmsQuery {
  static SmsQuery _instance;
  final MethodChannel _channel;

  factory SmsQuery() {
    if (_instance == null) {
      final MethodChannel methodChannel = const MethodChannel(
          "plugins.babariviere.com/querySMS", const JSONMethodCodec());
      _instance = new SmsQuery._private(methodChannel);
    }
    return _instance;
  }

  SmsQuery._private(this._channel);

  /// Wrapper for query only one kind
  Future<List<SmsMessage>> _querySmsWrapper(
      {int start,
      int count,
      int threadId,
      SmsQueryKind kind: SmsQueryKind.Inbox,
      SmsHandlerFail onError}) async {
    Map arguments = {};
    if (start != null && start >= 0) {
      arguments["start"] = start;
    }
    if (count != null && count > 0) {
      arguments["count"] = count;
    }
    if (threadId != null && threadId >= 0) {
      arguments["thread_id"] = threadId;
    }
    String function;
    SmsMessageKind msgKind;
    if (kind == SmsQueryKind.Inbox) {
      function = "getInbox";
      msgKind = SmsMessageKind.Received;
    } else if (kind == SmsQueryKind.Sent) {
      function = "getSent";
      msgKind = SmsMessageKind.Sent;
    } else {
      function = "getDraft";
      msgKind = SmsMessageKind.Draft;
    }
    return await _channel.invokeMethod(function, arguments).then((dynamic val) {
      List<SmsMessage> list = [];
      for (Map data in val) {
        SmsMessage msg = new SmsMessage.fromJson(data);
        msg.kind = msgKind;
        list.add(msg);
      }
      return list;
    }, onError: (Object e) {
      if (onError != null) {
        onError(e);
      }
    });
  }

  /// Query a list of SMS
  Future<List<SmsMessage>> querySms(
      {int start,
      int count,
      int threadId,
      List<SmsQueryKind> kinds: const [SmsQueryKind.Inbox],
      SmsHandlerFail onError,
      bool sort: true}) async {
    List<SmsMessage> result = [];
    for (var kind in kinds) {
      result
        ..addAll(await this._querySmsWrapper(
            start: start,
            count: count,
            threadId: threadId,
            kind: kind,
            onError: onError));
    }
    if (sort == true) {
      result.sort((a, b) => a.compareTo(b));
    }
    return (result);
  }

  /// Query multiple thread by id
  Future<Map<int, SmsThread>> queryThreads(List<int> threadsId,
      {List<SmsQueryKind> kinds: const [SmsQueryKind.Inbox],
      SmsHandlerFail onError}) async {
    Map<int, SmsThread> map = {};
    for (var id in threadsId) {
      map[id] = new SmsThread(id);
      map[id].messages =
          await this.querySms(threadId: id, kinds: kinds, onError: onError);
    }
    return map;
  }

  /// Get all SMS
  Future<List<SmsMessage>> get getAllSms async {
    return this.querySms(
        kinds: [SmsQueryKind.Sent, SmsQueryKind.Inbox, SmsQueryKind.Draft]);
  }

  /// Get all threads
  Future<Map<int, SmsThread>> get getAllThreads async {
    List<SmsMessage> messages = await this.getAllSms;
    Map<int, List<SmsMessage>> filtered = {};
    messages.forEach((msg) {
      if (!filtered.containsKey(msg.threadId)) {
        filtered[msg.threadId] = [];
      }
      filtered[msg.threadId].add(msg);
    });
    Map<int, SmsThread> map = {};
    for (var k in filtered.keys) {
      map[k] = new SmsThread.fromMessages(filtered[k]);
    }
    return map;
  }
}
