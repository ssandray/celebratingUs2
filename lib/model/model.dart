import 'package:cv/cv.dart';

import '../db/db.dart';
import '../model/model_constant.dart';

class DbEvent extends DbRecord {
  final firstName = CvField<String>(columnFirstName);
  final lastName = CvField<String>(columnLastName);
  final ideas = CvField<String>(columnIdeas);
  final updated = CvField<int>(columnUpdated); //date
  final evdate = CvField<String>(columnDate); //specialday
  final type = CvField<String>(columnType);
  

  @override
  List<CvField> get fields => [id, firstName, lastName, ideas, updated, evdate, type];
}
