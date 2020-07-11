Pod::Spec.new do |s|
  s.name          = "Shapr3DFileConverter"
  s.version       = "0.0.1"
  s.summary       = "Shapr3DFileConverter"
  s.description   = "A library to convert shapr files to multiple file formats"
  s.homepage      = "https://github.com/aldrich/"
  s.license       = "MIT"
  s.author        = "aldrich"
  s.platform      = :ios, "10.0"
  s.swift_version = "4.2"
  s.source        = {
    :git => "https://github.com/aldrich/Shapr3DFileConverter.git",
    :tag => "#{s.version}"
  }
  s.source_files        = "Shapr3DFileConverter/**/*.{h,m,swift}"
  s.public_header_files = "Shapr3DFileConverter/**/*.h"
end
