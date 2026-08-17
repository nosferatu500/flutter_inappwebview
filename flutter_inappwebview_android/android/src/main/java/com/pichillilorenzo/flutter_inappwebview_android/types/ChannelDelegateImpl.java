package com.pichillilorenzo.flutter_inappwebview_android.types;

import androidx.annotation.CallSuper;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class ChannelDelegateImpl implements IChannelDelegate {
  @Nullable
  private MethodChannel channel;

  // Publishes `this` before construction completes. Safe here: everything it is published to
  // (the MethodChannel handler, the activity-result listener list, the static manager registries)
  // is only ever reached from the platform/main-thread message loop, and these objects are also
  // constructed on that thread — so no callback can interleave with the constructor. Restructuring
  // to a two-phase init would change the lifecycle of 12 classes for no real-world gain.
  @SuppressWarnings("this-escape")
  public ChannelDelegateImpl(@NonNull MethodChannel channel) {
    this.channel = channel;
    this.channel.setMethodCallHandler(this);
  }

  @Override
  @Nullable
  public MethodChannel getChannel() {
    return channel;
  }

  @CallSuper
  public void dispose() {
    if (channel != null) {
      channel.setMethodCallHandler(null);
      channel = null;
    }
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {

  }
}
