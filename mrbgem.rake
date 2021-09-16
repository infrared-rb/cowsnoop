MRuby::Gem::Specification.new('cowsnoop') do |spec|
  spec.bins = ['cowsnoop']
  spec.license = 'MIT'
  spec.authors = 'Uchio Kondo'
  spec.version = '0.0.1'

  binname = spec.bins[0]

  path = File.expand_path('../mruby-libbpf', File.dirname(__FILE__))
  if File.exist? path
    spec.add_dependency 'mruby-libbpf', path: path
  else
    spec.add_dependency 'mruby-libbpf', github: 'infrared-rb/mruby-libbpf'
  end
  spec.add_dependency 'mruby-sleep'

  def spec.generate_bpf_files(binname)
    bpfdir = File.expand_path('./bpf', File.dirname(__FILE__))
    srcdir = File.expand_path('./src', File.dirname(__FILE__))

    file "#{bpfdir}/#{binname}.bpf.c"

    file "#{bpfdir}/vmlinux.h" do
      puts "bpftool\tbtf dump file /sys/kernel/btf/vmlinux format c > #{bpfdir}/vmlinux.h"
      begin
        sh "bpftool btf dump file /sys/kernel/btf/vmlinux format c > #{bpfdir}/vmlinux.h"
      rescue => e
        sh "rm -f #{bpfdir}/vmlinux.h"
        raise e
      end
    end

    file "#{bpfdir}/cowsnoop.bpf.o" => ["#{bpfdir}/#{binname}.bpf.c", "#{bpfdir}/vmlinux.h"] do
      puts "clang\t-O2 -c -g -target bpf #{bpfdir}/#{binname}.bpf.c -o #{bpfdir}/#{binname}.bpf.o"
      sh "clang -O1 -c -g -target bpf #{bpfdir}/#{binname}.bpf.c -o #{bpfdir}/#{binname}.bpf.o"
    end

    headers = []

    file "#{srcdir}/#{binname}.bpf.h" => "#{bpfdir}/#{binname}.bpf.o" do
      puts "bpftool\tgen skeleton #{bpfdir}/#{binname}.bpf.o > #{srcdir}/#{binname}.bpf.h"
      begin
        sh "bpftool gen skeleton #{bpfdir}/#{binname}.bpf.o > #{srcdir}/#{binname}.bpf.h"
      rescue => e
        sh "rm -f #{srcdir}/#{binname}.bpf.h"
        raise e
      end
    end
    headers << "#{srcdir}/#{binname}.bpf.h"

    if File.exist? "#{bpfdir}/types.h"
      file "#{srcdir}/types.h" => "#{bpfdir}/types.h" do
        sh "cp #{bpfdir}/types.h #{srcdir}/types.h"
      end
      headers << "#{srcdir}/types.h"
    end

    c_codes = Dir.glob("#{srcdir}/*.c")
    file c_codes[0] => headers
  end

  spec.generate_bpf_files(binname)
end
