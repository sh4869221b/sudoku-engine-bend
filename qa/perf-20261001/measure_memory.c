#define _GNU_SOURCE
#include <sys/resource.h>
#include <sys/wait.h>
#include <time.h>
#include <unistd.h>
#include <stdio.h>
/* Measurement only: a tiny launcher avoids inherited Python pre-exec RSS. */
static double ms(struct timespec t) { return t.tv_sec*1000.0+t.tv_nsec/1e6; }
int main(int argc,char **argv) {
 if(argc<3)return 125;
 struct timespec start,end;clock_gettime(CLOCK_MONOTONIC,&start);
 pid_t pid=fork();if(pid<0){perror("fork");return 125;}
 if(pid==0){execvp(argv[2],argv+2);perror("exec");_exit(126);}
 int status;struct rusage usage;
 if(wait4(pid,&status,0,&usage)<0){perror("wait4");return 125;}
 clock_gettime(CLOCK_MONOTONIC,&end);
 FILE *f=fopen(argv[1],"w");if(!f){perror("metrics");return 125;}
 fprintf(f,"{\"wall_ms\":%.6f,\"user_ms\":%.6f,\"system_ms\":%.6f,\"peak_rss_kib\":%ld}\n",ms(end)-ms(start),usage.ru_utime.tv_sec*1000.0+usage.ru_utime.tv_usec/1000.0,usage.ru_stime.tv_sec*1000.0+usage.ru_stime.tv_usec/1000.0,usage.ru_maxrss);fclose(f);
 return WIFEXITED(status)?WEXITSTATUS(status):128+WTERMSIG(status);
}
