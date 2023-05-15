import '../model/model.dart';

//THIS IS USED IN LIST, MAYBE IN CALENDAR TOO?

class EventUtils {
  static List<DbEvent> repeatedEvents = [];
  static void generateRepeatedEvents(List<DbEvent?> events) {
    // Clear the list before generating new events
    repeatedEvents.clear();

    // Iterate through each event and repeat it for the next 10 years
    for (var event in events) {
      // Get the special day for the current event
      var evdate =
          DateTime.parse(event?.evdate.v ?? '1970-01-01');

      // Iterate through the next 10 years and repeat the event
      for (int i = 0; i < 2; i++) {
        // Add the repeated event to the list
        repeatedEvents.add(DbEvent()
          ..id.v = int.parse('${event?.id.v}$i')
          ..firstName.v = event?.firstName.v
          ..lastName.v = event?.lastName.v
          ..evdate.v =
              DateTime(evdate.year + i, evdate.month, evdate.day)
                  .toString()
          ..ideas.v = event?.ideas.v);
      }
    }

    // Sort the list of repeated events by the special day
    repeatedEvents.sort(
        (a, b) => DateTime.parse(a.evdate.v!)
            .compareTo(DateTime.parse(b.evdate.v!)));
  }
}
