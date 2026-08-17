package com.pichillilorenzo.flutter_inappwebview_android.types;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

// Unchecked casts below are the Flutter codec boundary: StandardMessageCodec decodes to
// Map<String,Object>/List<Object>, so every read of a structured value is an unverifiable
// cast. Java cannot check these; a wrong shape throws ClassCastException at the cast site,
// which is the intended failure mode. Suppressed at class level because the whole class is
// that boundary. NOTE: javac does not enable -Xlint:unchecked by default; these only ever
// appeared under -Xlint:all.
@SuppressWarnings("unchecked")
public class CustomTabsSecondaryToolbar {
  @NonNull
  private AndroidResource layout;
  @NonNull
  private List<AndroidResource> clickableIDs = new ArrayList<>();

  public CustomTabsSecondaryToolbar(@NonNull AndroidResource layout, @NonNull List<AndroidResource> clickableIDs) {
    this.layout = layout;
    this.clickableIDs = clickableIDs;
  }

  @Nullable
  public static CustomTabsSecondaryToolbar fromMap(@Nullable Map<String, Object> map) {
    if (map == null) {
      return null;
    }
    AndroidResource layout = AndroidResource.fromMap((Map<String, Object>) map.get("layout"));
    List<AndroidResource> clickableIDs = new ArrayList<>();
    List<Map<String, Object>> clickableIDList = (List<Map<String, Object>>) map.get("clickableIDs");
    if (clickableIDList != null) {
      for (Map<String, Object> clickableIDMap : clickableIDList) {
        AndroidResource clickableID = AndroidResource.fromMap((Map<String, Object>) clickableIDMap.get("id"));
        if (clickableID != null) {
          clickableIDs.add(clickableID);
        }
      }
    }
    return new CustomTabsSecondaryToolbar(layout, clickableIDs);
  }

  @NonNull
  public AndroidResource getLayout() {
    return layout;
  }

  public void setLayout(@NonNull AndroidResource layout) {
    this.layout = layout;
  }

  @NonNull
  public List<AndroidResource> getClickableIDs() {
    return clickableIDs;
  }

  public void setClickableIDs(@NonNull List<AndroidResource> clickableIDs) {
    this.clickableIDs = clickableIDs;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) return true;
    if (o == null || getClass() != o.getClass()) return false;

    CustomTabsSecondaryToolbar that = (CustomTabsSecondaryToolbar) o;

    if (!layout.equals(that.layout)) return false;
    return clickableIDs.equals(that.clickableIDs);
  }

  @Override
  public int hashCode() {
    int result = layout.hashCode();
    result = 31 * result + clickableIDs.hashCode();
    return result;
  }

  @Override
  public String toString() {
    return "CustomTabsSecondaryToolbar{" +
            "layout=" + layout +
            ", clickableIDs=" + clickableIDs +
            '}';
  }
}
