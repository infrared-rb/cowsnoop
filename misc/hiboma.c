/*
 * A sample command to invoke CoW artificially
 * Code created by Hiroya Ito (c) 2021
 * ref https://hiboma.hatenadiary.jp/entry/2021/09/01/123240 (Japanese)
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <unistd.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/wait.h>

int main(int argc, char *argv[])
{
    /* CoW を起こしたいページ数 */
    int pages = 100;

    /* getconf PAGESIZE */
    size_t page_size = 4096;

    /* 観察しやすいようにアドレスを固定する */
    char *p1 = (char*)mmap((void *)0x100000000000, page_size * pages,
                   PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, 0, 0);

    if (p1 == MAP_FAILED) {
        perror("failed to mmap");
        exit(1);
    }

    printf("mmap: %p\n", p1);

    /* 親プロセス: minor page fault */
    for (int i = 0; i < pages; i++) {
        p1[i * page_size] = 'p';
    }

    pid_t pid = fork();
    if (pid == -1) {
        perror("failed to fork");
        exit(1);
    } else if (pid == 0) {
        printf("child pid:%d\n", getpid());

        /* 子プロセス: minor page fault -> cow -> do_wp_page */
        for (int i = 0; i < pages; i++) {
            printf("cow address: %p\n", &p1[i * page_size]);
            p1[i * page_size] = 'c';
            sleep(1);
        }
    } else {
        printf("parent pid:%d\n", getpid());
        waitpid(pid, NULL, 0);
    }
}
