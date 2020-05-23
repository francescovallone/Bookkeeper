class BuyEntry{
  int _id;
  double _cost;
  String _title;
  String _link;
  BuyEntry(this._cost, this._title, this._link);
  BuyEntry.withId(this._id, this._cost, this._title, this._link);
  int get id => _id;
  double get cost => _cost;
  String get title => _title;
  String get link => _link;
  set cost(double m) {
		this._cost = m;
	}
  set title(String t) {
		this._title = t;
	}
  set link(String d){
    this._link = d;
  }
  Map<String, dynamic> toMap() {
		var map = Map<String, dynamic>();
		if (id != null) {
			map['id'] = _id;
		}
		map['cost'] = _cost;
		map['title'] = _title;
    map['link'] = _link;
		return map;
	}
  BuyEntry.fromMapObject(Map<String, dynamic> map) {
		this._id = map['id'];
		this._cost = map['cost'];
		this._title = map['title'];
    this._link = map['link'];
	}
}

