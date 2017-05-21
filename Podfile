# Podfile
use_frameworks!

target "footStepMeter" do
  # Normal libraries
  pod 'RealmSwift'

  abstract_target 'Tests' do
    inherit! :search_paths
    target "footStepMeterTests"
    target "footStepMeterUITests"

    pod 'Quick'
    pod 'Nimble'
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end
