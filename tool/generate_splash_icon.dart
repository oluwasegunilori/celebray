import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

/// Strips white matte from [assets/app_icon.png], copies it to splash assets,
/// regenerates store listing icons, and refreshes iOS LaunchImage PNGs.
void main(List<String> args) {
  const storyboardPath = 'ios/Runner/Base.lproj/LaunchScreen.storyboard';
  const mainStoryboardPath = 'ios/Runner/Base.lproj/Main.storyboard';
  const launchImageDir =
      'ios/Runner/Assets.xcassets/LaunchImage.imageset';

  if (args.contains('--storyboard-only')) {
    _fixStoryboardBackgrounds(storyboardPath, mainStoryboardPath);
    _writeLaunchStoryboard(storyboardPath);
    return;
  }

  const appIconPath = 'assets/app_icon.png';
  const splashIconPath = 'assets/splash_icon.png';

  final source = img.decodeImage(File(appIconPath).readAsBytesSync());
  if (source == null) {
    stderr.writeln('Failed to decode $appIconPath');
    exit(1);
  }

  final cleaned = _cleanIcon(source);
  final transparentBytes = img.encodePng(cleaned);

  File(appIconPath).writeAsBytesSync(transparentBytes);
  stdout.writeln('Cleaned $appIconPath (transparent matte, rounded edge preserved)');

  final splashOpaque = _compositeOnBackground(cleaned);
  File(splashIconPath).writeAsBytesSync(img.encodePng(splashOpaque));
  stdout.writeln('Wrote $splashIconPath (opaque on #111111 for native splash)');

  _writeStoreIcons(cleaned);
  _writeLaunchImages(cleaned, launchImageDir);
  _writeLaunchStoryboard(storyboardPath);
  _fixStoryboardBackgrounds(storyboardPath, mainStoryboardPath);
}

img.Image _cleanIcon(img.Image source) {
  final image = img.Image(
    width: source.width,
    height: source.height,
    numChannels: 4,
  );
  img.fill(image, color: img.ColorRgba8(0, 0, 0, 0));

  for (var y = 0; y < source.height; y++) {
    for (var x = 0; x < source.width; x++) {
      final pixel = source.getPixel(x, y);
      final cleaned = _removeWhiteMattePixel(pixel);
      if (cleaned == null) continue;

      image.setPixelRgba(
        x,
        y,
        cleaned.$1,
        cleaned.$2,
        cleaned.$3,
        cleaned.$4,
      );
    }
  }

  return image;
}

/// Returns RGBA after removing a white matte while preserving rounded-edge AA.
(int, int, int, int)? _removeWhiteMattePixel(img.Pixel pixel) {
  final r = pixel.r.toInt();
  final g = pixel.g.toInt();
  final b = pixel.b.toInt();
  final maxChannel = math.max(r, math.max(g, b));
  final minChannel = math.min(r, math.min(g, b));
  final saturation = maxChannel - minChannel;

  if (_isGold(pixel)) {
    return (r, g, b, 255);
  }

  // Already-processed transparent pixels can be passed through unchanged.
  if (pixel.a.toInt() < 20 && maxChannel < 125) {
    return null;
  }

  // Pure white outer matte.
  if (maxChannel > 245 && saturation < 20) {
    return null;
  }

  // Dark icon plate interior.
  if (maxChannel < 125) {
    return (r, g, b, 255);
  }

  // Light anti-alias between the rounded plate and the white matte.
  if (saturation < 45) {
    final alpha = 255 - maxChannel;
    if (alpha < 12) return null;

    final a = alpha / 255.0;
    final fr = _unblendFromWhite(r, a);
    final fg = _unblendFromWhite(g, a);
    final fb = _unblendFromWhite(b, a);
    return (fr, fg, fb, alpha);
  }

  return (r, g, b, 255);
}

int _unblendFromWhite(int channel, double alpha) {
  final value = ((channel - 255 * (1 - alpha)) / alpha).round();
  return value.clamp(0, 255);
}

bool _isGold(img.Pixel pixel) {
  final r = pixel.r.toInt();
  final g = pixel.g.toInt();
  final b = pixel.b.toInt();
  return r > 130 && g > 85 && b < 100;
}

const _bgR = 17;
const _bgG = 17;
const _bgB = 17;

img.Image _compositeOnBackground(img.Image source) {
  final image = img.Image(
    width: source.width,
    height: source.height,
    numChannels: 4,
  );
  img.fill(image, color: img.ColorRgba8(_bgR, _bgG, _bgB, 255));

  for (var y = 0; y < source.height; y++) {
    for (var x = 0; x < source.width; x++) {
      final pixel = source.getPixel(x, y);
      final alpha = pixel.a.toInt();
      if (alpha < 1) continue;

      final a = alpha / 255.0;
      final r = (pixel.r.toInt() * a + _bgR * (1 - a)).round().clamp(0, 255);
      final g = (pixel.g.toInt() * a + _bgG * (1 - a)).round().clamp(0, 255);
      final b = (pixel.b.toInt() * a + _bgB * (1 - a)).round().clamp(0, 255);

      image.setPixelRgba(x, y, r, g, b, 255);
    }
  }

  return image;
}

