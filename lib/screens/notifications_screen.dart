import '../repositories/notifications_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/notification.dart' as model;
import '../bloc/notifications_bloc.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'detail_screen.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _showNewsOnly = false;

  @override
  Widget build(BuildContext context) {
    final notificationsRepository = Provider.of<NotificationsRepository>(context);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoNavigationBarBackButton(
          previousPageTitle: 'Back',
          onPressed: () {},
        ),
        middle: const Text('Notifications'),
        trailing: GestureDetector(
          onTap: () {
            context.read<NotificationsBloc>().add(DeleteReadNotifications());
          },
          child: const Text('Mark all read'),
        ),
      ),
      child: Stack(
        children: <Widget>[
          BlocProvider(
            create: (context) => NotificationsBloc(notificationsRepository: notificationsRepository)..add(FetchNotifications()),
            child: BlocBuilder<NotificationsBloc, NotificationsState>(
              builder: (context, state) {
                if (state is NotificationsInitial && !_showNewsOnly) {
                  return const Center(child: CupertinoActivityIndicator());
                } else if (state is NotificationsFailure) {
                  return const Center(child: Text('Failed to load notifications'));
                } else if (state is NotificationsSuccess) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      setState(() {
                        _showNewsOnly = !_showNewsOnly;
                      });
                      context.read<NotificationsBloc>().add(FetchNotifications());
                    },
                  child: ListView.builder(
                    itemCount: _showNewsOnly ? state.notifications.length : state.notifications.length + 1,
                    itemBuilder: (context, index) {
                      if (_showNewsOnly) {
                        return _buildNotificationItem(context, state.notifications[index]);
                      } else {
                        if (index == 0) {
                          return state.notifications.isNotEmpty
                              ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildFeaturedText(),
                              _buildFeaturedNotification(context, state.notifications[0]),
                              const SizedBox(height: 16),
                              _buildLatestNewsText(),
                            ],
                          )
                              : Container();
                        } else {
                          if (index < state.notifications.length) {
                            return _buildNotificationItem(context, state.notifications[index]);
                          } else {
                            return Container();
                          }
                        }
                      }
                    },
                  ),);
                }
                return Container();
              },
            ),
          ),
          Positioned(
            right: 20,
            bottom: 20,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showNewsOnly = !_showNewsOnly;
                });
              },
              child: Icon(_showNewsOnly ? CupertinoIcons.back : CupertinoIcons.arrow_up, size: 56),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedText() {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
        child: Text(
          'Featured',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontStyle: FontStyle.italic,
            fontFamily: 'Open Sans',
            fontWeight: FontWeight.w300,
            letterSpacing: 0.40,
            decoration: TextDecoration.none, // Remove underline
            backgroundColor: Colors.transparent, // Remove background color
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedNotification(BuildContext context, model.Notification notification) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(
              imagePath: notification.imageUrl,
              title: notification.title,
              htmlBody: notification.body,
            ),
          ),
        );
      },
      child: Card(
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            AspectRatio(
              aspectRatio: 25/9, // Set the aspect ratio of the picture
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  image: DecorationImage(
                    image: NetworkImage(notification.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                notification.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLatestNewsText() {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
        child: Text(
          'Latest news',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontStyle: FontStyle.italic,
            fontFamily: 'Open Sans',
            fontWeight: FontWeight.w300,
            letterSpacing: 0.40,
            decoration: TextDecoration.none, // Remove underline
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(BuildContext context, model.Notification notification) {
    // Parse the ISO 8601 date string
    DateTime notificationDate = DateTime.parse(notification.timestamp);

    // Calculate the difference in days from the notification date to the current date
    DateTime currentDate = DateTime.now();
    int daysDifference = currentDate.difference(notificationDate).inDays;

    // Only show the card if the notification is not marked as read
    if (!notification.isRead) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailScreen(
                imagePath: notification.imageUrl,
                title: notification.title,
                htmlBody: notification.body,
              ),
            ),
          );
        },
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 90,
                  height: 60,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          notification.imageUrl,
                          fit: BoxFit.fill,
                          errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                            // Return a CupertinoIcon in a Container
                            return Container(
                              alignment: Alignment.center,
                              child: const Icon(
                                CupertinoIcons.photo_fill_on_rectangle_fill,
                                size: 50, // adjust size as needed
                                color: Colors.grey, // adjust color as needed
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8.0), // Add space between the image and text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontFamily: 'Open Sans',
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.32,
                        ),
                      ),
                      Text(
                        // Display the number of days since the notification was made
                        '$daysDifference ${daysDifference == 1 ? 'day ago' : 'days ago'}',
                        style: const TextStyle(
                          color: Color(0xFF9A9A9A),
                          fontSize: 12,
                          fontFamily: 'Open Sans',
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.24,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // If the notification is marked as read, return an empty container to hide it
      return Container();
    }
  }
}