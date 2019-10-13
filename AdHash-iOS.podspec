Pod::Spec.new do |s|

# 1
s.platform = :ios
s.ios.deployment_target = '12.0'
s.name = "AdHash-iOS"
s.summary = "Library for AdHash using."
s.requires_arc = true

s.version = "0.1.0"

s.authors = { 'Dima Senchik' => 'dmitriy.senchik@gmail.com' }

s.license = { :type => "MIT", :file => "LICENSE" }

s.homepage = "https://github.com/dimasenchik/AdHash-iOS"

s.source = { :git => "https://github.com/dimasenchik/AdHash-iOS.git", 
             :tag => "#{s.version}" }

s.source_files = "AdHash-iOS/**/*.{swift}"

s.resources = "AdHash-iOS/**/*.{xcdatamodeld}"

s.swift_version = "5.0"

end