void _writeStoreIcons(img.Image cleaned) {
  const outputDir = 'assets/store-icons';
  Directory(outputDir).createSync(recursive: true);

  final storeIcons = {
    'appstore-icon-1024x1024.png': 1024,
    'playstore-icon-512x512.png': 512,
    'icon-512x512.png': 512,
    'icon-256x256.png': 256,
    'icon-128x128.png': 128,
  };

  for (final entry in storeIcons.entries) {
    final resized = img.copyResize(
      cleaned,
      width: entry.value,
      height: entry.value,
      interpolation: img.Interpolation.average,
    );
    final opaque = _compositeOnBackground(resized);
    File('$outputDir/${entry.key}').writeAsBytesSync(img.encodePng(opaque));
  }

  stdout.writeln('Updated store icons in $outputDir');
}

void _writeLaunchImages(img.Image source, String outputDir) {
  final sizes = {
    'LaunchImage.png': 256,
    'LaunchImage@2x.png': 512,
    'LaunchImage@3x.png': 768,
  };

  for (final entry in sizes.entries) {
    final resized = img.copyResize(
      source,
      width: entry.value,
      height: entry.value,
      interpolation: img.Interpolation.average,
    );
    final opaque = _compositeOnBackground(resized);
    File('$outputDir/${entry.key}').writeAsBytesSync(img.encodePng(opaque));
  }

  stdout.writeln('Updated iOS LaunchImage PNGs');
}

void _writeLaunchStoryboard(String path) {
  const storyboard = '''<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<document type="com.apple.InterfaceBuilder3.CocoaTouch.Storyboard.XIB" version="3.0" toolsVersion="12121" systemVersion="16G29" targetRuntime="iOS.CocoaTouch" propertyAccessControl="none" useAutolayout="YES" launchScreen="YES" initialViewController="01J-lp-oVM">
    <dependencies>
        <deployment identifier="iOS"/>
        <plugIn identifier="com.apple.InterfaceBuilder.IBCocoaTouchPlugin" version="12089"/>
    </dependencies>
    <scenes>
        <!--View Controller-->
        <scene sceneID="EHf-IW-A2E">
            <objects>
                <viewController id="01J-lp-oVM" sceneMemberID="viewController">
                    <layoutGuides>
                        <viewControllerLayoutGuide type="top" id="Ydg-fD-yQy"/>
                        <viewControllerLayoutGuide type="bottom" id="xbc-2k-c8Z"/>
                    </layoutGuides>
                    <view key="view" contentMode="scaleToFill" id="Ze5-6b-2t3">
                        <autoresizingMask key="autoresizingMask" widthSizable="YES" heightSizable="YES"/>
                        <subviews>
                            <imageView clipsSubviews="YES" userInteractionEnabled="NO" contentMode="scaleAspectFit" image="LaunchImage" translatesAutoresizingMaskIntoConstraints="NO" id="YRO-k0-Ey4"/>
                        </subviews>
                        <color key="backgroundColor" red="0.066666666666666666" green="0.066666666666666666" blue="0.066666666666666666" alpha="1" colorSpace="custom" customColorSpace="sRGB"/>
                        <constraints>
                            <constraint firstItem="YRO-k0-Ey4" firstAttribute="centerX" secondItem="Ze5-6b-2t3" secondAttribute="centerX" id="1a2-6s-vTC"/>
                            <constraint firstItem="YRO-k0-Ey4" firstAttribute="centerY" secondItem="Ze5-6b-2t3" secondAttribute="centerY" id="4X2-HB-R7a"/>
                            <constraint firstItem="YRO-k0-Ey4" firstAttribute="width" secondItem="Ze5-6b-2t3" secondAttribute="width" multiplier="0.28" id="logo-width"/>
                            <constraint firstItem="YRO-k0-Ey4" firstAttribute="height" secondItem="YRO-k0-Ey4" secondAttribute="width" id="logo-square"/>
                        </constraints>
                    </view>
                </viewController>
                <placeholder placeholderIdentifier="IBFirstResponder" id="iYj-Kq-Ea1" userLabel="First Responder" sceneMemberID="firstResponder"/>
            </objects>
            <point key="canvasLocation" x="53" y="375"/>
        </scene>
    </scenes>
    <resources>
        <image name="LaunchImage" width="1024" height="1024"/>
    </resources>
</document>
''';

  File(path).writeAsStringSync(storyboard);
  stdout.writeln('Wrote $path');
}

void _fixStoryboardBackgrounds(String launchStoryboard, String mainStoryboard) {
  const white =
      'red="1" green="1" blue="1" alpha="1" colorSpace="custom" customColorSpace="sRGB"';
  const black =
      'red="0.066666666666666666" green="0.066666666666666666" blue="0.066666666666666666" alpha="1" colorSpace="custom" customColorSpace="sRGB"';

  for (final path in [launchStoryboard, mainStoryboard]) {
    final file = File(path);
    if (!file.existsSync()) continue;

    final original = file.readAsStringSync();
    final updated = original.replaceAll(white, black);
    if (updated != original) {
      file.writeAsStringSync(updated);
      stdout.writeln('Fixed background in $path');
    }
  }
}
