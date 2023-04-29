const String tableNameday = 'nameday';

const String colId = '_id';
const String colName = 'name';
const String colDate = 'date';

class Nameday {
  int? id;
  String? name;
  String? date;

  Nameday({this.id, this.name, this.date});

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map[colName] = name;
    map[colDate] = date;
    if (id != null) {
      map[colId] = id;
    }
    return map;
  }

 Nameday.fromMap(Map<String, dynamic> map) {
  id = map[colId] as int?;
  name = map[colName] as String?;
  date = map[colDate] as String?;
}
}
