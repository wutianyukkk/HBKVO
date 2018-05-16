
Pod::Spec.new do |s|
  s.name             = 'HBKVO'
  s.version          = '0.1.0'
  s.summary          = '自定义KVO实现'
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/wutianyukkk/HBKVO'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'wutianyukkk@sina.com' => 'zhaoliangbo' }
  s.source           = { :git => 'https://github.com/wutianyukkk/HBKVO.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'HBKVO/Classes/**/*'
end
