#define _GNU_SOURCE
#include <stdlib.h>
#include <string.h>
#include "acrodict.h"

static const acroItem_t acrodict[] = {
  {"Toulibre", "Toulibre is a french organization promoting FLOSS"},
  {"GNU", "GNU is Not Unix"},
  {"GPL", "GNU general Public License"},
  {"BSD", "Berkeley Software Distribution"},
  {"CULTe","Club des Utilisateurs de Logiciels libres et de gnu/linux de Toulouse et des environs"},
  {"Lea", "Lea-Linux: Linux entre ami(e)s"},
  {"RMLL","Rencontres Mondiales du Logiciel Libre"},
  {"FLOSS","Free Libre Open Source Software"},
  {"",""}
};

const acroItem_t*
acrodict_get(const char* name) {
  int current =0;
  int found   =0;

  while ((strlen(acrodict[current].name)>0) && !found) {
    if (strcasecmp(name,acrodict[current].name)==0) {
      found=1;
    } else {
      current++;
    }
  }
  if (found) {
    return &(acrodict[current]);
  } else {
    return NULL;
  }
}

const acroItem_t*
acrodict_get_approx(const char* name) {
#ifdef GUESS_NAME
  int current =0;
  int found   =0;

  while ((strlen(acrodict[current].name)>0) && !found) {
    if ((strcasestr(name,acrodict[current].name)!=0) ||
        (strcasestr(acrodict[current].name,name)!=0)) {
      found=1;
    } else {
      current++;
    }
  }
  if (found) {
    return &(acrodict[current]);
  } else
#endif
  {
    return NULL;
  }
}
