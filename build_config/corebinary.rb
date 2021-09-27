MRuby::Build.new do |conf|
  toolchain :gcc
  #conf.gembox 'default'

  conf.gembox "stdlib"
  conf.gembox "stdlib-ext"
  conf.gembox "stdlib-io"
  conf.gembox "math"
  conf.gembox "metaprog"

  conf.gem :core => "mruby-bin-mrbc"
  # FIXME: mirb requires libreadline, which has some problems in statis link
  # conf.gem :core => "mruby-bin-mirb"
  conf.gem :core => "mruby-bin-mruby"
  conf.gem :core => "mruby-bin-strip"
  conf.gem :core => "mruby-bin-config"

  conf.gem File.expand_path('../../', __FILE__)
  conf.enable_test

  if ENV['RELEASE'] != 'true'
    conf.enable_debug
    conf.cc.defines = %w(MRB_USE_DEBUG_HOOK)
    conf.gem core: 'mruby-bin-debugger'
  end

  conf.cc.flags += ["-static", "-lc", "-lm", "-lelf"]
  conf.linker.flags += ["-static", "-lc", "-lm", "-lelf"]
end
