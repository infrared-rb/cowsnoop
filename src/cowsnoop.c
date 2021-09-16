/*
** mrb_cowsnoop.c - Cowsnoop class
**
** Copyright (c) Uchio Kondo 2021
**
** See Copyright Notice in LICENSE
*/

#include <string.h>

#include <mruby.h>
#include <mruby/data.h>
#include <mruby/error.h>
#include "mrb_cowsnoop.h"

#include "types.h"
#include "cowsnoop.bpf.h"

#define DONE mrb_gc_arena_restore(mrb, 0);

static void mrb_cowsnoop_bpf_free(mrb_state *mrb, void *p)
{
  struct cowsnoop_bpf *obj = p;
  cowsnoop_bpf__destroy(obj);
}

static const struct mrb_data_type mrb_cowsnoop_bpf_data_type = {
  "cowsnoop_bpf", mrb_cowsnoop_bpf_free,
};

static mrb_value mrb_cowsnoop_bpf_init(mrb_state *mrb, mrb_value self)
{
  char* comm;
  mrb_int len;
  mrb_get_args(mrb, "z", &comm, &len);

  struct cowsnoop_bpf *data;
  data = (struct cowsnoop_bpf *)DATA_PTR(self);
  if (data) {
    mrb_raise(mrb, E_RUNTIME_ERROR, "Cannot initialize twice");
  }
  DATA_TYPE(self) = &mrb_cowsnoop_bpf_data_type;
  DATA_PTR(self) = NULL;

  data = cowsnoop_bpf__open();
  if (comm) {
    if (!strncpy((char *)data->rodata->targ_comm, comm, sizeof(data->rodata->targ_comm) - 1)) {
      mrb_sys_fail(mrb, "strncpy");
    }
  }
  DATA_PTR(self) = data;

  return self;
}

static mrb_value mrb_cowsnoop_bpf_load(mrb_state *mrb, mrb_value self)
{
  struct cowsnoop_bpf *data = DATA_PTR(self);
  return mrb_fixnum_value(cowsnoop_bpf__load(data));
}

static mrb_value mrb_cowsnoop_bpf_attach(mrb_state *mrb, mrb_value self)
{
  struct cowsnoop_bpf *data = DATA_PTR(self);
  return mrb_fixnum_value(cowsnoop_bpf__attach(data));
}

mrb_value mrb_libbpf_map_generate(mrb_state *mrb,
                                  int key_size,
                                  int value_size,
                                  enum bpf_map_type type,
                                  struct bpf_map *ptr);

static mrb_value mrb_cowsnoop_bpf_get_counter_map(mrb_state *mrb, mrb_value self)
{
  struct cowsnoop_bpf *data = DATA_PTR(self);
  struct bpf_map *ptr = data->maps.counter;
  const struct bpf_map_def *def = bpf_map__def(ptr);

  mrb_value map = mrb_libbpf_map_generate(mrb,
                                          def->key_size,
                                          def->value_size,
                                          def->type,
                                          ptr
                                          );

  return map;
}

void mrb_cowsnoop_gem_init(mrb_state *mrb)
{
  struct RClass *builder;
  builder = mrb_define_class(mrb, "CowsnoopBuilder", mrb->object_class);
  mrb_define_method(mrb, builder, "initialize", mrb_cowsnoop_bpf_init, MRB_ARGS_REQ(1));
  mrb_define_method(mrb, builder, "load", mrb_cowsnoop_bpf_load, MRB_ARGS_NONE());
  mrb_define_method(mrb, builder, "attach", mrb_cowsnoop_bpf_attach, MRB_ARGS_NONE());

  // TODO: get from skelton?
  mrb_define_method(mrb, builder, "counter_map", mrb_cowsnoop_bpf_get_counter_map, MRB_ARGS_NONE());
  DONE;
}
void mrb_cowsnoop_gem_final(mrb_state *mrb)
{
}
