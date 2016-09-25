#define _GNU_SOURCE
#include <stdlib.h>
#include <stdio.h>
#include <strings.h>
#ifdef USE_ACRODICT
#include "acrodict.h"
#endif
int main(int argc, char* argv[]) {

  const char * name;
#ifdef USE_ACRODICT
  const acroItem_t*  item;
#endif

  if (argc < 2) {
    fprintf(stderr,"%s: you need one argument\n",argv[0]);
    fprintf(stderr,"%s <name>\n",argv[0]);
    exit(EXIT_FAILURE);
  }
  name = argv[1];

#ifndef USE_ACRODICT
  if (strcasecmp(name,"toulibre")==0) {
    printf("Toulibre is a french organization promoting FLOSS.\n");
    return EXIT_SUCCESS;
  }
#else
  item = acrodict_get(name);
  if (NULL != item) {
    printf("%s: %s\n",item->name,item->description);
    return EXIT_SUCCESS;
  }
  else {
    item=acrodict_get_approx(name);
    if (NULL != item) {
      printf("<%s> is unknown may be you mean:\n",name);
      printf("%s: %s\n",item->name,item->description);
      return EXIT_SUCCESS;
    }
  }
#endif
  printf("Sorry, I don't know: <%s>\n",name);
  return EXIT_FAILURE;
}
