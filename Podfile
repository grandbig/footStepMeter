# Podfile
platform :ios, "11.0"
use_frameworks!

target "footStepMeter" do
 	pod 'RealmSwift'
	pod 'RxSwift',    '~> 4.0'
	pod 'RxCocoa',    '~> 4.0'
	pod 'RxDataSources', '~> 3.0'
	pod 'R.swift',    '5.0.0.alpha.2'
	pod 'LicensePlist'
end

target "footStepMeterTests" do 
	pod 'RealmSwift'
	pod 'RxSwift',    '~> 4.0'
	pod 'RxCocoa',    '~> 4.0'
	pod 'RxBlocking', '~> 4.0'
	pod 'RxTest',     '~> 4.0'
end

target "footStepMeterUITests" do 
	pod 'RealmSwift'
	pod 'RxSwift',    '~> 4.0'
	pod 'RxCocoa',    '~> 4.0'
	pod 'RxBlocking', '~> 4.0'
	pod 'RxTest',     '~> 4.0'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '4.2'
    end
  end
end
