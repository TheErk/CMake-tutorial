#ifndef ACRODICT_H
#define ACRODICT_H
typedef struct acroItem {
  char* name;
  char* description;
} acroItem_t;

const acroItem_t*
acrodict_get(const char* name);

const acroItem_t*
acrodict_get_approx(const char* name);
#endif