#include "vmlinux.h"

// libbpf version issue...
#ifndef PT_REGS_PARM1
#define PT_REGS_PARM1(x) ((x)->di)
#endif

#include <bpf/bpf_helpers.h>
#include <bpf/bpf_tracing.h>
#include "types.h"

const volatile char targ_comm[TASK_COMM_LEN] = {0};
static __u32 initial_value = 0;

struct {
  __uint(type, BPF_MAP_TYPE_HASH);
  __uint(max_entries, 10240);
  __type(key, __u32);
  __type(value, __u32);
  __uint(map_flags, BPF_F_NO_PREALLOC);
} counter SEC(".maps");

static __always_inline bool comm_allowed(const char *comm)
{
  int i;

  if (targ_comm[0] == '\0')
    return true;

  for (i = 0; targ_comm[i] != '\0' && i < TASK_COMM_LEN; i++) {
    if (comm[i] != targ_comm[i])
      return false;
  }
  return true;
}

SEC("kprobe/do_wp_page")
int BPF_KPROBE(do_wp_page, struct vm_fault *arg0)
{
  __u32 pid;
  char comm[TASK_COMM_LEN] = {0};
  pid = bpf_get_current_pid_tgid();

  bpf_get_current_comm(&comm, sizeof(comm));
  if (!comm_allowed(comm))
    return 0;

  __u32 *p = bpf_map_lookup_elem(&counter, &pid);
  if (!p) {
    bpf_map_update_elem(&counter, &pid, &initial_value, 0);
    p = bpf_map_lookup_elem(&counter, &pid);
    if (!p)
      return 0;
  }

  __sync_fetch_and_add(p, 1);

  return 0;
}
