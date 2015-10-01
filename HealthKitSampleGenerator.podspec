Pod::Spec.new do |s|
s.name             = "HealthKitSampleGenerator"
s.version          = "0.1.0"
s.summary          = "A Generator for HealthKit Sample Data."
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
