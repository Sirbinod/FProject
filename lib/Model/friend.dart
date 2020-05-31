class Friend {
  int _id;
  String _name;
  String _number;
  String _date;

  Friend(this._name, this._date, [this._number]);

  Friend.withId(this._id, this._name, this._date, [this._number]);

  int get id => _id;

  String get name => _name;

  String get number => _number;

  String get date => _date;

  set name(String newName) {
    if (newName.length <= 50) {
      this._name = newName;
    }
  }

  set number(String newNumber) {
    if (newNumber.length <= 100) {
      this._number = newNumber;
    }
  }

  set date(String newDate) {
    this._date = newDate;
  }

  // Convert a Note object into a Map object
  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = _id;
    }
    map['name'] = _name;
    map['number'] = _number;
    map['date'] = _date;

    return map;
  }

  // Extract a Note object from a Map object
  Friend.fromMapObject(Map<String, dynamic> map) {
    this._id = map['id'];
    this._name = map['name'];
    this._number = map['number'];
    this._date = map['date'];
  }
}
