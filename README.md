# cowsnoop [![mruby](https://github.com/infrared-rb/cowsnoop/actions/workflows/ci.yml/badge.svg)](https://github.com/infrared-rb/cowsnoop/actions/workflows/ci.yml)

cowsnoop is a BPF CO-RE binary to detect CoW commitments. 

## Build && install

### Prerequisites

- mruby's build dependencies. [See here](https://github.com/mruby/mruby/blob/master/doc/guides/compile.md)
- mruby-libbpf, which will depend on `libelf-dev`
- `bpftool` command
- Kernel >= 5.9 or downloaded `vmlinux.h`

### Instruction

```console
$ rake
$ sudo install ./mruby/bin/cowsnoop /usr/local/bin
```

## License

under the MIT License:

- see LICENSE file
