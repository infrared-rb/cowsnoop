MRuby::Build.new do |conf|
  toolchain :gcc
  conf.gembox 'default'
  conf.gem File.expand_path('../../', __FILE__)
  conf.enable_test

  if ENV['RELEASE'] != 'true'
    conf.enable_debug
    conf.cc.defines = %w(MRB_USE_DEBUG_HOOK)
    conf.gem core: 'mruby-bin-debugger'
  end
end
