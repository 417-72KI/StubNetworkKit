PROJECT_NAME = StubNetworkKit

ver = 0.5.0

.SILENT:

test:
	rm -rf test_output
	xcrun -sdk macosx xcodebuild \
		-scheme ${PROJECT_NAME} \
		-destination 'platform=macOS' \
		-enableCodeCoverage=YES \
		-resultBundlePath "test_output/test.xcresult" \
		test | xcpretty
	xed test_output/test.xcresult

release:
	scripts/release.sh ${PROJECT_NAME} ${ver}

podspec:
	POD_VERSION=${ver} pod spec lint --allow-warnings
