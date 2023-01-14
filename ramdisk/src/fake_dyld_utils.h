#ifndef FAKE_DYLD_UTILS
#define FAKE_DYLD_UTILS

#include <stdint.h>

#define ROOTFS_IOS15        "/dev/disk0s1s1"
#define ROOTFS_IOS16        "/dev/disk1s1"
#define ROOTFS_RAMDISK      "/dev/md0"

#define LAUNCHD_PATH        "/sbin/launchd"
#define PAYLOAD_PATH        "/haxx"
#define CUSTOM_DYLD_PATH    "/fs/gen/dyld"

#ifdef ROOTFULL
#define LIBRARY_PATH        "/haxz.dylib"
#else
#define LIBRARY_PATH        "/haxx.dylib"
#endif

#define IS_IOS16        (1900)
#define IS_IOS15        (1800)

#define STDOUT_FILENO   (1)
#define getpid()        msyscall(20)
#define exit(err)       msyscall(1, err)
#define fork()          msyscall(2)
#define puts(str)       write(STDOUT_FILENO, str, sizeof(str) - 1)

#define O_RDONLY        0
#define O_WRONLY        1
#define O_RDWR          2
#define O_CREAT         0x00000200      /* create if nonexistant */

#define SEEK_SET        0
#define SEEK_CUR        1
#define SEEK_END        2

#define PROT_NONE       0x00    /* [MC2] no permissions */
#define PROT_READ       0x01    /* [MC2] pages can be read */
#define PROT_WRITE      0x02    /* [MC2] pages can be written */
#define PROT_EXEC       0x04    /* [MC2] pages can be executed */

#define MAP_FILE        0x0000  /* map from file (default) */
#define MAP_ANON        0x1000  /* allocated from memory, swap space */
#define MAP_ANONYMOUS   MAP_ANON
#define MAP_SHARED      0x0001          /* [MF|SHM] share changes */
#define MAP_PRIVATE     0x0002          /* [MF|SHM] changes are private */


#define MNT_RDONLY      0x00000001
#define MNT_LOCAL       0x00001000
#define MNT_ROOTFS      0x00004000      /* identifies the root filesystem */
#define MNT_UNION       0x00000020
#define MNT_UPDATE      0x00010000      /* not a real mount, just an update */
#define MNT_NOBLOCK     0x00020000      /* don't block unmount if not responding */
#define MNT_RELOAD      0x00040000      /* reload filesystem data */
#define MNT_FORCE       0x00080000      /* force unmount or readonly change */

#define MOUNT_WITH_SNAPSHOT                 (0)
#define MOUNT_WITHOUT_SNAPSHOT              (1)

#define checkrain_option_none               0x00000000
#define checkrain_option_all                0x7fffffff
#define checkrain_option_failure            0x80000000

#define checkrain_option_safemode           (1 << 0)
#define checkrain_option_bind_mount         (1 << 1)
#define checkrain_option_overlay            (1 << 2)
#define checkrain_option_force_revert       (1 << 7) /* keep this at 7 */

typedef uint32_t checkrain_option_t, *checkrain_option_p;

struct kerninfo {
    uint64_t size;
    uint64_t base;
    uint64_t slide;
    checkrain_option_t flags;
};

typedef uint32_t kern_return_t;
typedef uint32_t mach_port_t;
typedef uint64_t mach_msg_timeout_t;

void sleep(int secs);
int sys_dup2(int from, int to);
int stat(void *path, void *ub);
int mount(char *type, char *path, int flags, void *data);
void *mmap(void *addr, size_t length, int prot, int flags, int fd, uint64_t offset);
uint64_t write(int fd, void* cbuf, size_t nbyte);
int close(int fd);
int open(void *path, int flags, int mode);
int execve(char *fname, char *const argv[], char *const envp[]);
int unlink(void *path);
uint64_t read(int fd, void *cbuf, size_t nbyte);
uint64_t lseek(int fd, int32_t offset, int whence);
int mkdir(char* path, int mode);
void _putchar(char character);
void spin(void);
void memcpy(void *dst, void *src, size_t n);
void memset(void *dst, int c, size_t n);



#endif
