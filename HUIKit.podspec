Pod::Spec.new do |s|

  s.name         = "HUIKit"
  s.version      = "1.2.3"
  s.summary      = "A short description of HUIKit."

  s.description  = <<-DESC
                   A longer description of HUIKit in Markdown format.

                   * Think: Why did you write this? What is the focus? What does it do?
                   * CocoaPods will be using this to generate tags, and improve search results.
                   * Try to keep it short, snappy and to the point.
                   * Finally, don't worry about the indent, CocoaPods strips it!
                   DESC

  s.homepage     = "https://github.com/jumperb/HUIKit"
  s.license      = "Copyright"
  s.author       = { "jumperb" => "zhangchutian_05@163.com" }
  s.source       = { :git => "https://github.com/jumperb/HUIKit.git", :tag => s.version.to_s}
  s.source_files  = 'Classes/**/*.{h,m}'
  s.dependency 'Hodor'
  s.dependency 'SDWebImage'
  s.requires_arc = true
  s.ios.deployment_target = '7.0'
  
end
