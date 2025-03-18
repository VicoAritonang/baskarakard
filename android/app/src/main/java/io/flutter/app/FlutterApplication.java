package io.flutter.app;

import com.microsoft.appcenter.AppCenter;
import com.microsoft.appcenter.analytics.Analytics;
import com.microsoft.appcenter.crashes.Crashes;
import io.flutter.app.FlutterApplication;

public class FlutterApplication extends io.flutter.app.FlutterApplication {
    @Override
    public void onCreate() {
        super.onCreate();
        AppCenter.start(this, "852ea9f0-7b2a-400b-9870-6be631c9fc13",
                Analytics.class, Crashes.class);
    }
} 