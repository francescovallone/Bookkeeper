class Subscription{
  int _id;
  double _cost;
  String _title;
  String _date;
  String _period;
  Subscription(this._cost, this._title, this._period, this._date);
  Subscription.withId(this._id, this._cost, this._title, this._period, this._date);
  int get id => _id;
  double get cost => _cost;
  String get title => _title;
  String get period => _period;
  String get date => _date;
  set cost(double m) {
		this._cost = m;
	}
  set title(String t) {
		this._title = t;
	}
  set period(String p) {
		this._period = p;
	}
  set date(String d){
    this._date = d;
  }
  Map<String, dynamic> toMap() {
		var map = Map<String, dynamic>();
		if (id != null) {
			map['id'] = _id;
		}
		map['cost'] = _cost;
		map['title'] = _title;
    map['period'] = _period;
    map['date'] = _date;
		return map;
	}
  Subscription.fromMapObject(Map<String, dynamic> map) {
		this._id = map['id'];
		this._cost = map['cost'];
		this._title = map['title'];
    this._period = map['period'];
    this._date = map['date'];
	}
}

