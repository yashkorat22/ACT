import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../models/classEvent.dart';

import '../../../helpers/calendar_utils.dart';

import '../../../elements/CalendarEventWidget.dart';

class EventCalendarWidget extends StatefulWidget {
  List<ClassEvent> events;
  final Function updateMonth;
  final Function scheduleEvent;
  final Function cancelEvent;
  final bool showAddButton;

  EventCalendarWidget({
    Key? key,
    required this.events,
    required this.updateMonth,
    required this.scheduleEvent,
    required this.cancelEvent,
    this.showAddButton = true,
  }) : super(key: key);

  @override
  _EventCalendarWidget createState() => _EventCalendarWidget();
}

class _EventCalendarWidget extends StateMVC<EventCalendarWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  Key listKey = new GlobalKey();

  DateTime? _selectedDate;
  DateTime _focusedDate = DateTime.now();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animationController.forward();

    _selectedDate = DateTime.now();
  }

  void handleVisibleDaysChange(DateTime first, DateTime last) {
    widget.updateMonth(first: first, last: last);
  }

  bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Map<DateTime, List> convertEventsToNameList() {
    Map<DateTime, List> eventDays = {};
    widget.events.forEach((event) {
      final date = DateTime.parse(event.eventDateTime! + 'Z');
      final dayOnly = DateTime(date.year, date.month, date.day);
      if (eventDays[dayOnly] == null) {
        eventDays[dayOnly] = [];
      }
      eventDays[dayOnly]!.add(event.eventName);
    });
    return eventDays;
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: isSameDate(_selectedDate!, date)
            ? Colors.brown[500]
            : isSameDate(DateTime.now(), date)
                ? Colors.brown[300]
                : Colors.blue[400],
      ),
      width: 16.0,
      height: 16.0,
      child: Center(
        child: Text(
          '${events.length}',
          style: TextStyle().copyWith(
            color: Colors.white,
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }

  Widget _buildEventList() {
    return ListView(
      key: listKey,
      children: widget.events
          .where((event) {
            final eventDay = DateTime.parse(event.eventDateTime! + 'Z');
            return _selectedDate != null &&
                eventDay.year == _selectedDate!.year &&
                eventDay.month == _selectedDate!.month &&
                eventDay.day == _selectedDate!.day;
          })
          .toList()
          .map(
            (event) => CalendarEventWidget(
              event: event,
              onCancel: () => widget.cancelEvent(event),
              onSchedule: () => widget.scheduleEvent(event),
            ),
          )
          .toList(),
    );
  }

  _onDaySelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    Map<DateTime, List> _eventNameList = convertEventsToNameList();
    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            TableCalendar(
              firstDay: kFirstDay,
              lastDay: kLastDay,
              focusedDay: _focusedDate,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDate, day);
              },
              onDaySelected: (selectedDay, focusedDate) {
                _onDaySelected(selectedDay);
                _animationController.forward(from: 0.0);
              },
              onPageChanged: (focusedDay) {
                _focusedDate = focusedDay;
                final startDay = focusedDay.subtract(Duration(days: focusedDay.weekday % 7));
                final endDay = startDay.add(Duration(days: 34));
                handleVisibleDaysChange(startDay, endDay);
              },
              availableCalendarFormats: const {
                CalendarFormat.month: '',
              },
              eventLoader: (date) {
                final dayOnly = DateTime(date.year, date.month, date.day);
                return _eventNameList[dayOnly] ?? [];
              },
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
              ),
              calendarBuilders: CalendarBuilders(
                selectedBuilder: (context, date, _) {
                  return FadeTransition(
                    opacity: Tween(begin: 0.0, end: 1.0)
                        .animate(_animationController),
                    child: Container(
                      margin: const EdgeInsets.all(4.0),
                      padding: const EdgeInsets.only(top: 5.0, left: 6.0),
                      color: Colors.deepOrange[300],
                      width: 100,
                      height: 100,
                      child: Text(
                        '${date.day}',
                        style: TextStyle().copyWith(fontSize: 16.0),
                      ),
                    ),
                  );
                },
                todayBuilder: (context, date, _) {
                  return Container(
                    margin: const EdgeInsets.all(4.0),
                    padding: const EdgeInsets.only(top: 5.0, left: 6.0),
                    color: Colors.amber[400],
                    width: 100,
                    height: 100,
                    child: Text(
                      '${date.day}',
                      style: TextStyle().copyWith(fontSize: 16.0),
                    ),
                  );
                },
                markerBuilder: (context, date, events) {
                  if (events.isNotEmpty) {
                    return Positioned(
                      right: 1,
                      bottom: 1,
                      child: _buildEventsMarker(date, events),
                    );
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 8.0),
            Expanded(child: _buildEventList()),
          ],
        ),
        if (widget.showAddButton)
          Positioned(
            right: 0,
            bottom: 20,
            child: InkWell(
              child: Icon(
                Icons.add_circle_rounded,
                size: 70,
                color: Theme.of(context).accentColor,
              ),
              onTap: () {
                Navigator.of(context).pushNamed(
                  '/CreateClassEvent',
                  arguments: _selectedDate,
                );
              },
            ),
          ),
      ],
    );
  }
}
