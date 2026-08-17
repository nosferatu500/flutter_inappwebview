package com.pichillilorenzo.flutter_inappwebview_android.types;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.List;
import java.util.Map;
import java.util.Objects;

// Unchecked casts below are the Flutter codec boundary: StandardMessageCodec decodes to
// Map<String,Object>/List<Object>, so every read of a structured value is an unverifiable
// cast. Java cannot check these; a wrong shape throws ClassCastException at the cast site,
// which is the intended failure mode. Suppressed at class level because the whole class is
// that boundary. NOTE: javac does not enable -Xlint:unchecked by default; these only ever
// appeared under -Xlint:all.
@SuppressWarnings("unchecked")
public class ShowFileChooserResponse {
  private boolean handledByClient;
  @Nullable
  private List<String> filePaths;

  public ShowFileChooserResponse(boolean handledByClient, @Nullable List<String> filePaths) {
    this.handledByClient = handledByClient;
    this.filePaths = filePaths;
  }

  @Nullable
  public static ShowFileChooserResponse fromMap(@Nullable Map<String, Object> map) {
    if (map == null) {
      return null;
    }
    boolean handledByClient = (boolean) map.get("handledByClient");
    List<String> filePaths = (List<String>) map.get("filePaths");
    return new ShowFileChooserResponse(handledByClient, filePaths);
  }

  public boolean isHandledByClient() {
    return handledByClient;
  }

  public void setHandledByClient(boolean handledByClient) {
    this.handledByClient = handledByClient;
  }

  @Nullable
  public List<String> getFilePaths() {
    return filePaths;
  }

  public void setFilePaths(@Nullable List<String> filePaths) {
    this.filePaths = filePaths;
  }

  @Override
  public boolean equals(Object o) {
    if (this == o) return true;
    if (o == null || getClass() != o.getClass()) return false;

    ShowFileChooserResponse that = (ShowFileChooserResponse) o;
    return handledByClient == that.handledByClient && Objects.equals(filePaths, that.filePaths);
  }

  @Override
  public int hashCode() {
    int result = Boolean.hashCode(handledByClient);
    result = 31 * result + Objects.hashCode(filePaths);
    return result;
  }

  @NonNull
  @Override
  public String toString() {
    return "ShowFileChooserResponse{" +
            "handledByClient=" + handledByClient +
            ", filePaths=" + filePaths +
            '}';
  }
}
