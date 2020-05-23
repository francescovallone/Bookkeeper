class Goal{
  int _id;
  double _moneyNeeded;
  String _title;
  String _description;
  int _idTransaction;
  int _status;
  Goal(this._moneyNeeded, this._title, this._description, this._status, this._idTransaction);
  Goal.withId(this._id, this._moneyNeeded, this._title, this._description, this._status, this._idTransaction);
  int get id => _id;
  double get moneyNeeded => _moneyNeeded;
  String get title => _title;
  String get desc => _description;
  int get idT => _idTransaction;
  int get status => _status;
  set moneyNeeded(double m) {
		this._moneyNeeded = m;
	}
  set title(String t) {
		this._title = t;
	}
  set desc(String d){
    this._description = d;
  }
  set idT(int i) {
		this._idTransaction = i;
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
    map['description'] = _description;
    map['id_transactions'] = _idTransaction;
    map['status'] = _status;
		return map;
	}
  Goal.fromMapObject(Map<String, dynamic> map) {
		this._id = map['id'];
		this._moneyNeeded = map['money_needed'];
		this._title = map['title'];
    this._description = map['description'];
    this._idTransaction = map['id_transactions'];
    this._status = map['status'];
	}
}

