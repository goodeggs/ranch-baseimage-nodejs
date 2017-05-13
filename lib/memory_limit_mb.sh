#!/bin/sh

# outputs the memory limit in megabytes for the current docker container.
# exits 1 if it cannot be detected.

memory_limit_mb() {
  if [ ! -f /sys/fs/cgroup/memory/memory.limit_in_bytes ]; then
    return 1
  fi

  bytes=$(cat /sys/fs/cgroup/memory/memory.limit_in_bytes)
  echo $(( bytes / 1024 / 1024 ))
}
