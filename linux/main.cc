#include "digi_xpenselication.h"

int main(int argc, char** argv) {
  g_autoptr(MyApplication) app = digi_xpenselication_new();
  return g_application_run(G_APPLICATION(app), argc, argv);
}
