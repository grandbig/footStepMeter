# Podfile
platform :ios, "11.0"
use_frameworks!

target "footStepMeter" do
 	pod 'RealmSwift'
	pod 'RxSwift',    '~> 5'
	pod 'RxCocoa',    '~> 5'
	pod 'RxDataSources', '~> 4.0'
	pod 'R.swift'
	pod 'LicensePlist'
end

target "footStepMeterTests" do 
	pod 'RealmSwift'
	pod 'RxSwift',    '~> 5'
	pod 'RxCocoa',    '~> 5'
	pod 'RxBlocking', '~> 5'
	pod 'RxTest',     '~> 5'
end

target "footStepMeterUITests" do 
	pod 'RealmSwift'
	pod 'RxSwift',    '~> 5'
	pod 'RxCocoa',    '~> 5'
	pod 'RxBlocking', '~> 5'
	pod 'RxTest',     '~> 5'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '5.2'
    end
  end
end
