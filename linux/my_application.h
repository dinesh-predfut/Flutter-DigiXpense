#ifndef FLUTTER_digi_xpenseLICATION_H_
#define FLUTTER_digi_xpenseLICATION_H_

#include <gtk/gtk.h>

G_DECLARE_FINAL_TYPE(MyApplication, digi_xpenselication, MY, APPLICATION,
                     GtkApplication)

/**
 * digi_xpenselication_new:
 *
 * Creates a new Flutter-based application.
 *
 * Returns: a new #MyApplication.
 */
MyApplication* digi_xpenselication_new();

#endif  // FLUTTER_digi_xpenseLICATION_H_
