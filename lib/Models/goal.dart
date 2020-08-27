class Goal{
  int _id;
  double _moneyNeeded;
  String _title;
  String _date;
  int _status;
  Goal(this._moneyNeeded, this._title, this._date, this._status);
  Goal.withId(this._id, this._moneyNeeded, this._title, this._date, this._status);
  int get id => _id;
  double get moneyNeeded => _moneyNeeded;
  String get title => _title;
  String get desc => _date;
  int get status => _status;
  set moneyNeeded(double m) {
		this._moneyNeeded = m;
	}
  set title(String t) {
		this._title = t;
	}
  set date(String d){
    this._date = d;
  }
  set status(int s){
    this._status = s;
  }
  Map<String, dynamic> toMap() {
		var map = Map<String, dynamic>();
		if (id != null) {
			map['id'] = _id;
		}
		map['money_needed'] = _moneyNeeded;
		map['title'] = _title;
    map['date'] = _date;
    map['status'] = _status;
		return map;
	}
  Goal.fromMapObject(Map<String, dynamic> map) {
		this._id = map['id'];
		this._moneyNeeded = map['money_needed'];
		this._title = map['title'];
    this._date = map['date'];
    this._status = map['status'];
	}
}

