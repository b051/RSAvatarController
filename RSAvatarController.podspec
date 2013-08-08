Pod::Spec.new do |s|
  s.name         = "RSAvatarController"
  s.version      = "0.0.1"
  s.summary      = "A short description of RSAvatarController."
  s.description  = <<-DESC
                    An optional longer description of RSAvatarController
  
                    * Markdown format.
                    * Don't worry about the indent, we strip it!
                   DESC
  s.homepage     = "https://github.com/b051/RSAvatarController"
  s.license      = 'Apache 2.0'
  s.author       = { "Rex Sheng" => "shengning@gmail.com" }
  s.source       = { :git => "https://github.com/b051/RSAvatarController.git", :tag => "0.0.1" }

  s.platform     = :ios, '6.0'
  s.source_files = '*.{h,m}'
  s.requires_arc = true
end
