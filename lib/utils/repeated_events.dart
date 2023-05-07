import '../model/model.dart';

class EventUtils {
  static List<DbEvent> repeatedEvents = [];
  static void generateRepeatedEvents(List<DbEvent?> events) {
    // Clear the list before generating new events
    repeatedEvents.clear();

    // Iterate through each event and repeat it for the next 10 years
    for (var event in events) {
      // Get the special day for the current event
      var specialDay =
          DateTime.parse(event?.specialday.v ?? '1970-01-01');

      // Iterate through the next 10 years and repeat the event
      for (int i = 0; i < 10; i++) {
        // Add the repeated event to the list
        repeatedEvents.add(DbEvent()
          ..id.v = int.parse('${event?.id.v}$i')
          ..title.v = event?.title.v
          ..specialday.v =
              DateTime(specialDay.year + i, specialDay.month, specialDay.day)
                  .toString()
          ..ideas.v = event?.ideas.v);
      }
    }

    // Sort the list of repeated events by the special day
    repeatedEvents.sort(
        (a, b) => DateTime.parse(a.specialday.v!)
            .compareTo(DateTime.parse(b.specialday.v!)));
  }
}
