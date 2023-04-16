import 'package:cv/cv.dart';
import '../model/model_constant.dart';

abstract class DbRecord extends CvModelBase {
  final id = CvField<int>(columnId);
}
