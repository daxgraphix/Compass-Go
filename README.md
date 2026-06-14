# Compass Go

A professional compass application for outdoor navigation with advanced sensor integration, real-time tracking, and comprehensive analytics.

## Features

### Core Functionality

- **Real-time Compass**: High-precision heading with tilt compensation
- **Barometric Altimeter**: Real altitude readings from device barometer
- **Haptic Feedback**: Vibration on target alignment for navigation
- **Low Power Mode**: Reduced update rates to conserve battery

### Sensor Integration

- Magnetometer for heading detection
- Accelerometer for tilt compensation
- Barometer for altitude measurement
- Low-pass filtering for noise reduction

### Navigation Features

- Target heading setting
- Visual target marker on compass ring
- Calibration mode for sensor optimization
- True North vs Magnetic North support

### User Interface

- Dark/Light mode support
- Responsive design for all screen sizes
- Real-time sensor data display
- Intuitive settings panel

### Analytics & Tracking

- Screen visit tracking
- Event logging (calibration, haptics, errors)
- Usage summary dashboard
- Session tracking

## Project Structure

```txt
lib/
├── main.dart                    # App entry point
├── core/
│   ├── constants/
│   │   └── app_strings.dart     # String resources
│   └── utils/
│       └── app_theme.dart       # Theme configuration
├── data/
│   ├── services/
│   │   ├── sensor_service.dart           # Core sensor integration
│   │   ├── background_sensor_service.dart # Background processing
│   │   ├── analytics_service.dart        # Usage tracking
│   │   ├── permission_service.dart       # Permission handling
│   │   ├── location_service.dart         # Location services
│   │   └── altitude_service.dart         # Altitude processing
│   └── repositories/
├── domain/
│   ├── entities/
│   │   └── compass_state.dart     # State model
│   └── usecases/
├── presentation/
│   ├── providers/
│   │   ├── app_providers.dart     # DI providers
│   │   └── compass_notifier.dart  # State management
│   ├── navigation/
│   │   └── app_shell.dart         # Shell layout
│   └── screens/
│       ├── home_screen.dart       # Main compass view
│       ├── calibration_screen.dart # Sensor calibration
│       ├── settings_screen.dart   # App settings
│       ├── altitude_screen.dart   # Altitude details
│       ├── sun_moon_screen.dart   # Sun/Moon data
│       ├── target_navigation_screen.dart
│       └── permission_screen.dart # Initial permissions
└── widgets/
    └── compass_ring_widget.dart   # Compass visualization
```

## Architecture

### State Management

- **Provider**: `flutter_riverpod` for reactive state
- **Notifier Pattern**: `CompassStateNotifier` manages sensor state
- **Immutable State**: `CompassState` with copyWith pattern

### Data Flow

```txt
Sensors → SensorService → CompassStateNotifier → UI
                    ↓
              AnalyticsService
```

### Key Components

#### Sensor Service

- Listens to magnetometer, accelerometer, barometer streams
- Applies tilt compensation and low-pass filtering
- Calculates heading with 0.5° accuracy baseline

#### Compass State Notifier

- Manages periodic sensor updates (500ms normal, 1000ms low power)
- Handles calibration sequence
- Triggers haptic feedback on alignment

#### Analytics Service

- Local storage via `shared_preferences`
- Tracks screen visits and custom events
- Provides usage summary

## Configuration

### Dependencies

- `flutter_riverpod`: State management
- `sensors_plus`: Sensor access
- `permission_handler`: Permission management
- `geolocator`: Location services
- `shared_preferences`: Local storage
- `workmanager`: Background tasks
- `flutter_local_notifications`: Notifications

### Android Setup

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.BODY_SENSORS" />
```

### iOS Setup

Add to `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Compass needs location for accurate readings</string>
```

## Usage

### Getting Started

1. Grant sensor permissions on first launch
2. Calibrate magnetometer via figure-8 motion
3. Set target heading for navigation
4. Enable low power mode for extended battery life

### Calibration Process

1. Navigate to Settings → Calibration
2. Perform figure-8 motion with device
3. Wait for completion indicator
4. Verify improved accuracy

### Navigation Mode

1. Set target heading via `targetHeadingProvider`
2. Watch compass ring for alignment
3. Feel haptic feedback when aligned
4. Check accuracy indicator (green = <2°, orange = >2°)

## API Reference

### Sensor Service API

```dart
final service = SensorService();
double heading = await service.getHeading();
double altitude = await service.getAltitudeMeters();
double accuracy = await service.getAccuracy();
service.setSeaLevelPressure(1013.25);
service.dispose();
```

### Analytics Service API

```dart
final service = AnalyticsService(prefs);
service.logScreenVisit('Home');
service.logEvent('calibration_complete', payload: {'duration': 15.5});
service.logSensorReading(heading: 45.0, accuracy: 1.2, altitude: 120.0, lowPowerMode: false);
final summary = service.getSummary();
```

## Testing

Run tests with:

```bash
flutter test
```

## Build

```bash
flutter build apk --release
flutter build ios --release
```

## License

MIT License
