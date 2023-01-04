#include <stdio.h>

#define MAX_LEN 50
#define NumLine 100

int main() {
  char str[MAX_LEN];
  
  for(int i = 0; i < NumLine; i++) {
    fgets(str,MAX_LEN,stdin);
    printf("%s",str);
  }

  return 0;
}
