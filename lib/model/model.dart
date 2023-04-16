import 'package:cv/cv.dart';

import '../db/db.dart';
import '../model/model_constant.dart';

class DbNote extends DbRecord {
  final title = CvField<String>(columnTitle);
  final content = CvField<String>(columnContent);
  final date = CvField<int>(columnUpdated);
  final specialday = CvField<int>(columnDate);
  final type = CvField<String>(columnType);

  @override
  List<CvField> get fields => [id, title, content, date, specialday, type];
}
