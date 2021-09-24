VERSION = '0.1.0'
Version = VERSION
Release = RELEASE = nil

def defined?(v)
  v
rescue NameError
  nil
end
