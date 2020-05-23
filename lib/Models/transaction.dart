
class Transaction{
  int _id;
  double _money;
  String _date;
  String _category;
  int _type;
  Transaction(this._money, this._date, this._category, this._type);
  Transaction.withId(this._id, this._money, this._date, this._category, this._type);
  int get id => _id;
  String get category => _category;
	String get date => _date;
	double get money => _money;
  int get type => _type;
  set money(double newmoney) {
		this._money = newmoney;
	}
  set date(String newDate) {
		this._date = newDate;
	}
  set category(String c) {
		this._category = c;
	}
  set type(int t){
    this._type = t;
  }
  Map<String, dynamic> toMap() {
		var map = Map<String, dynamic>();
		if (id != null) {
			map['id'] = _id;
		}
		map['money'] = _money;
		map['date'] = _date;
    map['category'] = _category;
    map['type'] = _type;
		return map;
	}
  Transaction.fromMapObject(Map<String, dynamic> map) {
		this._id = map['id'];
		this._money = map['money'];
		this._date = map['date'];
    this._category = map['category'];
    this._type = map['type'];
	}
}

