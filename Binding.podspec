
Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  spec.name         = "Binding"
  spec.version      = "0.0.1"
  spec.summary      = "Binding Library for RxSwift"
  spec.description  = <<-DESC
  Binding Library for RxSwift. It's enable one way binding and two way binding
                   DESC

  spec.homepage     = "https://github.com/supenkwibowo/Binding"
  spec.ios.deployment_target  = '9.0'

  spec.license       = { :type => 'MIT', :file => "LICENSE.md" }
  spec.author       = "Sugeng Wibowo"
  spec.source       = { :git => "https://github.com/supenkwibowo/Binding.git", :tag => "#{spec.version}" }

  spec.source_files  = "Sources", "Sources/**/*.swift"
  spec.dependency "RxSwift", "~> 6.2.0"
  spec.dependency "RxRelay", "~> 6.2.0"
  spec.dependency "RxCocoa", "~> 6.2.0"

  spec.swift_version = '5.1'
end
