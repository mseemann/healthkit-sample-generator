Pod::Spec.new do |s|
s.name             = "HealthKitSampleGenerator"
s.version          = "0.2.0"
s.summary          = "Export/Import/Sample Generator for HealthKit Data (Swift + UI)"
s.homepage         = "https://github.com/mseemann/healthkit-sample-generator"
s.license          = 'MIT'
s.author           = { "Michael Seemann" => "pods@mseemann.de" }
s.source           = { :git => "https://github.com/mseemann/healthkit-sample-generator.git", :tag => s.version.to_s }


s.platform     = :ios, '9.0'
s.requires_arc = true

s.source_files = 'Pod/Classes/**/*'
s.resource_bundles = {
'HealthKitSampleGenerator' => ['Pod/Assets/*.png']
}

end
