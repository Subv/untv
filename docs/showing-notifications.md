Notifications API
=================

UNTV employs the use of the `Notifier` class upon initialization and passes this instance to the `GlobalMenu`, which in turn hands out a reference to all the non-passive extensions. Wherever we have access to the `Notifier` instance, we can show notifications to the user.

There are 2 types of notifications: standard and passive.

Standard notifications steal focus from the remote, effectively blocking all user interaction until dismissed, while passive notifications simply appear and dismiss on their own and do not steal remote focus.

## Core Methods

#### notifier.notify(from, content, is_passive)

Creates and displays a notification. The `from` argument will appear as a title bar of sorts and is intended to allow you to inform the user what extension or component initiated the notification. The `content` argument should be the text/html content of the notification and the `is_passive` flag will determine how to deliver your notification.

#### notifier.dismiss()

Dismisses the currently active non-passive notification.
