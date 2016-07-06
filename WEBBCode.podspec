#
# Be sure to run `pod lib lint WEBBCode.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'WEBBCode'
  s.version          = '0.2.0'
  s.summary          = 'A fast SAX style parser for BBCode in Objective C with support for various transformations'

  s.description      = <<-DESC

                    This is a lean and mean SAX style parser for BBCode written in Objective C/C.

                    It has support for output to HTML and NSAttributedString (work in progress) for simple BBCode.

                    It is totally pluggable and extensible to allow for full customization.

                       DESC

  s.homepage         = 'https://github.com/werner77/WEBBCode'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Werner Altewischer' => 'werner.altewischer@gmail.com' }
  s.source           = { :git => 'https://github.com/werner77/WEBBCode.git', :tag => s.version.to_s }

  s.ios.deployment_target = '6.0'

  s.subspec 'Core' do |s_core|
       s_core.source_files = 'WEBBCode/Classes/Core/**/*'
       s_core.public_header_files = 'WEBBCode/Classes/Core/**/*.h'
  end

  s.subspec 'HTML' do |s_html|
      s_html.source_files = 'WEBBCode/Classes/HTML/**/*'
      s_html.public_header_files = 'WEBBCode/Classes/HTML/**/*.h'
      s_html.dependency 'WEBBCode/Core'
  end

end
