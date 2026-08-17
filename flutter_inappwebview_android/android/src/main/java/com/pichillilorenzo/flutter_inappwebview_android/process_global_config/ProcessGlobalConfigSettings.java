package com.pichillilorenzo.flutter_inappwebview_android.process_global_config;

import android.content.Context;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.webkit.ProcessGlobalConfig;
import androidx.webkit.WebViewFeature;

import com.pichillilorenzo.flutter_inappwebview_android.ISettings;

import java.io.File;
import java.util.HashMap;
import java.util.Map;

// Unchecked casts below are the Flutter codec boundary: StandardMessageCodec decodes to
// Map<String,Object>/List<Object>, so every read of a structured value is an unverifiable
// cast. Java cannot check these; a wrong shape throws ClassCastException at the cast site,
// which is the intended failure mode. Suppressed at class level because the whole class is
// that boundary. NOTE: javac does not enable -Xlint:unchecked by default; these only ever
// appeared under -Xlint:all.
@SuppressWarnings("unchecked")
public class ProcessGlobalConfigSettings implements ISettings<ProcessGlobalConfig> {
  public static final String LOG_TAG = "ProcessGlobalConfigSettings";

  @Nullable
  public String dataDirectorySuffix;
  @Nullable
  public DirectoryBasePaths directoryBasePaths;

  @NonNull
  @Override
  public ProcessGlobalConfigSettings parse(@NonNull Map<String, Object> settings) {
    for (Map.Entry<String, Object> pair : settings.entrySet()) {
      String key = pair.getKey();
      Object value = pair.getValue();
      if (value == null) {
        continue;
      }

      switch (key) {
        case "dataDirectorySuffix":
          dataDirectorySuffix = (String) value;
          break;
        case "directoryBasePaths":
          directoryBasePaths = (new DirectoryBasePaths()).parse((Map<String, Object>) value);
          break;
      }
    }

    return this;
  }

  public ProcessGlobalConfig toProcessGlobalConfig(@NonNull Context context) {
    ProcessGlobalConfig config = new ProcessGlobalConfig();
    if (dataDirectorySuffix != null &&
            WebViewFeature.isStartupFeatureSupported(context, WebViewFeature.STARTUP_FEATURE_SET_DATA_DIRECTORY_SUFFIX)) {
      config.setDataDirectorySuffix(context, dataDirectorySuffix);
    }
    if (directoryBasePaths != null &&
            WebViewFeature.isStartupFeatureSupported(context, WebViewFeature.STARTUP_FEATURE_SET_DIRECTORY_BASE_PATHS)) {
      applyDirectoryBasePaths(config, context, directoryBasePaths);
    }
    return config;
  }

  // ProcessGlobalConfig.setDirectoryBasePaths is deprecated in androidx.webkit 1.17.0 but has no
  // successor: verified by javap over the 1.17.0 AAR, the class stores mDataDirectoryBasePath and
  // mCacheDirectoryBasePath yet exposes no other public setter for them, and none of the 1.13-1.17
  // release notes mention it. It is not marked for removal. Removing it would drop a capability
  // with no alternative, so it is kept. Re-check on the next androidx.webkit bump.
  @SuppressWarnings("deprecation")
  private static void applyDirectoryBasePaths(@NonNull ProcessGlobalConfig config,
                                              @NonNull Context context,
                                              @NonNull DirectoryBasePaths basePaths) {
    config.setDirectoryBasePaths(context,
            new File(basePaths.dataDirectoryBasePath),
            new File(basePaths.cacheDirectoryBasePath));
  }
  @NonNull
  public Map<String, Object> toMap() {
    Map<String, Object> settings = new HashMap<>();
    settings.put("dataDirectorySuffix", dataDirectorySuffix);
    return settings;
  }

  @NonNull
  @Override
  public Map<String, Object> getRealSettings(@NonNull ProcessGlobalConfig processGlobalConfig) {
    Map<String, Object> realSettings = toMap();
    return realSettings;
  }

  static class DirectoryBasePaths implements ISettings<Object> {
    public static final String LOG_TAG = "ProcessGlobalConfigSettings";

    public String cacheDirectoryBasePath;
    public String dataDirectoryBasePath;

    @NonNull
    @Override
    public DirectoryBasePaths parse(@NonNull Map<String, Object> settings) {
      for (Map.Entry<String, Object> pair : settings.entrySet()) {
        String key = pair.getKey();
        Object value = pair.getValue();
        if (value == null) {
          continue;
        }

        switch (key) {
          case "cacheDirectoryBasePath":
            cacheDirectoryBasePath = (String) value;
            break;
          case "dataDirectoryBasePath":
            dataDirectoryBasePath = (String) value;
            break;
        }
      }

      return this;
    }

    @NonNull
    public Map<String, Object> toMap() {
      Map<String, Object> settings = new HashMap<>();
      settings.put("cacheDirectoryBasePath", cacheDirectoryBasePath);
      settings.put("dataDirectoryBasePath", dataDirectoryBasePath);
      return settings;
    }

    @NonNull
    @Override
    public Map<String, Object> getRealSettings(@NonNull Object obj) {
      Map<String, Object> realSettings = toMap();
      return realSettings;
    }
  }
}