Pod::Spec.new do |spec|
  spec.name         = 'TCMXMLWriter'
  spec.version      = '1.0.0'
  spec.license      = 'MIT'
  spec.homepage     = 'https://github.com/monkeydom/TCMXMLWriter'
  spec.author       = 'Dominik Wagner'
  spec.summary      = 'Elegant cocoa XML marshalling with a small memory footprint'
  spec.source       = { :git => 'https://github.com/monkeydom/TCMXMLWriter.git', :tag => spec.version.to_s }
  spec.source_files = 'TCMXML/TCMXMLWriter.{h,m}'
  spec.framework    = 'Foundation'
  spec.requires_arc = true
end
