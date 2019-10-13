Pod::Spec.new do |s|

# 1
s.platform = :ios
s.ios.deployment_target = '12.0'
s.name = "AdHash-iOS"
s.summary = "Library for AdHash using."
s.requires_arc = true

# 2
s.version = "0.1.0"

# 3
s.license = { :type => "MIT", :file => "LICENSE" }

# 5 - Replace this URL with your own GitHub page's URL (from the address bar)
s.homepage = "https://github.com/dimasenchik/AdHash-iOS"

# 6 - Replace this URL with your own Git URL from "Quick Setup"
s.source = { :git => "https://github.com/dimasenchik/AdHash-iOS.git", 
             :tag => "#{s.version}" }

# 8
s.source_files = "AdHash-iOS/**/*.{swift}"

# 9
s.resources = "AdHash-iOS/**/*.{xcdatamodeld}"

# 10
s.swift_version = "5.0"

end